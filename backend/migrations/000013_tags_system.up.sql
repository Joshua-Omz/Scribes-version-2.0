-- ═══════════════════════════════════════════════════════
-- MIGRATION 013: Tags System
-- ═══════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ── Tag system ─────────────────────────────────────────
CREATE TABLE tags (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT        NOT NULL UNIQUE,
    display_name  TEXT        NOT NULL,
    post_count    INT         NOT NULL DEFAULT 1,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tags_name       ON tags (name);
CREATE INDEX idx_tags_post_count ON tags (post_count DESC);
CREATE INDEX idx_tags_name_trgm  ON tags USING GIN (name gin_trgm_ops);

CREATE TABLE post_tags (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  UUID NOT NULL REFERENCES tags(id),
    PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_post_tags_tag  ON post_tags (tag_id);
CREATE INDEX idx_post_tags_post ON post_tags (post_id);

-- ── Migrate Data ───────────────────────────────────────
-- Migrate existing categories into tags
INSERT INTO tags (id, name, display_name, post_count)
SELECT 
    id, 
    lower(trim(regexp_replace(name, '[^a-zA-Z0-9]', '', 'g'))), 
    name, 
    (SELECT COUNT(*) FROM post_categories pc WHERE pc.category_id = categories.id)
FROM categories;

-- Migrate post_categories into post_tags
INSERT INTO post_tags (post_id, tag_id)
SELECT post_id, category_id FROM post_categories;

-- Tag upsert function
CREATE OR REPLACE FUNCTION upsert_tag(
    p_name         TEXT,
    p_display_name TEXT
) RETURNS UUID AS $$
DECLARE
    v_id         UUID;
    v_normalised TEXT := lower(trim(regexp_replace(p_name, '[^a-zA-Z0-9]', '', 'g')));
BEGIN
    INSERT INTO tags (name, display_name)
    VALUES (v_normalised, p_display_name)
    ON CONFLICT (name) DO UPDATE
        SET post_count   = tags.post_count + 1,
            last_used_at = now()
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ── Drop old tables ────────────────────────────────────
DROP TABLE IF EXISTS user_onboarding_categories;
DROP TABLE IF EXISTS draft_categories;
DROP TABLE IF EXISTS post_categories;
DROP TABLE IF EXISTS categories;
