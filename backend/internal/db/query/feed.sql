-- name: GetFeedPosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
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
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
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
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN follows f ON p.author_id = f.followee_id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND f.follower_id = $1
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;

-- name: GetExplorePostsByTag :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN post_tags pt ON p.id = pt.post_id
JOIN tags t ON pt.tag_id = t.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND t.name = $1
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;

-- name: GetExplorePostsByScripture :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
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
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND p.search_vector @@ websearch_to_tsquery('english', sqlc.arg(search_query)::text)
  AND (p.published_at < $1 OR (p.published_at = $1 AND p.id < $2))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $3;

-- name: GetChurchPosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND u.is_church = true
  AND (p.published_at < $1 OR (p.published_at = $1 AND p.id < $2))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $3;

-- name: GetSuggestedUsers :many
SELECT 
    u.id, u.handle, u.display_name, u.bio, u.is_church, u.avatar_url,
    (SELECT COUNT(*) FROM follows WHERE followee_id = u.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = u.id)::int AS following_count
FROM users u
WHERE u.is_deleted = false
  AND u.id != $1
  AND NOT EXISTS (
      SELECT 1 FROM follows f WHERE f.follower_id = $1 AND f.followee_id = u.id
  )
ORDER BY RANDOM()
LIMIT $2;

-- name: GetForYouPosts :many
SELECT 
    p.id, p.author_id, p.content, p.caption, p.visibility, p.current_version, 
    p.is_correction, p.corrects_post_id, p.sermon_source, p.is_deleted, p.published_at, p.cover_image_url, p.post_type,
    u.handle AS author_handle, u.display_name AS author_name, u.avatar_url AS author_avatar_url,
    (SELECT COUNT(*) FROM reactions r WHERE r.post_id = p.id AND r.type = 'amen')::int AS amen_count,
    (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id)::int AS comment_count
FROM posts p
JOIN users u ON p.author_id = u.id
JOIN post_tags pt ON p.id = pt.post_id
JOIN user_tags ut ON pt.tag_id = ut.tag_id
WHERE p.is_deleted = false 
  AND p.visibility = 'public'
  AND ut.user_id = $1
  AND (p.published_at < $2 OR (p.published_at = $2 AND p.id < $3))
ORDER BY p.published_at DESC, p.id DESC
LIMIT $4;
