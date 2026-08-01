-- name: GetRecommendationsByType :many
SELECT p.id, p.author_id, p.caption, p.content, p.sermon_source, p.visibility, p.is_deleted, p.published_at,
       u.display_name AS author_name, u.handle AS author_handle, u.is_church AS author_is_church
FROM post_engagement_scores s
JOIN posts p ON p.id = s.post_id
JOIN users u ON u.id = p.author_id
ORDER BY
    CASE WHEN sqlc.arg('sort_type')::text = 'overall' THEN s.overall_ratio END DESC,
    CASE WHEN sqlc.arg('sort_type')::text = 'amen' THEN s.amen_ratio END DESC,
    CASE WHEN sqlc.arg('sort_type')::text = 'insightful' THEN s.insightful_ratio END DESC,
    CASE WHEN sqlc.arg('sort_type')::text = 'thought_provoking' THEN s.tp_ratio END DESC
LIMIT sqlc.arg('limit_count') OFFSET sqlc.arg('offset_count');

-- name: GetSemanticallySimilarPosts :many
SELECT p.id, p.author_id, p.caption, p.content, p.sermon_source, p.visibility, p.is_deleted, p.published_at,
       u.display_name AS author_name, u.handle AS author_handle, u.is_church AS author_is_church
FROM posts p
JOIN users u ON u.id = p.author_id
WHERE p.is_deleted = false AND p.visibility = 'public'
  AND p.id != sqlc.arg('post_id')
  AND p.embedding IS NOT NULL
ORDER BY p.embedding <=> (SELECT embedding FROM posts WHERE id = sqlc.arg('post_id'))
LIMIT sqlc.arg('limit_count');

-- name: RefreshEngagementScores :exec
REFRESH MATERIALIZED VIEW CONCURRENTLY post_engagement_scores;
