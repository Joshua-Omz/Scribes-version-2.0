-- name: CreateDraft :one
INSERT INTO drafts (
    author_id,
    content,
    caption,
    sermon_source
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: GetDraftByID :one
SELECT * FROM drafts
WHERE id = $1 LIMIT 1;

-- name: ListDraftsByAuthor :many
SELECT * FROM drafts
WHERE author_id = $1
ORDER BY created_at DESC;

-- name: UpdateDraft :one
UPDATE drafts
SET content = $2,
    caption = $3,
    sermon_source = $4,
    updated_at = now()
WHERE id = $1 AND author_id = $5
RETURNING *;

-- name: DeleteDraft :exec
DELETE FROM drafts
WHERE id = $1 AND author_id = $2;

-- name: UpsertDraft :one
INSERT INTO drafts (id, author_id, content, caption, sermon_source)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (id) DO UPDATE
SET content = EXCLUDED.content,
    caption = EXCLUDED.caption,
    sermon_source = EXCLUDED.sermon_source,
    updated_at = now()
WHERE drafts.author_id = $2
RETURNING *;
