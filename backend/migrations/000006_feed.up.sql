-- ═══════════════════════════════════════════════
-- SPRINT 6: Feed indexes + explore score support
-- ═══════════════════════════════════════════════
-- No new tables — this migration adds the indexes
-- that make feed and explore queries performant.
-- The interaction score formula is:
--   SUM(reactions) + SUM(comments) in 90-day window
-- No view counts. No read times. Ever.

-- ── Composite index for following feed ─────────
-- Supports: WHERE author_id IN (subquery) ORDER BY published_at DESC
CREATE INDEX idx_posts_feed ON posts (author_id, published_at DESC)
    WHERE is_deleted = false
    AND visibility = 'public';

-- ── Composite index for explore score ──────────
-- Supports reaction count subquery per post in 90d window
CREATE INDEX idx_reactions_score ON reactions (post_id, created_at DESC);

-- ── Composite index for comment count ──────────
CREATE INDEX idx_comments_score ON comments (post_id, created_at DESC)
    WHERE is_deleted = false
    AND is_hidden = false;

-- ── Keyset pagination index ─────────────────────
-- Supports: WHERE (published_at, id) < ($cursor_ts, $cursor_id)
CREATE INDEX idx_posts_keyset ON posts (published_at DESC, id DESC)
    WHERE is_deleted = false
    AND visibility = 'public';

-- ── Category index for explore filter ──────────
CREATE INDEX idx_post_categories_explore
    ON post_categories (category_id, post_id);
