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
SELECT p.*, u.handle AS author_handle, u.display_name AS author_name 
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.id = $1 AND p.is_deleted = false LIMIT 1;

-- name: ListPostsByAuthor :many
SELECT p.*, u.handle AS author_handle, u.display_name AS author_name 
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.author_id = $1 AND p.is_deleted = false
ORDER BY p.published_at DESC;

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

-- name: ClearPostCategories :exec
DELETE FROM post_categories
WHERE post_id = $1;

-- name: AddPostCategory :exec
INSERT INTO post_categories (post_id, category_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: GetPostCategories :many
SELECT category_id FROM post_categories
WHERE post_id = $1;

-- name: AddScriptureRef :exec
INSERT INTO scripture_refs (post_id, book, chapter, verse_start, verse_end)
VALUES ($1, $2, $3, $4, $5);

-- name: ClearScriptureRefs :exec
DELETE FROM scripture_refs
WHERE post_id = $1;

-- name: GetScriptureRefs :many
SELECT book, chapter, verse_start, verse_end 
FROM scripture_refs 
WHERE post_id = $1
ORDER BY id ASC;
