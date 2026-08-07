# Scribes — Patch 2 Completion: Wiring SyncService to Real Drift Storage
**Version 1.0 · Closes the gap flagged in the Patch 2 audit**

> The router endpoints exist. The Dart constants exist. `SyncService.syncNow()` exists. None of that means sync works — the four storage methods it depends on are currently placeholders that return defaults instead of querying Drift. This document specifies exactly what each method needs to do, with no ambiguity left for guesswork.

---

## The Four Methods, Precisely

### 1. `getLastServerSequence()`

**What it must do:** Return the highest `server_sequence` value currently stored locally across all syncable tables (notes, drafts, posts). This is the checkpoint the pull request uses to ask the server "give me everything after this point."

**What it must NOT do:** Return a hardcoded default, return `0` unconditionally, or track sequence per-table separately when the pull endpoint expects one unified number.

```dart
// client/lib/core/storage/sync_service.dart

Future<int> getLastServerSequence() async {
  final noteMax  = await _db.notesDao.getMaxServerSequence();
  final draftMax = await _db.draftsDao.getMaxServerSequence();
  final postMax  = await _db.postsDao.getMaxServerSequence();  // cached posts, if applicable

  return [noteMax, draftMax, postMax]
      .where((v) => v != null)
      .fold(0, (max, v) => v! > max ? v : max);
}
```

**Required Drift query, per table DAO:**

```dart
// client/lib/core/storage/notes_dao.dart (and equivalent for drafts_dao.dart)

Future<int?> getMaxServerSequence() {
  return (selectOnly(notes)
    ..addColumns([notes.serverSequence.max()]))
    .map((row) => row.read(notes.serverSequence.max()))
    .getSingleOrNull();
}
```

**Why this matters specifically:** if this returns `0` every time, the client re-pulls the entire history on every sync instead of just the delta. It will work, technically — but it defeats the entire purpose of the sequence checkpoint and will degrade badly as data grows.

---

### 2. `getLocalOnlyRecords()`

**What it must do:** Query Drift for every row across notes and drafts where `local_only = true` — the records created or edited offline that have never been confirmed by the server.

**What it must NOT do:** Return an empty list unconditionally, or only check one table when both notes and drafts can be created offline.

```dart
// client/lib/core/storage/sync_service.dart

Future<List<PendingRecord>> getLocalOnlyRecords() async {
  final pendingNotes  = await _db.notesDao.getLocalOnly();
  final pendingDrafts = await _db.draftsDao.getLocalOnly();

  return [
    ...pendingNotes.map((n) => PendingRecord.fromNote(n)),
    ...pendingDrafts.map((d) => PendingRecord.fromDraft(d)),
  ];
}
```

**Required Drift query, per table DAO:**

```dart
// client/lib/core/storage/notes_dao.dart

Future<List<Note>> getLocalOnly() {
  return (select(notes)..where((n) => n.localOnly.equals(true))).get();
}
```

**The `PendingRecord` shape must match what the backend's `POST /sync/push` handler expects** — per `scribes_backend_source_of_truth.md`, the push payload needs enough to identify record type, local ID, and content. Confirm this shape against the real `internal/sync/model.go` `PendingRecord` struct on the backend before finalizing — do not assume the shapes match without checking both sides.

```dart
// client/lib/features/sync/domain/pending_record.dart

class PendingRecord {
  final String localId;
  final String type;        // "note" | "draft"
  final Map<String, dynamic> content;
  final DateTime updatedAt;

  factory PendingRecord.fromNote(Note note) => PendingRecord(
    localId:   note.id,
    type:      'note',
    content:   note.toSyncPayload(),
    updatedAt: note.updatedAt,
  );

  factory PendingRecord.fromDraft(Draft draft) => PendingRecord(
    localId:   draft.id,
    type:      'draft',
    content:   draft.toSyncPayload(),
    updatedAt: draft.updatedAt,
  );
}
```

---

### 3. `applyDelta()`

**What it must do:** Take the response body from `GET /sync?seq=N` and upsert every returned record into the correct local Drift table, updating each row's `server_sequence` to the value the server assigned.

**What it must NOT do:** Silently discard records of a type it doesn't recognize, or fail entirely if one record in the batch is malformed — one bad record should not block the rest of the delta from applying.

```dart
// client/lib/core/storage/sync_service.dart

Future<void> applyDelta(SyncDeltaResponse delta) async {
  for (final record in delta.records) {
    try {
      switch (record.type) {
        case 'note':
          await _db.notesDao.upsertFromServer(record);
          break;
        case 'draft':
          await _db.draftsDao.upsertFromServer(record);
          break;
        case 'post':
          await _db.postsDao.upsertFromServer(record);
          break;
        default:
          // Log and skip — do not throw. An unrecognized type
          // (e.g. a future record type not yet handled client-side)
          // should not break the entire sync operation.
          _logger.warn('Unrecognized sync record type: ${record.type}');
      }
    } catch (e, stack) {
      // Log and continue to the next record — one malformed record
      // must not abort the whole delta application.
      _logger.error('Failed to apply sync record ${record.localId}', e, stack);
    }
  }
}
```

