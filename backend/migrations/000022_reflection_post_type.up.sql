-- MIGRATION 022: Reflection Post Type & Reflection Image Column

-- Drop dependencies on post_type
ALTER TABLE posts DROP CONSTRAINT IF EXISTS cover_image_standard_only;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS reflection_image_only_on_reflection;
DROP INDEX IF EXISTS idx_posts_type;

-- Recreate post_type enum to include 'reflection' transactionally
ALTER TYPE post_type RENAME TO post_type_old;
CREATE TYPE post_type AS ENUM ('standard', 'passage', 'reflection');
ALTER TABLE posts ALTER COLUMN post_type DROP DEFAULT;
ALTER TABLE posts ALTER COLUMN post_type TYPE post_type USING post_type::text::post_type;
ALTER TABLE posts ALTER COLUMN post_type SET DEFAULT 'standard';
DROP TYPE post_type_old;

-- Recreate dependencies
ALTER TABLE posts
    ADD CONSTRAINT cover_image_standard_only
    CHECK (
        cover_image_url IS NULL
        OR post_type = 'standard'
    );

CREATE INDEX idx_posts_type ON posts (post_type, published_at DESC) WHERE is_deleted = false;

-- Add reflection_image_url column
ALTER TABLE posts
    ADD COLUMN IF NOT EXISTS reflection_image_url TEXT;

-- Constraints: reflection_image_url is strictly for reflection post type
ALTER TABLE posts
    ADD CONSTRAINT reflection_image_only_on_reflection
    CHECK (
        reflection_image_url IS NULL
        OR post_type = 'reflection'
    );
