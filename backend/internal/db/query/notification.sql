-- name: InsertNotification :one
INSERT INTO notifications (
    recipient_id, type, ref_id, actor_id, is_realtime, is_read, sent_at
) VALUES (
    $1, $2, $3, $4, $5, false,
    CASE WHEN $5 THEN now() ELSE NULL END
)
RETURNING *;

-- name: ListUnreadByUser :many
SELECT n.*, u.handle as actor_handle, CAST(NULL AS TEXT) as actor_avatar 
FROM notifications n
LEFT JOIN users u ON n.actor_id = u.id
WHERE n.recipient_id = $1
  AND n.is_read = false
ORDER BY n.created_at DESC
LIMIT 100;

-- name: ListAllByUser :many
SELECT n.*, u.handle as actor_handle, CAST(NULL AS TEXT) as actor_avatar 
FROM notifications n
LEFT JOIN users u ON n.actor_id = u.id
WHERE n.recipient_id = $1
ORDER BY n.created_at DESC
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
