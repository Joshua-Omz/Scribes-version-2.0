-- name: ListActiveSounds :many
SELECT * FROM sound_pool
WHERE is_active = true
ORDER BY category, title;

-- name: GetSoundByID :one
SELECT * FROM sound_pool
WHERE id = $1 LIMIT 1;
