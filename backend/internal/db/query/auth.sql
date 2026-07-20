-- name: CreateUser :one
INSERT INTO users (
    handle,
    display_name,
    email,
    password_hash,
    bio,
    role
) VALUES (
    $1, $2, $3, $4, $5, $6
) RETURNING *;

-- name: GetUserByEmail :one
SELECT 
    *,
    (SELECT COUNT(*) FROM follows WHERE followee_id = id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = id)::int AS following_count
FROM users
WHERE email = $1 AND is_deleted = false LIMIT 1;

-- name: GetUserByID :one
SELECT 
    *,
    (SELECT COUNT(*) FROM follows WHERE followee_id = id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = id)::int AS following_count
FROM users
WHERE id = $1 AND is_deleted = false LIMIT 1;

-- name: GetUserByHandle :one
SELECT 
    *,
    (SELECT COUNT(*) FROM follows WHERE followee_id = id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = id)::int AS following_count
FROM users
WHERE handle = $1 AND is_deleted = false LIMIT 1;

-- name: GetPublicProfile :one
SELECT 
    id, handle, display_name, bio,
    (SELECT COUNT(*) FROM follows WHERE followee_id = id)::int AS followers_count,
    (SELECT COUNT(*) FROM follows WHERE follower_id = id)::int AS following_count
FROM users
WHERE id = $1 AND is_deleted = false LIMIT 1;

-- name: SearchUsersByHandle :many
SELECT id, handle, display_name
FROM users
WHERE handle ILIKE $1 || '%' AND is_deleted = false
ORDER BY handle ASC
LIMIT 10;
