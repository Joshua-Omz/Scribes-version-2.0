-- name: CreateNote :one
INSERT INTO notes (
    author_id,
    content,
    title,
    notebook_id,
    source_type,
    source_label
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetNoteByID :one
SELECT * FROM notes
WHERE id = $1 LIMIT 1;

-- name: ListNotesByAuthor :many
SELECT * FROM notes
WHERE author_id = $1
ORDER BY created_at DESC;

-- name: UpdateNote :one
UPDATE notes
SET content = $2,
    title = $3,
    notebook_id = $4,
    source_type = $5,
    source_label = $6,
    updated_at = now()
WHERE id = $1 AND author_id = $7
RETURNING *;

-- name: DeleteNote :exec
DELETE FROM notes
WHERE id = $1 AND author_id = $2;
