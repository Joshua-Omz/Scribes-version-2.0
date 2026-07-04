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
INSERT INTO messages (conversation_id, sender_id, body)
VALUES ($1, $2, $3)
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
