-- ═══════════════════════════════════════════════════════
-- MIGRATION 020: Fix search vector parsing
-- ═══════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.caption, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content->>'title', '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content->>'excerpt', '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.content->>'body', '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.sermon_source, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger an update on all existing posts so they regenerate their search_vector
UPDATE posts SET id = id;
