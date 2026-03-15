# Sprint 2 — The Delta Sync Engine

**Phase**: 1 (Backend Foundation)  
**Weeks**: 3–4  
**Status**: ✅ Complete

---

## Goal

Implement a reliable delta sync engine so that local-first clients can synchronise their private workspace with the server without transferring the entire dataset on every sync.

---

## Deliverables

### Pull Endpoint

| Task | Status | Notes |
|---|---|---|
| `GET /api/sync/pull` | ✅ | Accepts `last_synced_at` (RFC3339) query param |
| Returns Notes delta | ✅ | `SELECT … WHERE updated_at > $last_synced_at` |
| Returns Drafts delta | ✅ | Same pattern |
| Returns Posts delta | ✅ | Public feed deltas (no user filter) |
| Returns `server_time` | ✅ | Client stores this as the new `last_synced_at` |
| First sync (no `last_synced_at`) | ✅ | Returns entire dataset |

### Push Endpoint

| Task | Status | Notes |
|---|---|---|
| `POST /api/sync/push` | ✅ | Accepts `{ notes: [...], drafts: [...] }` |
| LWW conflict resolution (Notes) | ✅ | `ON CONFLICT … WHERE notes.updated_at < EXCLUDED.updated_at` |
| Ownership enforcement | ✅ | `user_id` is always taken from the JWT, not the payload |
| Returns `applied` / `skipped` count | ✅ | |

### Soft Deletes

| Task | Status | Notes |
|---|---|---|
| Notes `deleted_at` | ✅ | Set via `DELETE /api/notes/{id}` or push payload |
| Drafts `deleted_at` | ✅ | Set via `DELETE /api/drafts/{id}` |
| Deleted records included in delta | ✅ | `deleted_at IS NOT NULL` rows included in pull response |

### Chronological Feeds

| Task | Status | Notes |
|---|---|---|
| Posts feed `ORDER BY created_at DESC` | ✅ | `GET /api/posts` |
| Notes list `ORDER BY created_at DESC` | ✅ | `GET /api/notes` |
| Drafts list `ORDER BY created_at DESC` | ✅ | `GET /api/drafts` |

---

## API Reference (Sprint 2)

### Pull — Fetch server deltas

```
GET /api/sync/pull?last_synced_at=2026-03-01T00:00:00Z   [Bearer required]

Response 200:
{
  "notes":       [ { "id": "...", "updated_at": "...", "deleted_at": null, ... } ],
  "drafts":      [ ... ],
  "posts":       [ ... ],
  "server_time": "2026-03-15T12:00:00Z"
}
```

### Push — Upload client mutations

```
POST /api/sync/push   [Bearer required]
Body:
{
  "notes": [
    {
      "id":         "client-generated-uuid",
      "title":      "My Note",
      "body":       "...",
      "created_at": "2026-03-10T09:00:00Z",
      "updated_at": "2026-03-15T11:00:00Z",
      "deleted_at": null
    }
  ],
  "drafts": []
}

Response 200:
{
  "applied": 1,
  "skipped": 0,
  "sync_at":  "2026-03-15T12:00:01Z"
}
```

---

## Conflict Resolution Strategy

Scribes uses **Last-Write-Wins (LWW)** based on `updated_at` timestamps:

```sql
INSERT INTO notes (id, user_id, title, body, created_at, updated_at, deleted_at)
VALUES (…)
ON CONFLICT (id) DO UPDATE
  SET title      = EXCLUDED.title,
      body       = EXCLUDED.body,
      updated_at = EXCLUDED.updated_at,
      deleted_at = EXCLUDED.deleted_at
WHERE notes.updated_at < EXCLUDED.updated_at;
```

If the server's `updated_at` is **newer** than the client's, the push is silently ignored. The client will receive the server's version on the next Pull.

---

## Notes for Sprint 5 (Flutter Sync Worker)

- Store `server_time` from the Pull response as `last_synced_at` in Drift.
- On every sync cycle: Push first → then Pull.
- Implement exponential backoff using `dio` retry interceptor.
- Mark records with `sync_status = pending | synced | conflict` in the local Drift schema.
