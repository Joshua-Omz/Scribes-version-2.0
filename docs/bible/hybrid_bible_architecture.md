# Scribes — Bible Drawer & Quick-Read Feature Contract
**Version 3.0 · Hybrid architecture — bundled offline default, server-hosted for search, sync, and future translations**

> Two related features in one contract: (1) tapping any scripture reference chip anywhere in the app opens a quick-read overlay, and (2) a full Bible is accessible from a drawer for open reading and searching. This version replaces the pure server-hosted design of v2.0 with a hybrid model — BSB ships bundled inside the app itself, so scripture reading requires zero network call, ever, even on first launch in airplane mode. The server remains responsible only for what genuinely needs a server: full-text search, reading-position sync across devices, and future additional-translation downloads.

---

## 1. Why Hybrid, Not Pure Server-Hosted

v2.0 of this contract called BSB "self-hosted" and meant self-hosted *on the Scribes server* — every verse read was still an HTTP round trip, just to Scribes' own backend instead of a third party's. That solved the *dependency* problem (no reliance on an external API) but not the *connectivity* problem — a user with no signal still couldn't read a verse.

This version fixes that by putting the actual verse data on the device. The architecture now mirrors what YouVersion itself does: <cite index="29-1">a default translation is bundled and always available offline,</cite> <cite index="23-1">while functions like search remain server-dependent even when a translation is downloaded.</cite> <cite index="23-1">YouVersion's own downloaded translations run under 0.2GB of on-device storage for text alone</cite> — Scribes' single-translation bundle, being simpler (no cross-reference metadata, no catalog structure), will land closer to the original 3-4MB estimate.

**The resulting split:**

| Capability | Lives where | Needs network? |
|---|---|---|
| Reading any verse in BSB | Bundled SQLite, on-device | **No — zero network, ever** |
| Scripture chip quick-read tap | Bundled SQLite, on-device | **No** |
| Full Bible Drawer browsing (BSB) | Bundled SQLite, on-device | **No** |
| Full-text search across verses | Server (`GET /bible/search`) | Yes |
| Reading position sync across devices | Server | Yes |
| Downloading a second translation (future) | Server → cached to on-device SQLite | Yes, once — then offline forever after |

This is not a smaller version of the server-hosted design — it is a different center of gravity. The device is now the primary source of truth for reading; the server is the primary source of truth for anything that is inherently cross-device or requires searching at scale.

---

## 2. The Bundled Database

### What ships inside the app

A single pre-populated SQLite file, `bsb.sqlite3`, built once at development time and shipped as a Flutter asset — not created on-device, not downloaded on first launch. It exists in the app binary from the moment of install.

```
assets/bible/bsb.sqlite3
```

### Schema — identical shape to the original server-side design, minus anything server-only

```sql
-- The bundled file's schema — built once, offline, via the import script in §4

CREATE TABLE books (
    id            INTEGER PRIMARY KEY,
    name          TEXT NOT NULL,          -- "Genesis"
    short_name    TEXT NOT NULL,           -- "Gen"
    testament     TEXT NOT NULL,           -- "old" | "new"
    book_order    INTEGER NOT NULL,        -- 1-66
    chapter_count INTEGER NOT NULL
);

CREATE TABLE verses (
    id       INTEGER PRIMARY KEY,
    book_id  INTEGER NOT NULL REFERENCES books(id),
    chapter  INTEGER NOT NULL,
    verse    INTEGER NOT NULL,
    text     TEXT NOT NULL
);

CREATE INDEX idx_verses_lookup ON verses (book_id, chapter, verse);
```

No `translation_id` column here — the bundled file is single-translation by construction, since it only ever contains BSB. No `attribution_text` column either — the attribution string is a static constant in the Flutter code, not data, since there's only ever one bundled translation to credit.

### Why SQLite specifically, not JSON assets

A ~31,000-row JSON file loaded and parsed into memory on every app launch is real, avoidable overhead. SQLite gives indexed, instant lookups (`SELECT text FROM verses WHERE book_id = ? AND chapter = ? AND verse BETWEEN ? AND ?`) without ever holding the whole Bible in memory at once, and it's the same storage engine Drift already uses elsewhere in the app — no new dependency category introduced.

---

## 3. Flutter Package: `lib/features/bible/`

