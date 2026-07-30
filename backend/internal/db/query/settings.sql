-- name: GetNotificationPreferences :one
SELECT * FROM notification_preferences
WHERE user_id = $1 LIMIT 1;

-- name: UpsertNotificationPreferences :one
INSERT INTO notification_preferences (
    user_id, push_enabled, email_enabled, dm_alerts, new_follower_alerts
) VALUES (
    $1, $2, $3, $4, $5
)
ON CONFLICT (user_id) DO UPDATE SET
    push_enabled = EXCLUDED.push_enabled,
    email_enabled = EXCLUDED.email_enabled,
    dm_alerts = EXCLUDED.dm_alerts,
    new_follower_alerts = EXCLUDED.new_follower_alerts,
    updated_at = CURRENT_TIMESTAMP
RETURNING *;