**Required Drift upsert, per table DAO:**

```dart
// client/lib/core/storage/notes_dao.dart

Future<void> upsertFromServer(SyncRecord record) {
  return into(notes).insertOnConflictUpdate(
    NotesCompanion.insert(
      id:             record.localId,
      content:        record.content['content'],
      title:          Value(record.content['title']),
      serverSequence: Value(record.serverSequence),  // server-assigned, always trusted
      localOnly:      const Value(false),             // confirmed by server now
      updatedAt:      record.updatedAt,
    ),
  );
}
```

**This is where the non-negotiable rule matters most on the client side too:** `serverSequence` in the upsert always comes from `record.serverSequence` — the value the backend assigned — never recalculated or preserved from a prior local value. The client trusts the server's ordering completely.

---

### 4. `confirmSynced()`

**What it must do:** Take the response from `POST /sync/push` — which maps each pushed `localId` to its newly assigned `server_sequence` — and update those local rows to set `local_only = false` and store the real sequence number.

**What it must NOT do:** Mark a record as synced if the push response didn't actually confirm it (e.g., if the backend rejected one record in a batch push, that specific record must remain `local_only = true`).

```dart
// client/lib/core/storage/sync_service.dart

Future<void> confirmSynced(SyncPushResponse response) async {
  for (final confirmation in response.confirmed) {
    switch (confirmation.type) {
      case 'note':
        await _db.notesDao.markSynced(
          confirmation.localId,
          confirmation.serverSequence,
        );
        break;
      case 'draft':
        await _db.draftsDao.markSynced(
          confirmation.localId,
          confirmation.serverSequence,
        );
        break;
    }
  }

  // Anything in the original push batch that is NOT in response.confirmed
  // was rejected server-side and must remain local_only = true.
  // Do not assume the whole batch succeeded just because the call returned 200 —
  // check the confirmed list explicitly, record by record.
}
```

**Required Drift update, per table DAO:**

```dart
// client/lib/core/storage/notes_dao.dart

Future<void> markSynced(String localId, int serverSequence) {
  return (update(notes)..where((n) => n.id.equals(localId))).write(
    NotesCompanion(
      serverSequence: Value(serverSequence),
      localOnly:      const Value(false),
    ),
  );
}
```

---

## The Full `syncNow()` — What It Should Look Like When Actually Done

```dart
// client/lib/core/storage/sync_service.dart — complete, not scaffolded

class SyncService {
  final ApiClient _api;
  final AppDatabase _db;
  final Logger _logger;

  Future<void> syncNow() async {
    // PULL
    final lastSeq = await getLastServerSequence();
    final deltaResponse = await _api.get(
      Endpoints.syncPull,
      queryParams: {'seq': lastSeq.toString()},
    );
    final delta = SyncDeltaResponse.fromJson(deltaResponse.data);
    await applyDelta(delta);

    // PUSH
    final pending = await getLocalOnlyRecords();
    if (pending.isNotEmpty) {
      final pushResponse = await _api.post(
        Endpoints.syncPush,
        body: {'records': pending.map((r) => r.toJson()).toList()},
      );
      final result = SyncPushResponse.fromJson(pushResponse.data);
      await confirmSynced(result);
    }
  }
}
```

---

## The Real Verification — Not a Smoke Test

The audit's mistake was treating "the code compiles and the route responds" as sufficient. It is not. This is the actual test that proves Patch 2 is done:

```
1. Put the device/simulator in airplane mode.
2. Create a Note with distinct, identifiable content ("SYNC-TEST-001").
3. Confirm it appears in the local Notes list immediately.
4. Confirm via Drift inspection (or a debug screen) that:
     - local_only = true
     - server_sequence = null
5. Re-enable network.
6. Trigger syncNow() — either automatically via the connectivity listener,
   or manually via a debug button.
7. Confirm via Drift inspection that the same note now shows:
     - local_only = false
     - server_sequence = <some real positive integer>
8. Independently, call GET /sync?seq=0 directly against the backend
   (curl or Postman, using the same user's JWT) and confirm
   "SYNC-TEST-001" appears in the response with a matching server_sequence.
9. Only after step 8 passes is Patch 2 actually complete.
```

Step 8 is the one the original audit skipped. Everything up to step 7 can pass even with placeholder methods, if the placeholders happen to not throw errors. Step 8 is the only step that proves data actually moved from the device to the server.

---

## Updated Status

| Patch | Audit's claim | Actual status | What's left |
|---|---|---|---|
| 1 — Admin guard | ✅ Complete | ✅ Confirmed complete | Nothing |
| 2 — Sync protocol | ✅ Complete | ⚠️ Scaffolded, not functional | Wire 4 methods above, run the 9-step verification |
| 3 — Follow mapping | ✅ Complete | ✅ Confirmed complete | Nothing |

**Do not proceed to Media or Bible feature work until Patch 2's step 8 verification passes against the real running backend.**

---

*Scribes Patch 2 Completion Spec v1.0*
*Closes the placeholder gap in SyncService — wires all four storage methods to real Drift queries* /