```
lib/features/bible/
├── data/
│   ├── local/
│   │   └── bible_local_datasource.dart   — opens and queries bsb.sqlite3 directly
│   ├── remote/
│   │   └── bible_api.dart                 — calls GET /bible/search, reading-position endpoints
│   └── bible_repository.dart              — decides local vs remote per method, see §5
├── domain/
│   ├── verse.dart
│   ├── chapter.dart
│   └── book.dart
├── application/
│   ├── bible_drawer_notifier.dart
│   └── verse_lookup_provider.dart          — used by ScribesScriptureChip
└── presentation/
    ├── bible_drawer.dart
    ├── bible_book_list.dart
    ├── bible_chapter_view.dart
    ├── bible_search_bar.dart
    └── quick_verse_sheet.dart
```

### The local datasource — this is what actually gets used for reading

```dart
// lib/features/bible/data/local/bible_local_datasource.dart

class BibleLocalDatasource {
  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    // Copy the bundled asset to a real file path on first access —
    // sqflite cannot open a database directly from Flutter asset bundles,
    // it needs an actual file path on the device's filesystem.
    final dbPath = await _ensureDatabaseCopied();
    _db = await openDatabase(dbPath, readOnly: true);
    return _db!;
  }

  Future<String> _ensureDatabaseCopied() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDir.path, 'bsb.sqlite3');

    if (!await File(dbPath).exists()) {
      final data = await rootBundle.load('assets/bible/bsb.sqlite3');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }
    return dbPath;
  }

  Future<List<Book>> getBooks() async {
    final db = await _getDb();
    final rows = await db.query('books', orderBy: 'book_order ASC');
    return rows.map((r) => Book.fromSqlite(r)).toList();
  }

  Future<Chapter> getChapter(String bookName, int chapter) async {
    final db = await _getDb();
    final rows = await db.rawQuery('''
      SELECT v.verse, v.text FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE b.name = ? AND v.chapter = ?
      ORDER BY v.verse ASC
    ''', [bookName, chapter]);
    return Chapter(book: bookName, chapter: chapter, verses: rows.map((r) => Verse.fromSqlite(r)).toList());
  }

  Future<List<Verse>> getVerseRange(Reference ref) async {
    final db = await _getDb();
    final end = ref.verseEnd ?? ref.verseStart;
    final rows = await db.rawQuery('''
      SELECT v.verse, v.text FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE b.name = ? AND v.chapter = ? AND v.verse BETWEEN ? AND ?
      ORDER BY v.verse ASC
    ''', [ref.book, ref.chapter, ref.verseStart, end]);
    return rows.map((r) => Verse.fromSqlite(r)).toList();
  }
}
```

**This is the entire reading path.** No `http`, no `Dio`, no `Endpoints.bible*`, no loading state for network latency — because there is no network call. `_getDb()` after the very first access is a cached, already-open, indexed SQLite handle; every subsequent read is effectively instant.

---

## 4. Building the Bundled File (One-Time, Development-Side)

This replaces §2's `cmd/import-bible/main.go` from v2.0 — the import target is now a standalone SQLite file, not a PostgreSQL database.

