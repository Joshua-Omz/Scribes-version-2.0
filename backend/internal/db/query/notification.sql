-- name: CreateNotification :one
INSERT INTO notifications (recipient_id, type, ref_id, is_realtime)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetUnreadNotificationsForUser :many
SELECT * FROM notifications
WHERE recipient_id = $1 AND is_read = false
ORDER BY created_at DESC
LIMIT 50;

-- name: MarkNotificationAsRead :exec
UPDATE notifications
SET is_read = true
WHERE id = $1 AND recipient_id = $2;

-- name: GetUnsentBatchedNotifications :many
SELECT * FROM notifications
WHERE is_realtime = false AND sent_at IS NULL
ORDER BY created_at ASC
LIMIT 1000;

-- name: MarkNotificationsAsSent :exec
UPDATE notifications
SET sent_at = now()
WHERE id = ANY($1::uuid[]);
