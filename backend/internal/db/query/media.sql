-- name: InsertMediaUpload :one
INSERT INTO media_uploads (
    uploader_id,
    url,
    mime_type,
    size_bytes,
    width_px,
    height_px,
    post_id
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetMediaUpload :one
SELECT * FROM media_uploads
WHERE id = $1 LIMIT 1;