```bash
# Step 1 — same source data as before
npx @helloao/cli export --translation BSB --format json --output ./bible-data/

# Step 2 — a one-off Go or Python script reads the exported JSON and
# writes directly into a fresh SQLite file matching the schema in §2,
# rather than inserting into Postgres tables.
go run cmd/build-bible-sqlite/main.go \
  --input ./bible-data/ \
  --output ./assets_source/bsb.sqlite3

# Step 3 — copy the resulting file into the Flutter project
cp ./assets_source/bsb.sqlite3 client/assets/bible/bsb.sqlite3

# Step 4 — register it in pubspec.yaml
```

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/bible/bsb.sqlite3
```

**Verification before shipping:**

```bash
sqlite3 assets/bible/bsb.sqlite3 "SELECT COUNT(*) FROM books;"   # expect 66
sqlite3 assets/bible/bsb.sqlite3 "SELECT COUNT(*) FROM verses;"  # expect ~31,000
sqlite3 assets/bible/bsb.sqlite3 "SELECT name FROM books ORDER BY book_order LIMIT 1;"  # expect "Genesis"
```

This build step runs once per app release, not per install and not at runtime. If BSB's source text is ever corrected, this script re-runs and the updated `bsb.sqlite3` ships in the next app update — the same tradeoff already accepted knowingly in exchange for true offline guarantee (see §8).

---

## 5. What Still Needs the Server — and Only This

### `GET /bible/search` (server-hosted, unchanged from v2.0)

Full-text search across all 31,000 verses is achievable on-device via SQLite's FTS5 extension, but it's meaningfully more implementation and index-maintenance work for a feature that isn't the primary offline use case — someone without signal is overwhelmingly more likely to be *reading a specific reference* (handled fully offline above) than *searching by keyword*. Matching YouVersion's own precedent — <cite index="23-1">search still requires a connection even for downloaded translations</cite> — search stays server-side.

```
GET /bible/search?q=steadfast+love&limit=20     PUBLIC, same as v2.0
```

Backend package `internal/bible/` from v2.0 is retained **only** for this endpoint and the reading-position endpoints below — `GetBooks`, `GetChapter`, and `GetVerseRange` service methods are no longer called by the Flutter client and can be simplified or removed from the backend's public surface, since the client now serves those from the bundled file directly. Confirm with whoever owns the backend whether to keep them as internal/admin tooling (e.g., for generating the bundled file itself) or remove entirely.

### `GET` / `POST /bible/reading-position` (server-hosted, unchanged from v2.0)

Reading position is inherently cross-device state — inherently something a single on-device SQLite file cannot represent. Stays exactly as specified in v2.0.

```
GET  /bible/reading-position    PROTECTED
POST /bible/reading-position    PROTECTED
```

### Full current backend endpoint surface for Bible

```
GET  /bible/search                PUBLIC
GET  /bible/reading-position      PROTECTED
POST /bible/reading-position      PROTECTED
```

**Three endpoints, not six.** `GetBooks`, `GetChapter`, and `GetVerseRange` as public HTTP endpoints are removed from this contract's required surface — the Flutter client never calls them once bundled SQLite is in place.

---

## 6. The Repository — Deciding Local vs Remote

```dart
// lib/features/bible/data/bible_repository.dart

class BibleRepository {
  final BibleLocalDatasource _local;
  final BibleApi _remote;

  // Reading — always local, always instant, never touches network
  Future<List<Book>> getBooks() => _local.getBooks();
  Future<Chapter> getChapter(String book, int chapter) => _local.getChapter(book, chapter);
  Future<List<Verse>> getVerseRange(Reference ref) => _local.getVerseRange(ref);

  // Search — always remote, requires network, surface this clearly in the UI
  Future<List<Verse>> search(String query) => _remote.search(query);

  // Reading position — always remote, cross-device by nature
  Future<void> saveReadingPosition(Reference ref) => _remote.saveReadingPosition(ref);
  Future<Reference?> getReadingPosition() => _remote.getReadingPosition();
}
```

This repository is the single place the local/remote decision is made — every other layer of the app (`ScribesScriptureChip`, the Bible Drawer) calls `BibleRepository` and never needs to know or care which method hits SQLite and which hits HTTP.

---

## 7. UI Implications of the Split

- **The scripture chip's quick-read tap is now genuinely instant** — no loading spinner needed at all for the common case, since it's a local SQLite read. This is a real UX improvement over v2.0, worth calling out to whoever builds the widget.
- **The Bible Drawer's search bar needs an explicit offline state.** If `BibleRepository.search()` fails due to no connectivity, show a clear, calm message — *"Search needs a connection. Browse by book instead —"* with a shortcut back to the book list — rather than a generic error. This is the one place in an otherwise fully-offline feature where connectivity genuinely matters, so it deserves its own considered empty/error state rather than inheriting a generic API-failure handler.
- **Reading position sync happens silently in the background when online**, and simply doesn't update when offline — the drawer still opens to whatever position was last successfully synced, which degrades gracefully rather than blocking anything.

---

## 8. Non-Negotiables for This Feature

1. **BSB reading — book list, chapter view, verse range lookup, scripture chip — requires zero network call, under all circumstances, including first launch in airplane mode.** This is the entire point of the hybrid redesign and the one rule every other decision in this document serves.
2. **Attribution is always visible.** "Berean Standard Bible" appears wherever verse text is shown, in-app or exported — this is a static string in the Flutter code now, not fetched data, but the requirement is unchanged from v2.0.
3. **Search and reading-position sync are allowed to require connectivity** — this is an explicit, accepted exception to rule 1, not an oversight. The UI must communicate this distinction clearly rather than let a search failure look like a general app malfunction.
4. **Scripture chip inline expansion, never a modal.** Unchanged design law from the original brief.
5. **Verse text is immutable on-device.** The bundled SQLite file is read-only (`openDatabase(..., readOnly: true)`) — there is no path in the app that writes to `bsb.sqlite3`. Any correction to BSB text requires rebuilding the file and shipping an app update, per §4.
6. **No commercial gating of scripture, ever.** Unchanged from v2.0 — Bible reading, bundled or downloaded, is never behind a paywall or tier.

---

## 9. Future Work — Additional Translation Downloads

This section is unchanged in spirit from v2.0's §10, but the mechanics now match YouVersion's actual pattern rather than a guessed one:

```
User taps "Download NIV" in the Bible Drawer's translation picker
        │
        ▼
