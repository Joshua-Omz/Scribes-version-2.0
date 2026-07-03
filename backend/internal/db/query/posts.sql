-- name: CreatePost :one
INSERT INTO posts (
    author_id,
    content,
    caption,
    visibility,
    sermon_source
) VALUES (
    $1, $2, $3, $4, $5
) RETURNING *;

-- name: GetPostByID :one
SELECT * FROM posts
WHERE id = $1 AND is_deleted = false LIMIT 1;

-- name: ListPostsByAuthor :many
SELECT * FROM posts
WHERE author_id = $1 AND is_deleted = false
ORDER BY published_at DESC;

-- name: UpdatePost :one
UPDATE posts
SET content = $2,
    caption = $3,
    visibility = $4,
    sermon_source = $5,
    current_version = $6
WHERE id = $1 AND author_id = $7 AND is_deleted = false
RETURNING *;

-- name: DeletePost :exec
UPDATE posts
SET is_deleted = true
WHERE id = $1 AND author_id = $2;

-- name: RevisePost :one
UPDATE posts
SET content = $2,
    caption = $3,
    current_version = current_version + 1
WHERE id = $1 AND author_id = $4 AND is_deleted = false
RETURNING *;

-- name: CreateCorrectionPost :one
INSERT INTO posts (
    author_id,
    content,
    caption,
    visibility,
    sermon_source,
    is_correction,
    corrects_post_id
) VALUES (
    $1, $2, $3, $4, $5, true, $6
) RETURNING *;
