-- name: CreatePassagePanel :one
INSERT INTO passage_panels (
    post_id,
    panel_order,
    panel_type,
    content,
    background_image_url,
    scripture_ref
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: ListPassagePanelsByPostID :many
SELECT * FROM passage_panels
WHERE post_id = $1
ORDER BY panel_order ASC;
