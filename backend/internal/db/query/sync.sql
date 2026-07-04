-- name: PullSyncEvents :many
SELECT 'note' AS type, id, content, title AS title_or_caption,
       notebook_id AS parent_id, server_sequence, updated_at AS ts
FROM notes
WHERE notes.author_id = $1 AND notes.server_sequence > $2

UNION ALL

SELECT 'draft' AS type, id, content, caption AS title_or_caption,
       NULL::uuid AS parent_id, server_sequence, updated_at AS ts
FROM drafts
WHERE drafts.author_id = $1 AND drafts.server_sequence > $2

UNION ALL

SELECT 'post' AS type, id, content, caption AS title_or_caption,
       corrects_post_id AS parent_id, server_sequence, published_at AS ts
FROM posts
WHERE posts.author_id = $1 AND posts.server_sequence > $2

ORDER BY server_sequence ASC;
