# Scribes — Notification Feature Implementation Contract
**Version 1.0 · Backend + Frontend · Sprint 8**

> This document is the single source of truth for the notification feature across both the backend and the Flutter client. It defines the complete contract between the two layers — what the backend produces, what the frontend consumes, how the worker operates, and what the UI must render. A contributor implementing either side reads this document first and treats it as the authority. Where this document conflicts with general project documentation, flag the conflict — do not silently resolve it.

---

## 1. Feature Boundary

The notification feature covers exactly this scope:

**In scope:**
- Two-path delivery system (real-time and batched digest)
- Storing notification records in the database
- The `GET /notifications` endpoint
- The goroutine worker that dispatches events
- The Flutter notification centre screen
- The gold dot badge on the Feed header bell icon
- Grouping logic for batched notifications
- Read/unread state management

**Out of scope (v1):**
- Push notifications (APNs / FCM) — in-app polling only in v1
- Email digest notifications
- Notification preferences per-type (the toggle exists in Settings UI but the backend endpoint is deferred — see §10)
- WebSocket real-time push to the client — polling on screen open is the v1 mechanism

---

## 2. The Two Delivery Paths

This is the core architectural decision of the notification feature. Every notification belongs to exactly one of two paths determined by its type.

```
Event fires in a handler
        │
        ▼
notification.Service.Enqueue(event)
        │
        ▼ (non-blocking channel write)
Worker dispatch loop reads channel
        │
        ├─── is_realtime = true ──▶ sendRealtime()
        │    (mention, admin_alert)   Write to DB immediately
        │                             sent_at = now()
        │
        └─── is_realtime = false ──▶ enqueueBatch()
             (reaction, comment,       Write to DB with sent_at = NULL
              follow)                  Accumulate until flushBatch()
                                       flushBatch() runs every 15 minutes
                                       Sets sent_at = now() on flush
```

**Why this split exists:** Mentions and admin alerts require the user to see them immediately — a user @mentioned in a comment needs to know now. Reactions, comments, and follows do not require immediacy. Batching them reduces noise and aligns with the platform's deliberate resistance to anxiety-inducing real-time engagement metrics.

**The client does not know which path delivered a notification.** It only sees the stored record. The `is_realtime` field exists in the DB for the worker's internal routing — the Flutter client uses it only to apply the visual left-border distinction between real-time-origin and batched-origin items.

---

## 3. Database Contract

### Table: `notifications`

```sql
CREATE TYPE notif_type AS ENUM (
    'mention',       -- is_realtime = true
    'reaction',      -- is_realtime = false
    'comment',       -- is_realtime = false
    'follow',        -- is_realtime = false
    'admin_alert'    -- is_realtime = true
);

CREATE TABLE notifications (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type         notif_type  NOT NULL,
    ref_id       UUID        NOT NULL,       -- polymorphic — see §4
    is_realtime  BOOLEAN     NOT NULL,
    is_read      BOOLEAN     NOT NULL DEFAULT false,
    sent_at      TIMESTAMPTZ,                -- NULL = not yet sent (batch pending)
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_recipient
    ON notifications (recipient_id, created_at DESC)
    WHERE is_read = false;

CREATE INDEX idx_notifications_unsent
    ON notifications (is_realtime, sent_at)
    WHERE sent_at IS NULL;
```

### The `ref_id` polymorphic field

`ref_id` points to different tables depending on `type`. The mapping is:

| `type` | `ref_id` points to | Used by client to |
|---|---|---|
| `mention` | `comments.id` | Navigate to the comment's post |
| `reaction` | `posts.id` | Navigate to the post |
| `comment` | `posts.id` | Navigate to the post |
| `follow` | `users.id` | Navigate to the follower's profile |
| `admin_alert` | `reports.id` or `posts.id` | Navigate to the flagged content |

This is resolved at the service layer — the repository returns the raw `ref_id` UUID and the service enriches it based on `type` before the handler returns the response.

---

## 4. Backend Implementation Contract

### 4.1 — Package structure

```
internal/notification/
├── handler.go      — HTTP handler for GET /notifications
├── service.go      — Enqueue · dispatch routing · enrichment
├── worker.go       — goroutine worker · channel · flush scheduler
├── repository.go   — DB reads/writes
└── model.go        — domain types
```

### 4.2 — Domain model

