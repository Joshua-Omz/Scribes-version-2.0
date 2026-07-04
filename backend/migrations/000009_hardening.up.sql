-- ═══════════════════════════════════════════════
-- SPRINT 9: Final indexes, full-text search prep,
--           and data integrity constraints
-- ═══════════════════════════════════════════════

-- ── Full-text search on posts ──────────────────
-- Postgres native tsvector — no Elasticsearch needed.
-- Used for future search feature. Not exposed in v1 API.
-- Adding the column and index now is low-cost;
-- building the search endpoint later is a single handler.
ALTER TABLE posts
    ADD COLUMN search_vector TSVECTOR;

CREATE INDEX idx_posts_search ON posts USING GIN (search_vector)
    WHERE is_deleted = false;

-- Trigger to auto-update search_vector on post content change
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        to_tsvector('english',
            COALESCE(NEW.caption, '') || ' ' ||
            COALESCE(NEW.sermon_source, '')
        );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_post_search_vector
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_post_search_vector();

-- ── Composite index: public profile feed ───────
-- Supports GET /users/:handle — public posts, reverse-chron
CREATE INDEX idx_posts_public_profile
    ON posts (author_id, published_at DESC)
    WHERE is_deleted = false
    AND visibility = 'public';

-- ── Index: scripture refs for explore ──────────
CREATE INDEX idx_scripture_book_chapter
    ON scripture_refs (book, chapter);

-- ── Partial index: unread notifications ────────
-- Already created in 008 — confirmed correct, no change.

-- ── Constraint: post_versions is insert-only ───
-- Documented constraint — enforced at Go layer.
-- Cannot be enforced with a pure SQL constraint,
-- but left here as a reminder for code reviewers:
-- NO UPDATE or DELETE should exist for post_versions
-- in any .sql query file or generated Go code.
COMMENT ON TABLE post_versions IS
    'INSERT-ONLY. No UPDATE or DELETE permitted. '
    'Enforced at repository layer in internal/post/repository.go.';

-- ── Index: saved content for profile/library ───
CREATE INDEX idx_saved_bookmarks
    ON saved (user_id, created_at DESC)
    WHERE type = 'bookmark';
CREATE INDEX idx_saved_imports
    ON saved (user_id, created_at DESC)
    WHERE type = 'import';

-- ── Retention: index for DM purge worker ───────
-- Already created in 007 (idx_conversations_active).
-- Worker query: WHERE last_active < now() - INTERVAL '12 months'
-- Confirmed index covers this. No change needed.
