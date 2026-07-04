-- name: GetFollowingFeed :many
SELECT p.* 
FROM posts p
JOIN follows f ON p.author_id = f.followee_id
WHERE f.follower_id = sqlc.arg(follower_id)::uuid 
  AND p.is_deleted = false 
  AND p.visibility = 'public'
  AND (p.published_at, p.id) < (sqlc.arg(cursor_ts)::timestamptz, sqlc.arg(cursor_id)::uuid)
ORDER BY p.published_at DESC, p.id DESC
LIMIT sqlc.arg(limit_count)::int;

-- name: GetExploreFeed :many
SELECT
  p.id,
  p.author_id,
  p.content,
  p.caption,
  p.published_at,
  (
    SELECT COUNT(*) FROM reactions r
    WHERE r.post_id = p.id
    AND r.created_at > now() - INTERVAL '90 days'
  ) +
  (
    SELECT COUNT(*) FROM comments c
    WHERE c.post_id = p.id
    AND c.is_deleted = false
    AND c.created_at > now() - INTERVAL '90 days'
  ) AS interaction_score
FROM posts p
JOIN post_categories pc ON pc.post_id = p.id
WHERE pc.category_id = ANY(sqlc.arg(category_ids)::uuid[])
  AND p.is_deleted = false
  AND p.visibility = 'public'
ORDER BY interaction_score DESC, p.published_at DESC
LIMIT sqlc.arg(limit_count)::int;

-- name: GetUserOnboardingCategories :many
SELECT category_id 
FROM user_onboarding_categories 
WHERE user_id = $1;
