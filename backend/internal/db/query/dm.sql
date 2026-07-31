-- ── Message Requests ───────────────────────────

-- name: CreateMessageRequest :one
INSERT INTO message_requests (from_user_id, to_user_id, first_message)
VALUES ($1, $2, $3)
RETURNING *;

-- name: UpdateMessageRequestStatus :exec
UPDATE message_requests
SET status = $2
WHERE id = $1;

-- name: GetPendingRequestsForUser :many
SELECT * FROM message_requests
WHERE to_user_id = $1 AND status = 'pending'
ORDER BY created_at DESC;

-- name: GetMessageRequestByID :one
SELECT * FROM message_requests
WHERE id = $1;

-- ── Conversations ──────────────────────────────

-- name: CreateConversation :one
INSERT INTO conversations (user_a_id, user_b_id)
VALUES ($1, $2)
RETURNING *;

-- name: GetConversationsForUser :many
SELECT * FROM conversations
WHERE user_a_id = $1 OR user_b_id = $1
ORDER BY last_active DESC;

-- name: GetConversationByID :one
SELECT * FROM conversations
WHERE id = $1;

-- name: BlockConversation :exec
UPDATE conversations
SET blocked = true
WHERE id = $1;

-- ── Messages ───────────────────────────────────

-- name: CreateMessage :one
INSERT INTO messages (conversation_id, sender_id, body, reply_to_id)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetMessagesForConversation :many
SELECT * FROM messages
WHERE conversation_id = sqlc.arg(conversation_id)::uuid
  AND sent_at < sqlc.arg(cursor_ts)::timestamptz
ORDER BY sent_at DESC
LIMIT sqlc.arg(limit_count)::int;

-- name: SoftDeleteMessage :exec
UPDATE messages
SET is_deleted = true
WHERE id = $1 AND sender_id = $2;

-- name: UpdateMessage :one
UPDATE messages
SET body = $3, edited_at = now()
WHERE id = $1 AND sender_id = $2 AND is_deleted = false
RETURNING *;

-- name: SearchContacts :many
SELECT DISTINCT u.id, u.handle, u.display_name
FROM users u
LEFT JOIN conversations c ON (c.user_a_id = $1 AND c.user_b_id = u.id) OR (c.user_b_id = $1 AND c.user_a_id = u.id)
LEFT JOIN follows f1 ON f1.follower_id = $1 AND f1.followee_id = u.id
LEFT JOIN follows f2 ON f2.follower_id = u.id AND f2.followee_id = $1
WHERE u.id != $1
  AND (
    c.id IS NOT NULL 
    OR (f1.created_at IS NOT NULL AND f2.created_at IS NOT NULL)
  )
  AND (u.handle ILIKE '%' || $2 || '%' OR u.display_name ILIKE '%' || $2 || '%')
LIMIT 20;

-- name: GetConversationByUsers :one
SELECT * FROM conversations
WHERE (user_a_id = $1 AND user_b_id = $2)
   OR (user_a_id = $2 AND user_b_id = $1);