App calls a (future) backend endpoint: GET /bible/translations/:code/full
        │  Server streams the complete translation as JSON —
        │  pulled from wherever the server sources it (e.g. YouVersion
        │  Platform API, per the earlier licensing discussion), once
        ▼
App writes the result into a NEW local SQLite file: nlt.sqlite3
        │  (same schema as bsb.sqlite3, one file per downloaded translation —
        │  never merged into the bundled BSB file, which stays read-only and untouched)
        ▼
NIV now reads exactly like BSB does today — fully local, zero network,
using the same BibleLocalDatasource pattern, just pointed at a different file
```

**Why a separate file per translation, not one growing database:** keeping `bsb.sqlite3` permanently read-only and untouched means the guaranteed-offline default can never be corrupted or partially-written by a failed download of something else. Each downloaded translation is its own independent, deletable file — matching <cite index="24-1">YouVersion's own per-version download/remove pattern</cite> exactly, including the ability to free up storage by removing a downloaded translation without touching the default.

This remains unbuilt in v1 of the Bible feature — documented here so the schema and file-per-translation pattern don't need rediscovering when it's prioritized.

---

## 10. Connection to Post Export

Unchanged in principle from v2.0's §8, updated for the new data path: when a published Post's scripture reference is rendered for export, the export pipeline should call `BibleRepository.getVerseRange()` — the same local-first path the in-app chip uses — rather than a duplicate implementation or a network call. This also means **exporting a post with a scripture reference works offline**, consistent with the export feature's own goal of not requiring connectivity.

---

## 11. Done Criteria

### Bundled data (development-side, verified before any app release)
- [ ] `bsb.sqlite3` contains exactly 66 books and ~31,000 verses — confirmed via direct `sqlite3` CLI query, not assumed from the import script's exit code
- [ ] Genesis is `book_order = 1`; Revelation is `book_order = 66`
- [ ] File is registered in `pubspec.yaml` and confirmed present in a built app bundle (not just the source tree)

### Flutter — offline reading path
- [ ] With the device in airplane mode, on a **fresh install**, tapping any `ScribesScriptureChip` shows real BSB verse text inline — not a modal, not an error, not a loading spinner that never resolves
- [ ] With the device in airplane mode, the Bible Drawer opens, browses books, and displays chapters correctly
- [ ] First-access database copy (`_ensureDatabaseCopied`) is verified to only happen once per install — confirmed by checking the file isn't re-copied on every app launch
- [ ] Verse numbers render as small gold Cormorant Garamond superscripts, per the existing typesetting spec

### Flutter — online-only paths, with graceful offline handling
- [ ] Search returns real results when online
- [ ] Search shows the specific offline-state message (§7), not a generic error, when offline
- [ ] Reading position saves and restores correctly when online; drawer still opens to last-known position when offline

### Backend
- [ ] `GET /bible/search` and both reading-position endpoints work correctly
- [ ] Confirm with the backend owner whether `GetBooks`/`GetChapter`/`GetVerseRange` service methods are removed from the public router or retained as internal tooling — do not leave this undecided

### Export integration
- [ ] Exporting a post with a scripture reference works correctly with the device offline

---

## 12. Updated Totals

| Metric | v2.0 (pure server-hosted) | v3.0 (hybrid) |
|---|---|---|
| Bible backend endpoints | 6 | **3** (Books/Chapter/VerseRange removed from public surface) |
| Platform total endpoints | 70 | **67** |
| Bible-specific tables (Postgres) | 4 | **2** (`bible_reading_position` only meaningful server table; search can run against a lighter server-side verse-search table rather than the full relational set — confirm exact server-side schema needs with backend owner before finalizing migration 016) |
| New client-side asset | — | **1** bundled SQLite file, ~3-4MB app size increase |

---

*Scribes Bible Drawer & Quick-Read Feature Contract v3.0*
*Bundled offline-first default · Server reserved for search, sync, and future downloads · Zero network required to read scripture, ever*