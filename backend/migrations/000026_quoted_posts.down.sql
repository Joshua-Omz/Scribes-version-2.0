-- MIGRATION 026: Quoted Posts

DROP INDEX IF EXISTS idx_posts_quoted;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS valid_quoted_post_type;
ALTER TABLE posts DROP COLUMN IF EXISTS quoted_post_id;
