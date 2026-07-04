-- name: CreateReport :one
INSERT INTO reports (reporter_id, content_type, content_id, reason)
VALUES ($1, $2, $3, $4)
RETURNING *;

-- name: GetPendingReports :many
SELECT * FROM reports
WHERE status = 'pending'
ORDER BY created_at ASC
LIMIT 100;

-- name: UpdateReportStatus :exec
UPDATE reports
SET status = $2, reviewed_by = $3, reviewed_at = now()
WHERE id = $1;
