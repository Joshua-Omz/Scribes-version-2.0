# Sprint 5 — The Sync Worker

**Phase**: 3 (Integration & Launch)  
**Weeks**: 9–10  
**Status**: 🔲 Pending

---

## Goal

Connect the Flutter client to the Go sync engine. Implement background sync with offline queuing and exponential backoff.

---

## Deliverables

| Task | Status | Notes |
|---|---|---|
| Background sync queue in Flutter | 🔲 | Use `WorkManager` or a long-running Isolate |
| Push local mutations | 🔲 | `POST /api/sync/push` with `sync_status = pending` records |
| Pull server deltas | 🔲 | `GET /api/sync/pull?last_synced_at=<stored_server_time>` |
| LWW conflict resolution in Drift | 🔲 | Compare `updated_at`; server wins if newer |
| Update `sync_status` to `synced` | 🔲 | After successful round-trip |
| Offline queuing | 🔲 | Buffer mutations in Drift when no connectivity |
| Connectivity detection | 🔲 | `connectivity_plus` package |
| Exponential backoff retries | 🔲 | `dio` retry interceptor; max 5 retries |
| Integration tests | 🔲 | Mock server responses; verify LWW outcomes |

---

## Sync Loop

```
1. Check connectivity (connectivity_plus)
2. If online:
   a. Read all Drift records with sync_status = "pending"
   b. POST /api/sync/push  → get applied/skipped counts
   c. GET  /api/sync/pull?last_synced_at=<last_server_time>
   d. For each returned record:
      - If server.updated_at > local.updated_at → overwrite local
      - Else → keep local (already pushed)
   e. Save server_time from pull response as new last_synced_at
   f. Mark pushed records as sync_status = "synced"
3. If offline:
   - All writes go to Drift with sync_status = "pending"
   - Retry when connectivity restored
```

---

## Packages

| Package | Purpose |
|---|---|
| `dio` | HTTP client + retry interceptor |
| `connectivity_plus` | Network state monitoring |
| `drift` | Local SQLite ORM |
| `flutter_riverpod` | State management for sync status |

---

## Testing Strategy

- Mock the Go API with `mockito` or a local HTTP server in tests.
- Test cases:
  1. Normal sync: pending records pushed, server delta merged.
  2. Server-wins conflict: server `updated_at` is newer.
  3. Client-wins: push succeeds, pull returns same record (no overwrite).
  4. Offline: mutations queued, retry succeeds on reconnect.
  5. Network failure mid-push: records remain `pending`, retry works.