```go
// internal/notification/model.go

type NotifType string

const (
    NotifTypeMention    NotifType = "mention"
    NotifTypeReaction   NotifType = "reaction"
    NotifTypeComment    NotifType = "comment"
    NotifTypeFollow     NotifType = "follow"
    NotifTypeAdminAlert NotifType = "admin_alert"
)

// Event is what handlers enqueue — internal to the worker pipeline
type Event struct {
    Type        NotifType
    RecipientID uuid.UUID
    RefID       uuid.UUID
    IsRealtime  bool
    ActorID     uuid.UUID  // the user who triggered the event — for body text generation
}

// Notification is the domain type returned to the client
type Notification struct {
    ID          uuid.UUID
    Type        NotifType
    IsRealtime  bool
    IsRead      bool
    Body        string     // generated server-side — see §4.5
    RefID       uuid.UUID
    ActorHandle string     // resolved from ActorID
    ActorAvatar string
    CreatedAt   time.Time
}

// NotificationGroup represents grouped batched notifications
// e.g. "Sarah and 4 others reacted to your post 'On Suffering'"
type NotificationGroup struct {
    Type        NotifType
    IsRealtime  bool
    Body        string
    RefID       uuid.UUID
    Count       int
    CreatedAt   time.Time  // most recent in group
}
```

### 4.3 — Service interface

```go
// internal/notification/service.go

type Service struct {
    repo   *Repository
    worker *Worker
}

func NewService(repo *Repository, worker *Worker) *Service

// Enqueue is called by all other feature handlers.
// It is non-blocking — it writes to the worker's buffered channel.
// If the channel is full, the event is dropped and logged.
// This must never block a handler's response.
func (s *Service) Enqueue(event Event)

// GetForUser returns enriched, grouped notifications for a user.
// Grouped: multiple actors on the same ref within 24h are collapsed.
func (s *Service) GetForUser(ctx context.Context, userID uuid.UUID) ([]NotificationGroup, error)

// MarkAllRead sets is_read = true for all of a user's notifications.
func (s *Service) MarkAllRead(ctx context.Context, userID uuid.UUID) error

// HasUnread returns true if the user has any unread notification.
// Used by the Feed header to determine whether to show the gold dot.
func (s *Service) HasUnread(ctx context.Context, userID uuid.UUID) (bool, error)
```

### 4.4 — Worker contract

```go
// internal/notification/worker.go

type Worker struct {
    channel chan Event          // buffered — size 256
    repo    *Repository
    ticker  *time.Ticker       // 15-minute flush interval
}

func NewWorker(repo *Repository) *Worker

// Start begins the dispatch loop. Must be called with a context
// that is cancelled on SIGTERM/SIGINT. Blocks until context is done.
func (w *Worker) Start(ctx context.Context)

// Enqueue writes an event to the channel without blocking.
// Called by Service.Enqueue only — never called directly by handlers.
func (w *Worker) Enqueue(event Event)
```

**Worker internal logic:**

```
Start(ctx):
  go w.flushLoop(ctx)     // 15-min ticker for batch flush
  for {
    select {
    case event := <-w.channel:
      if event.IsRealtime {
        w.sendRealtime(event)
      } else {
        w.persistBatch(event)
      }
    case <-ctx.Done():
      w.flushBatch()       // drain remaining batch on shutdown
      return
    }
  }
```

**`sendRealtime(event)`:**
1. INSERT into `notifications` with `is_realtime = true`, `sent_at = now()`
2. In v1 — nothing further. The client polls. In v2 this becomes a WebSocket push.

**`persistBatch(event)`:**
1. INSERT into `notifications` with `is_realtime = false`, `sent_at = NULL`

**`flushBatch()`:**
1. UPDATE `notifications` SET `sent_at = now()` WHERE `sent_at IS NULL`
2. This marks them as available to the client on next poll

### 4.5 — Body text generation

Notification body text is generated server-side in the service layer — never on the client. The client renders whatever string it receives.

| Type | Body pattern | Example |
|---|---|---|
| `mention` | `"{actor} mentioned you in a response"` | "Sarah mentioned you in a response" |
| `reaction` (single) | `"{actor} reacted {reaction_type} to your post '{post_title}'"` | "Samuel reacted Amen to your post 'On Suffering'" |
| `reaction` (grouped) | `"{actor} and {N} others reacted to your post '{post_title}'"` | "Samuel and 4 others reacted to your post 'On Suffering'" |
| `comment` (single) | `"{actor} commented on your post '{post_title}'"` | "Grace commented on your post 'Romans 8'" |
| `comment` (grouped) | `"{actor} and {N} others commented on your post '{post_title}'"` | "Grace and 2 others commented on your post 'Romans 8'" |
| `follow` | `"{actor} started following you"` | "Daniel started following you" |
| `admin_alert` | `"An admin has reviewed content you reported"` or `"Your post '{post_title}' has been reviewed"` | — |

**Grouping rule:** Notifications of the same `type` and `ref_id` created within a 24-hour window by different actors are collapsed into a single `NotificationGroup`. The most recent actor is named, the count includes all actors in the window.

