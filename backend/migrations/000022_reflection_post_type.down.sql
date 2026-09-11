ALTER TABLE posts DROP CONSTRAINT IF EXISTS reflection_image_only_on_reflection;
ALTER TABLE posts DROP COLUMN IF EXISTS reflection_image_url;
