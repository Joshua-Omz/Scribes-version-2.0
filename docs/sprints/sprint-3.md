# Sprint 3 — Offline Database & The Editor

**Phase**: 2 (Local-First Client)  
**Weeks**: 6–7  
**Status**: 🔲 Pending

---

## Goal

Build the local-first Flutter application layer: an offline-capable SQLite database (Drift) and a rich text editor UI.

---

## Deliverables

| Task | Status | Notes |
|---|---|---|
| Flutter project initialisation | 🔲 | `flutter create scribes_app` |
| Riverpod state management | 🔲 | `flutter_riverpod`, `riverpod_annotation` |
| Drift SQLite integration | 🔲 | `drift`, `drift_dev`, `sqlite3_flutter_libs` |
| Local schema — Notes table | 🔲 | Mirror backend schema: `id`, `title`, `body`, `created_at`, `updated_at`, `deleted_at`, `sync_status` |
| Local schema — Drafts table | 🔲 | Same pattern |
| WYSIWYG Rich Text Editor UI | 🔲 | `flutter_quill` or `super_editor` |
| Offline Create Note | 🔲 | |
| Offline Read Notes list | 🔲 | Sorted by `created_at DESC` |
| Offline Update Note | 🔲 | Bumps `updated_at`, sets `sync_status = pending` |
| Offline Soft-Delete Note | 🔲 | Sets `deleted_at`, `sync_status = pending` |

---

## Local Drift Schema (Notes)

```dart
class Notes extends Table {
  TextColumn get id        => text().withLength(min: 36, max: 36)();
  TextColumn get userId    => text()();
  TextColumn get title     => text().withDefault(const Constant(''))();
  TextColumn get body      => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  // pending | synced | conflict
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## Sync Status Lifecycle

```
[created/edited offline] → sync_status = "pending"
[pushed successfully]    → sync_status = "synced"
[LWW conflict detected]  → sync_status = "conflict" (show in UI)
```