### 4.6 — Repository contract

```go
// internal/notification/repository.go

type Repository struct { q *generated.Queries }

func NewRepository(q *generated.Queries) *Repository

func (r *Repository) Insert(ctx context.Context, event Event) error
func (r *Repository) ListUnread(ctx context.Context, userID uuid.UUID) ([]generated.Notification, error)
func (r *Repository) MarkAllRead(ctx context.Context, userID uuid.UUID) error
func (r *Repository) FlushBatch(ctx context.Context) error  // sets sent_at on all pending batch items
func (r *Repository) HasUnread(ctx context.Context, userID uuid.UUID) (bool, error)
```

### 4.7 — HTTP handler contract

**`GET /notifications`**

```
Auth:     JWT required (PROTECTED)
Method:   GET
Path:     /notifications
Query:    none in v1 (pagination deferred)

Response 200:
{
  "notifications": [
    {
      "id":           "uuid",
      "type":         "reaction",
      "is_realtime":  false,
      "is_read":      false,
      "body":         "Samuel and 4 others reacted to your post 'On Suffering'",
      "ref_id":       "uuid",
      "actor_handle": "samuel.o",
      "actor_avatar": "url or null",
      "created_at":   "2025-06-14T20:00:00Z"
    }
  ],
  "has_unread": true
}

Response 401: no or invalid JWT
```

**`POST /notifications/read-all`** (companion endpoint, also Sprint 8)

```
Auth:     JWT required
Method:   POST
Path:     /notifications/read-all
Body:     none

Response 200: { "message": "ok" }
Response 401: no or invalid JWT
```

### 4.8 — Integration with other handlers

Every handler that creates a social event must call `notification.Service.Enqueue()`. This is a non-blocking call — it must never slow down the handler's response.

| Handler method | Event type | `ref_id` | `is_realtime` |
|---|---|---|---|
| `social.Handler.AddComment` | `mention` (for each @mention parsed) | `comments.id` | `true` |
| `social.Handler.AddComment` | `comment` (for post author) | `posts.id` | `false` |
| `social.Handler.React` | `reaction` (for post author) | `posts.id` | `false` |
| `social.Handler.Follow` | `follow` (for followee) | `users.id` (follower) | `false` |
| `admin.Handler.Action` | `admin_alert` | `reports.id` or `posts.id` | `true` |

**Wiring in `main.go`:**

```go
notifRepo   := notification.NewRepository(queries)
notifWorker := notification.NewWorker(notifRepo)
notifSvc    := notification.NewService(notifRepo, notifWorker)

// Start worker before server
go notifWorker.Start(ctx)

// Inject notifSvc into all social handlers
socialSvc := social.NewService(socialRepo, notifSvc)
adminSvc  := admin.NewService(adminRepo, notifSvc)
```

---

## 5. Frontend Implementation Contract

### 5.1 — Package structure

```
lib/features/notification/
├── data/
│   ├── notification_api.dart        — raw dio calls
│   └── notification_repository.dart — domain mapping + grouping display logic
├── domain/
│   └── notification_model.dart      — Notification, NotificationGroup models
├── application/
│   └── notification_provider.dart   — AsyncNotifier
└── presentation/
    ├── notification_screen.dart      — the full screen
    ├── notification_row.dart         — single row widget
    └── notification_badge.dart       — the gold dot widget used in Feed header
```

### 5.2 — Domain model (Dart)

```dart
// lib/features/notification/domain/notification_model.dart

enum NotifType {
  mention,
  reaction,
  comment,
  follow,
  adminAlert,
}

class NotificationItem {
  final String id;
  final NotifType type;
  final bool isRealtime;
  final bool isRead;
  final String body;         // pre-generated by backend
  final String refId;
  final String? actorHandle;
  final String? actorAvatar;
  final DateTime createdAt;

  const NotificationItem({...});

  // Whether to show the gold left-border accent
  // Real-time origin items get the border treatment
  bool get showRealtimeAccent => isRealtime;
}
```

### 5.3 — Riverpod provider contract

```dart
// lib/features/notification/application/notification_provider.dart

@riverpod
class NotificationNotifier extends _$NotificationNotifier {

  @override
  Future<List<NotificationItem>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    return repo.getNotifications();
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllRead();
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Separate lightweight provider for the badge dot
// Polled on Feed screen open — does not fetch full list
@riverpod
Future<bool> hasUnreadNotifications(HasUnreadNotificationsRef ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.hasUnread();
}
```

**Polling strategy (v1):** The notification screen calls `GET /notifications` on screen open and on pull-to-refresh. The gold dot on the Feed header is checked by `hasUnreadNotifications` when the Feed screen builds. There is no background polling timer in v1 — this is intentional. Push in v2.

