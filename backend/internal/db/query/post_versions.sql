-- name: CreatePostVersion :one
INSERT INTO post_versions (
    post_id,
    version_number,
    content_snapshot,
    snapshotted_by
) VALUES (
    $1, $2, $3, $4
) RETURNING *;

-- name: ListVersionsByPost :many
SELECT * FROM post_versions
WHERE post_id = $1
ORDER BY version_number ASC;

-- name: GetVersionByPostAndNumber :one
SELECT * FROM post_versions
WHERE post_id = $1 AND version_number = $2
LIMIT 1;
