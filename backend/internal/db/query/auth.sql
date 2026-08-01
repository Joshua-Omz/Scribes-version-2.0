-- name: CreateUser :one
INSERT INTO users (
    handle,
    display_name,
    email,
    password_hash,
    bio,
    role,
    is_church
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
) RETURNING *;

-- name: GetUserByEmail :one
SELECT 
    users.*,
    (SELECT COUNT(*) FROM follows WHERE followee_id = users.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = users.id)::int AS following_count,
    COALESCE((SELECT array_agg(t.name)::text[] FROM tags t JOIN user_tags ut ON t.id = ut.tag_id WHERE ut.user_id = users.id), '{}')::text[] AS selected_tags
FROM users
WHERE users.email = $1 AND users.is_deleted = false LIMIT 1;

-- name: GetUserByID :one
SELECT 
    users.*,
    (SELECT COUNT(*) FROM follows WHERE followee_id = users.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = users.id)::int AS following_count,
    COALESCE((SELECT array_agg(t.name)::text[] FROM tags t JOIN user_tags ut ON t.id = ut.tag_id WHERE ut.user_id = users.id), '{}')::text[] AS selected_tags
FROM users
WHERE users.id = $1 AND users.is_deleted = false LIMIT 1;

-- name: GetUserByHandle :one
SELECT 
    users.*,
    (SELECT COUNT(*) FROM follows WHERE followee_id = users.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = users.id)::int AS following_count,
    COALESCE((SELECT array_agg(t.name)::text[] FROM tags t JOIN user_tags ut ON t.id = ut.tag_id WHERE ut.user_id = users.id), '{}')::text[] AS selected_tags
FROM users
WHERE users.handle = $1 AND users.is_deleted = false LIMIT 1;

-- name: GetPublicProfile :one
SELECT 
    users.id, users.handle, users.display_name, users.bio,
    (SELECT COUNT(*) FROM follows WHERE followee_id = users.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = users.id)::int AS following_count,
    COALESCE((SELECT array_agg(t.name)::text[] FROM tags t JOIN user_tags ut ON t.id = ut.tag_id WHERE ut.user_id = users.id), '{}')::text[] AS selected_tags
FROM users
WHERE users.id = $1 AND users.is_deleted = false LIMIT 1;

-- name: SearchUsers :many
SELECT 
    users.*,
    (SELECT COUNT(*) FROM follows WHERE followee_id = users.id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = users.id)::int AS following_count,
    COALESCE((SELECT array_agg(t.name)::text[] FROM tags t JOIN user_tags ut ON t.id = ut.tag_id WHERE ut.user_id = users.id), '{}')::text[] AS selected_tags
FROM users
WHERE (users.handle ILIKE $1 || '%' OR users.display_name ILIKE '%' || $1 || '%') AND users.is_deleted = false
ORDER BY handle ASC
LIMIT 10;

-- name: UpdateUserProfile :one
UPDATE users
SET handle = $2, display_name = $3, bio = $4, is_church = $5
WHERE id = $1 AND is_deleted = false
RETURNING *;

-- name: UpdateUserEmail :exec
UPDATE users
SET email = $2
WHERE id = $1 AND is_deleted = false;

-- name: UpdateUserPassword :exec
UPDATE users
SET password_hash = $2
WHERE id = $1 AND is_deleted = false;

-- name: GetUserPasswordHash :one
SELECT password_hash FROM users WHERE id = $1 AND is_deleted = false LIMIT 1;
