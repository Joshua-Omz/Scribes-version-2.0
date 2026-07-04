DROP TRIGGER IF EXISTS trg_post_search_vector ON posts;
DROP FUNCTION IF EXISTS update_post_search_vector();
DROP INDEX IF EXISTS idx_saved_imports;
DROP INDEX IF EXISTS idx_saved_bookmarks;
DROP INDEX IF EXISTS idx_scripture_book_chapter;
DROP INDEX IF EXISTS idx_posts_public_profile;
DROP INDEX IF EXISTS idx_posts_search;
ALTER TABLE posts DROP COLUMN IF EXISTS search_vector;