### 5.4 — Screen layout contract

The notification screen layout follows the Stitch prompt specification with these technical requirements:

**Time grouping:** Notifications are grouped into three sections: TODAY · THIS WEEK · EARLIER. Grouping is done client-side based on `created_at`. The server returns a flat list ordered by `created_at DESC`.

```dart
// Grouping logic in notification_repository.dart
Map<String, List<NotificationItem>> groupByTime(List<NotificationItem> items) {
  final now = DateTime.now();
  final today    = items.where((n) => n.createdAt.isAfter(now.subtract(const Duration(days: 1)))).toList();
  final thisWeek = items.where((n) => n.createdAt.isAfter(now.subtract(const Duration(days: 7))) && !today.contains(n)).toList();
  final earlier  = items.where((n) => !today.contains(n) && !thisWeek.contains(n)).toList();
  return {'TODAY': today, 'THIS WEEK': thisWeek, 'EARLIER': earlier};
}
```

**Tap navigation:** Each notification row navigates on tap. The destination is determined by `type` and `ref_id`:

| Type | Navigation destination |
|---|---|
| `mention` | `PostDetailScreen` (the comment's post, auto-scrolled to comments section) |
| `reaction` | `PostDetailScreen` (the reacted post) |
| `comment` | `PostDetailScreen` (the commented post) |
| `follow` | `ProfileScreen` (the follower's public profile) |
| `admin_alert` | Admin detail (out of scope for standard users in v1) |

### 5.5 — `NotificationRow` widget contract

```dart
// lib/features/notification/presentation/notification_row.dart

class NotificationRow extends StatelessWidget {
  final NotificationItem notification;

  // Layout:
  // [avatar 36px] [body text + timestamp right-aligned]
  // If showRealtimeAccent: 2px left border in goldMuted token
  // If !isRead: small gold dot 8px left of avatar
  // Unread dot disappears after MarkAllRead or after visiting screen

  // Tap: navigate based on type + ref_id (see §5.4)
  // No swipe-to-delete in v1
  // No inline action buttons — navigation only
}
```

### 5.6 — `NotificationBadge` widget contract

```dart
// lib/features/notification/presentation/notification_badge.dart

// Used in the Feed header alongside the bell icon
// Watches hasUnreadNotificationsProvider
// Renders: a 8px gold dot overlaid on the bell icon
// Absent entirely when has_unread = false
// Never shows a number — only present/absent
// Refreshes when the user returns from the Notification screen
//   via ref.invalidate(hasUnreadNotificationsProvider)

class NotificationBadge extends ConsumerWidget {
  final Widget child; // the bell icon widget

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);
    return Stack(
      children: [
        child,
        if (hasUnread.valueOrNull == true)
          Positioned(
            top: 0, right: 0,
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: ScribesColors.of(context).gold,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 6. The sqlc Query Contract

```sql
-- internal/db/query/notifications.sql

-- name: InsertNotification :one
INSERT INTO notifications (
    recipient_id, type, ref_id, is_realtime, is_read, sent_at
) VALUES (
    $1, $2, $3, $4, false,
    CASE WHEN $4 THEN now() ELSE NULL END  -- sent_at = now() if realtime, NULL if batch
)
RETURNING *;

-- name: ListUnreadByUser :many
SELECT * FROM notifications
WHERE recipient_id = $1
  AND is_read = false
ORDER BY created_at DESC
LIMIT 100;

-- name: ListAllByUser :many
SELECT * FROM notifications
WHERE recipient_id = $1
ORDER BY created_at DESC
LIMIT 100;

-- name: MarkAllReadByUser :exec
UPDATE notifications
SET is_read = true
WHERE recipient_id = $1
  AND is_read = false;

-- name: FlushPendingBatch :exec
UPDATE notifications
SET sent_at = now()
WHERE sent_at IS NULL
  AND is_realtime = false;

-- name: HasUnread :one
SELECT EXISTS (
    SELECT 1 FROM notifications
    WHERE recipient_id = $1
      AND is_read = false
      AND sent_at IS NOT NULL
) AS has_unread;
```

---

## 7. Error Handling Contract

Both backend and frontend follow consistent error handling for notifications.

### Backend errors

| Scenario | Behaviour |
|---|---|
| Worker channel full (256 events backed up) | Drop the event, log with `slog.Warn` — never block the handler |
| DB write fails in `sendRealtime` | Log with `slog.Error`, do not retry in v1, do not crash the worker |
| DB write fails in `persistBatch` | Log with `slog.Error`, continue processing next event |
| `flushBatch` fails | Log with `slog.Error`, worker continues running, retry on next 15-min tick |
| Worker `Start` called without a context | P