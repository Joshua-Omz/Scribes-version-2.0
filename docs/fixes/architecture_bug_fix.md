# Architecture and Bug Fix Plan: Feed, Search, Explore, Sync, Notification

This document outlines the proposed architectural changes and bug fixes to resolve coupling issues, N+1 query bottlenecks, logic errors, and missing features across the requested domains.

## User Review Required

> [!WARNING]
> **Breaking changes to `search` & `sync`:** The `search` service will now explicitly pass `nil` for vectors when embeddings fail, requiring the SQL query to handle NULL vectors gracefully. The `sync` service requires a new `Push` endpoint, which will change the sync contract with the client.

## Open Questions

> [!IMPORTANT]
> **Sync Push Mechanism:** Currently, the `sync` service only has a `Pull` endpoint. Do you want the `Push` mechanism to be a dedicated `/sync/push` bulk endpoint that accepts an array of offline mutations? Or are offline changes currently expected to be flushed one-by-one to their standard REST endpoints (e.g., `POST /posts`, `PUT /notes`) once online? I strongly recommend a dedicated `/sync/push` bulk endpoint for atomic offline-syncing.

## Proposed Changes

---

### Feed & Explore (Performance / N+1 Query Bug)
**Problem:** In `backend/internal/feed/repository.go`, `GetFeedPosts`, `GetExplorePosts`, and related functions iterate over the returned rows and execute two separate database queries (`GetScriptureRefs` and `GetPostTags`) for *every single post*. Fetching a single page of 20 posts results in 41 separate database queries. This is a massive N+1 bottleneck.

#### [MODIFY] `backend/internal/feed/repository.go`
- **Action:** Refactor all feed retrieval functions to use an in-memory mapping strategy.
- **Implementation:** 
  1. Fetch the page of `FeedPost` rows.
  2. Extract all `post.ID`s into a slice of UUIDs.
  3. Execute a single new query `GetScriptureRefsForPosts(ctx, postIDs)` and a single `GetPostTagsForPosts(ctx, postIDs)`.
  4. Build a hash map in memory and attach the tags and refs to the posts in a single pass.
  *(This will require modifying the `sqlc` queries in the database layer).*

---

### Search (Hybrid Search Distortion Bug)
**Problem:** In `backend/internal/search/service.go`, if `GenerateEmbedding` fails or if the query is empty, the service falls back to generating a zero-vector: `vecString = formatVectorString(make([]float32, 768))`. Passing a zero-vector into a hybrid search (pgvector) distorts the cosine similarity scoring, effectively ruining the lexical search fallback.

#### [MODIFY] `backend/internal/search/service.go`
- **Action:** Stop passing zero-vectors to the database.
- **Implementation:** If semantic embedding fails, keep `vecString = nil`. The underlying database query `SearchPostsHybrid` must be updated to ignore the vector similarity score if the passed vector is NULL, relying solely on `ts_rank` (lexical search).

---

### Notification (Panic Risk & Grouping Logic Hack)
**Problem 1 (Panic Risk):** In `backend/internal/notification/service.go`, `Broadcast()` sends to `ch <- notif` inside an `RLock`. `Unsubscribe()` calls `close(ch)` inside a `Lock`. While the mutex prevents them from running simultaneously, if a broadcast is waiting to acquire `RLock`, and `Unsubscribe` deletes and closes the channel, the subsequent `Broadcast` could panic if it held a stale reference.
**Problem 2 (Domain Hack):** The `groupNotifications` function temporarily hijacks the `Body` field to store the `ActorHandle` string before generating the final text. 

#### [MODIFY] `backend/internal/notification/service.go`
- **Action 1:** Do not call `close(ch)` in `Unsubscribe`. Simply delete the channel from the `s.clients` map: `delete(subs, ch)`. The garbage collector will safely clean up the unreferenced channel without risking a `send on closed channel` panic.
- **Action 2:** Create an internal helper struct (e.g. `notificationGroupTemp`) to hold `ActorHandle`, `Count`, and `Rows` separately during the grouping loop, rather than modifying the final `NotificationGroup` domain model halfway through.

---

### Sync (Architectural Gap & DB Cost Bug)
**Problem 1 (Backend Push Missing):** The `backend/internal/sync` service only exposes a `Pull` mechanism (`h.svc.Pull`). Offline-first architectures heavily rely on a `Push` mechanism to resolve local `Drift` database mutations.
**Problem 2 (Client Query Cost Surge):** In the client, `note_editor_provider.dart` currently triggers `repo.pushToCloud(state.noteId)` in the background *every 2 seconds* during autosave. This creates a massive spike in database query costs and network traffic, as every keystroke essentially fires a single REST update to the server.

#### [NEW] `backend/internal/sync/handler.go` & `service.go`
- **Action:** Implement `Push(ctx context.Context, events []SyncEvent)` to accept batched mutations from the client.
- **Implementation:** The service will iterate through incoming `SyncEvent`s (e.g., Note created, Draft updated), apply them to the respective feature repositories inside a database transaction, and update the server-side sequence number.

#### [MODIFY] `client/lib/features/notes/application/note_editor_provider.dart`
- **Action:** Remove the direct background `pushToCloud()` invocation on autosave.
- **Implementation:** Autosave will *only* call `saveNoteLocally` (which naturally marks the Drift record as `isSynced = false`). 

#### [MODIFY] `client/lib/features/sync/application/sync_service.dart`
- **Action:** Refactor `pushNotes` and `pushDrafts` to use the new bulk backend `/sync/push` endpoint.
- **Implementation:** Instead of looping and firing `N` individual API requests, it will batch all records where `isSynced == false` into a single payload, send it to the backend once, and then mark them all as `isSynced == true` locally. This changes the sync cadence from "every 2 seconds per note" to a controlled batch process (e.g., app backgrounding, manual pull-to-refresh, or a 60-second periodic timer).

---

## Verification Plan

### Automated Tests
- Run `go test ./internal/notification/...` to ensure grouping logic correctly collapses 24h windows without corrupting actor handles.
- Run `go test ./internal/search/...` mocking a failed embedding API call, ensuring it does not panic and successfully passes `nil`.

### Manual Verification
- Deploy the updated Feed queries and monitor SQL execution logs to confirm that exactly 3 queries are fired per feed request instead of 41.
- Establish an SSE connection to `/notifications` and force an abrupt client disconnect to ensure the server does not panic on `Unsubscribe`.
