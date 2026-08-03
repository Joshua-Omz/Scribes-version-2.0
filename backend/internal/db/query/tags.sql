-- name: SuggestTags :many
SELECT * FROM tags
WHERE name % $1
ORDER BY post_count DESC
LIMIT $2;

-- name: GetTrendingTags :many
SELECT * FROM tags
WHERE last_used_at > now() - INTERVAL '30 days'
ORDER BY post_count DESC, last_used_at DESC
LIMIT $1;

-- name: UpsertTag :one
SELECT upsert_tag($1, $2) AS tag_id;

-- name: AddPostTag :exec
INSERT INTO post_tags (post_id, tag_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: GetPostTags :many
SELECT t.display_name FROM tags t
JOIN post_tags pt ON pt.tag_id = t.id
WHERE pt.post_id = $1;

-- name: ClearUserTags :exec
DELETE FROM user_tags WHERE user_id = $1;

-- name: AddUserTag :exec
INSERT INTO user_tags (user_id, tag_id) VALUES ($1, $2) ON CONFLICT DO NOTHING;

-- name: GetPostTagsForPosts :many
SELECT pt.post_id, t.display_name FROM tags t
JOIN post_tags pt ON pt.tag_id = t.id
WHERE pt.post_id = ANY($1::uuid[]);
