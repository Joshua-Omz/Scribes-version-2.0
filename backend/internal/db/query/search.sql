-- name: UpdatePostEmbedding :exec
UPDATE posts SET embedding = $1 WHERE id = $2;

-- name: SearchPostsHybrid :many
WITH keyword_search AS (
    SELECT p.id,
           ts_rank(p.search_vector, websearch_to_tsquery('english', $1)) AS keyword_score,
           RANK() OVER (ORDER BY ts_rank(p.search_vector, websearch_to_tsquery('english', $1)) DESC) as rnk
    FROM posts p
    WHERE p.is_deleted = false AND p.visibility = 'public'
      AND p.search_vector @@ websearch_to_tsquery('english', $1)
    ORDER BY keyword_score DESC
    LIMIT 100
),
semantic_search AS (
    SELECT p.id,
           1 - (p.embedding <=> $2::vector) AS semantic_score,
           RANK() OVER (ORDER BY p.embedding <=> $2::vector) as rnk
    FROM posts p
    WHERE p.is_deleted = false AND p.visibility = 'public'
      AND p.embedding IS NOT NULL
    ORDER BY p.embedding <=> $2::vector
    LIMIT 100
)
SELECT p.id, p.author_id, p.caption, p.content, p.sermon_source, p.visibility, p.is_deleted, p.published_at,
       u.display_name AS author_name, u.handle AS author_handle, u.is_church AS author_is_church,
       COALESCE(k.keyword_score, 0)::float8 AS keyword_score,
       COALESCE(s.semantic_score, 0)::float8 AS semantic_score,
       (COALESCE(1.0 / (60 + k.rnk), 0.0) + COALESCE(1.0 / (60 + s.rnk), 0.0))::float8 AS rrf_score
FROM posts p
JOIN users u ON u.id = p.author_id
LEFT JOIN keyword_search k ON p.id = k.id
LEFT JOIN semantic_search s ON p.id = s.id
WHERE (k.id IS NOT NULL OR s.id IS NOT NULL)
ORDER BY rrf_score DESC
LIMIT $3 OFFSET $4;

-- name: SearchAuthors :many
SELECT u.id, u.handle, u.display_name, u.email, u.bio, u.is_church, u.created_at
FROM users u
WHERE u.display_name ILIKE '%' || $1 || '%' OR u.handle ILIKE '%' || $1 || '%'
ORDER BY u.display_name ASC
LIMIT $2 OFFSET $3;
