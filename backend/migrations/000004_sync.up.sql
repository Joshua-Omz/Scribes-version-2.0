-- ═══════════════════════════════════════════════
-- SPRINT 4: server_sequence on all syncable tables
-- ═══════════════════════════════════════════════

CREATE SEQUENCE IF NOT EXISTS global_sequence;

CREATE OR REPLACE FUNCTION update_server_sequence()
RETURNS TRIGGER AS $$
BEGIN
    NEW.server_sequence = nextval('global_sequence');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── Add server_sequence to notes ───────────────
ALTER TABLE notes
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE TRIGGER update_notes_sequence
BEFORE UPDATE ON notes
FOR EACH ROW
EXECUTE FUNCTION update_server_sequence();

CREATE INDEX idx_notes_seq ON notes (author_id, server_sequence ASC);

-- ── Add server_sequence to drafts ──────────────
ALTER TABLE drafts
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE TRIGGER update_drafts_sequence
BEFORE UPDATE ON drafts
FOR EACH ROW
EXECUTE FUNCTION update_server_sequence();

CREATE INDEX idx_drafts_seq ON drafts (author_id, server_sequence ASC);

-- ── Add server_sequence to posts ───────────────
ALTER TABLE posts
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE TRIGGER update_posts_sequence
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION update_server_sequence();

CREATE INDEX idx_posts_seq ON posts (author_id, server_sequence ASC);
