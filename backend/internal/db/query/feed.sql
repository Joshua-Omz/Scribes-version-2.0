-- name: GetFeedPosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND (p.published_at < $1 OR (p.published_at = $1 AND p.id < $2))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $3;

-- name: GetExplorePosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND (p.published_at < $1 OR (p.published_at = $1 AND p.id < $2))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $3;

-- name: GetFollowingFeedPosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN follows f ON p.author_id = f.followee_id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND f.follower_id = $1
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;

-- name: GetExplorePostsByCategory :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN post_categories pc ON p.id = pc.post_id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND pc.category_id = $1
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;

-- name: ListCategories :many
SELECT id, name, is_deprecated 
FROM categories
WHERE is_deprecated = false
ORDER BY name ASC;

-- name: GetExplorePostsByScripture :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN scripture_refs sr ON p.id = sr.post_id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND sr.book = $1
  AND (sqlc.arg(chapter)::int = 0 OR sr.chapter = sqlc.arg(chapter))
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;

-- name: SearchExplorePosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at,
    u.handle AS author_handle, u.display_name AS author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND p.search_vector @@ websearch_to_tsquery('english', sqlc.arg(search_query)::text)
  AND (p.published_at < $1 OR (p.published_at = $1 AND p.id < $2))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $3;
