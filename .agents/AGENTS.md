### Architecture & Performance Invariants
* **N+1 Query Prevention (Feed/Data):** Never execute database queries in a loop over returned rows. Always extract IDs and use bulk `IN` queries (e.g., `GetTagsForPosts(ctx, postIDs)`), then map the results in-memory.
* **Vector Search (Search):** Never pass a zero-vector (`[]float32{0, ...}`) to `pgvector` during hybrid search if embeddings fail, as this distorts lexical fallback scoring. Pass `nil` and handle NULL vectors in the underlying SQL query.
* **Go Channel Safety (Notifications):** When broadcasting to a map of channels (e.g., under an `RLock`), do not `close()` a subscriber's channel when they unsubscribe. Simply delete the channel from the map (`delete(subs, ch)`) to avoid panics on concurrent sends.
* **Offline Syncing (Sync/Client):** Do not fire individual REST requests (e.g., per-keystroke) to sync offline-first data. Batch offline mutations locally and send them via a dedicated bulk `/sync/push` endpoint. The protocol MUST implement BOTH pull (`GET /sync`) and push (`POST /sync/push`). Server sequence must ALWAYS be server-assigned via `nextval('global_sequence')`, never by the client.
* **Admin Role Guard (Security):** All admin routes must be grouped in an `/admin` route group and guarded with `middleware.RequireRole("super_admin")`. Never mount admin handlers to the standard `protected` group.

### Chat & DM Architecture Invariants (Decommissioned)
* **Decommissioned from Scope:** Direct messaging, chat, and conversation polling have been shut down and removed from the active project scope. No background polling or sync routines may call conversation or DM endpoints.

### Feed & List Performance Invariants
* **N+1 Query Prevention (UI/Backend):** Never fetch metadata (like reaction counts or comment counts) per item when displaying lists or feeds. The backend must aggregate these counts using `LEFT JOIN` or subqueries directly in PostgreSQL and return them in the main JSON payload (`amenCount`, `commentCount`). The Flutter UI must consume these directly without firing separate HTTP requests.
* **Image Caching & Decoding (UI):** Never use `Image.network` in scrollable lists (like feeds or explore grids). Always use `cached_network_image` to handle offline caching and memory management. You must specify a `memCacheWidth` (e.g., `800`) to force the decoder to downsize the image in memory before painting, avoiding UI-thread jank.
* **Scroll Listener Isolation (Zero Page Rebuilds):** Never call `setState()` inside a `NotificationListener<UserScrollNotification>` on the parent screen to toggle FAB/bottom-nav visibility. Use a dedicated `ValueNotifier<bool>` with `ValueListenableBuilder` to isolate updates to leaf widgets and prevent rebuilding the entire viewport during active scroll flings.
* **Granular Riverpod Selectors in Lists:** Never watch global collection providers (e.g., `savedPostsProvider`) directly inside scrollable item cards without `.select()`. Always use `ref.watch(provider.select((list) => list.contains(item.id)))` to ensure a card only rebuilds when its own state changes.
* **Prohibit Per-Card Tickers:** Never wrap full feed post cards in heavy custom animation controllers (e.g., `ScribesBounceButton` with per-item `TickerProviderStateMixin`). Use lightweight native gesture detection (`InkWell` or raw `GestureDetector`) on list cards and reserve animation controllers for small, isolated action buttons.
* **Viewport Pre-Rasterization:** Always configure `cacheExtent` (e.g., `1500`) on `CustomScrollView` / `SliverList` in feed and explore screens so off-screen text and images are pre-decoded before entering the user's viewport.
* **Hybrid Magazine Feed Card Layout:** Feed post cards must follow the standard vertical hierarchy: Author Header -> Cover Image (16:9 with gradient scrim & floating badges, or collapsed if no image) -> Title & Excerpt -> Scripture Tags -> ScribesOrnamentDivider -> Compact Multi-Reaction Row.

### Local-First & Offline Invariants
* **Guest Offline Creation:** Notes, drafts, and notebooks must support full offline creation by unauthenticated users. If no authenticated user ID exists, the client must resolve a persistent device-level guest ID via `SecureStorage.getOrCreateGuestId()`. Never silently discard writes due to `userId == null`.
* **Transactional Account Claiming (Re-parenting):** When an unauthenticated user subsequently registers or logs in, the client MUST execute an atomic Drift transaction to re-parent all local notes, drafts, and notebooks from the guest ID to the new user ID (`is_synced = false`) before initiating cloud sync.
* **Logout Data Preservation:** Never unconditionally wipe local unsynced offline data on logout. `clearAllData()` must default to `preserveUnsynced: true` so that uncommitted guest notes and drafts remain intact across auth state transitions.

### Scripture & Bible Feature Invariants
* **Public Scripture Endpoints:** All `/bible/*` GET endpoints (`/bible/books`, `/bible/:book/:chapter`, `/bible/:book/:chapter/:verseRange`, `/bible/search`) must remain strictly public without requiring an `Authorization` header. Only personal reading position endpoints are protected.
* **Inline Scripture Expansion:** `ScribesScriptureChip` must expand inline to show verse text and context. Never open a modal bottom sheet or route to a new screen for verse previews.
* **Self-Hosted Scripture Read Path:** Verse text must always be queried from the local PostgreSQL `bible_verses` table (BSB in v1). Never introduce a runtime network dependency on third-party Bible APIs in the read path.
* **Attribution Guarantee:** Wherever scripture verse text is rendered (in-app previews, Bible drawer, and exported PDFs/images), the translation attribution caption (e.g., "Berean Standard Bible, public domain") must be visibly displayed.

### Social & Recommendation Invariants
* **Distinct Recommendation Seeds (Reactions):** Reaction types (`amen`, `insightful`, `thought_provoking`) must NEVER be collapsed or aggregated into a single generic "like" counter in UI components or API payloads. They must remain individually accessible, interactive, and distinct across all feed cards, post tiles, and detail views to preserve telemetry for recommendation materialized views and Discover tab carousels.

### Document Export & Post Type Invariants
* **Standard Post Exclusivity (Export):** The illuminated PDF manuscript export pipeline is strictly reserved for `standard` posts, standard drafts, and study notes. Never render or trigger the "Export Manuscript (PDF)" option for `passage` (multi-panel interactive deck) or `reflection` (500-character contemplation) post types.


