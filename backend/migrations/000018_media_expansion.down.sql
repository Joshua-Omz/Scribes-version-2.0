DROP TABLE IF EXISTS media_uploads;
DROP INDEX IF EXISTS idx_posts_type;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS cover_image_standard_only;
ALTER TABLE posts DROP COLUMN IF EXISTS cover_image_url;
ALTER TABLE posts DROP COLUMN IF EXISTS post_type;
DROP TYPE IF EXISTS post_type;
