-- ═══════════════════════════════════════════════════════
-- MIGRATION 015: Search + Semantic layer + Recommendations
-- ═══════════════════════════════════════════════════════

-- Prerequisites
CREATE EXTENSION IF NOT EXISTS vector;    -- pgvector

-- ── Semantic embedding column ──────────────────────────
ALTER TABLE posts
    ADD COLUMN embedding vector(768);

-- IVFFlat approximate nearest neighbour index
-- Adjust 'lists' as post count grows: lists ≈ sqrt(total_posts)
CREATE INDEX idx_posts_embedding
    ON posts USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- ── Extended search vector trigger ─────────────────────
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.caption, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content->>'text', '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.sermon_source, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── Recommendation: engagement ratio index (materialised) ─
CREATE MATERIALIZED VIEW post_engagement_scores AS
SELECT
    p.id AS post_id,
    COUNT(CASE WHEN r.type = 'amen'              THEN 1 END) AS amen_count,
    COUNT(CASE WHEN r.type = 'insightful'        THEN 1 END) AS insightful_count,
    COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) AS tp_count,
    GREATEST(
        EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0,
        0.1
    ) AS age_days,
    -- Pre-computed ratios
    (COUNT(CASE WHEN r.type = 'amen' THEN 1 END) * 1.0) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS amen_ratio,
    (COUNT(CASE WHEN r.type = 'insightful' THEN 1 END) * 1.5) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS insightful_ratio,
    (COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) * 2.0) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS tp_ratio,
    (
        COUNT(CASE WHEN r.type = 'amen' THEN 1 END) * 1.0 +
        COUNT(CASE WHEN r.type = 'insightful' THEN 1 END) * 1.5 +
        COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) * 2.0
    ) / GREATEST(
        EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1
    ) AS overall_ratio
FROM posts p
LEFT JOIN reactions r ON r.post_id = p.id
WHERE p.is_deleted = false AND p.visibility = 'public'
GROUP BY p.id;

CREATE UNIQUE INDEX ON post_engagement_scores (post_id);
CREATE INDEX ON post_engagement_scores (overall_ratio DESC);
CREATE INDEX ON post_engagement_scores (amen_ratio DESC);
CREATE INDEX ON post_engagement_scores (insightful_ratio DESC);
CREATE INDEX ON post_engagement_scores (tp_ratio DESC);
