-- ── Follows ────────────────────────────────────

-- name: FollowUser :exec
INSERT INTO follows (follower_id, followee_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: UnfollowUser :exec
DELETE FROM follows
WHERE follower_id = $1 AND followee_id = $2;

-- name: CheckIsFollowing :one
SELECT EXISTS(
    SELECT 1 FROM follows 
    WHERE follower_id = $1 AND followee_id = $2
);


-- ── Reactions ──────────────────────────────────

-- name: UpsertReaction :exec
INSERT INTO reactions (post_id, user_id, type)
VALUES ($1, $2, $3)
ON CONFLICT (post_id, user_id) 
DO UPDATE SET type = EXCLUDED.type, created_at = now();

-- name: DeleteReaction :exec
DELETE FROM reactions
WHERE post_id = $1 AND user_id = $2;

-- name: GetReactionCounts :many
SELECT type, COUNT(*) as count
FROM reactions
WHERE post_id = $1
GROUP BY type;


-- ── Comments ───────────────────────────────────

-- name: CreateComment :one
INSERT INTO comments (post_id, author_id, body, mentions)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: HideComment :exec
UPDATE comments
SET is_hidden = true
WHERE id = $1;

-- name: DeleteComment :exec
UPDATE comments
SET is_deleted = true
WHERE id = $1 AND author_id = $2;

-- name: GetCommentsByPost :many
SELECT *
FROM comments
WHERE post_id = $1 AND is_deleted = false
ORDER BY created_at ASC;

-- name: GetCommentByID :one
SELECT * FROM comments WHERE id = $1;


-- ── Saved ──────────────────────────────────────

-- name: SavePost :exec
INSERT INTO saved (user_id, post_id, type, snapshot)
VALUES ($1, $2, $3, $4)
ON CONFLICT (user_id, post_id, type) 
DO UPDATE SET snapshot = EXCLUDED.snapshot, created_at = now();

-- name: UnsavePost :exec
DELETE FROM saved
WHERE user_id = $1 AND post_id = $2 AND type = $3;

-- name: ListSavedPosts :many
SELECT s.*, p.content, p.caption
FROM saved s
JOIN posts p ON p.id = s.post_id
WHERE s.user_id = $1 AND s.type = $2
ORDER BY s.created_at DESC;
