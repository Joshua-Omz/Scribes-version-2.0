-- ═══════════════════════════════════════════════
-- SPRINT 4: server_sequence on all syncable tables
-- ═══════════════════════════════════════════════

-- ── Add server_sequence to notes ───────────────
ALTER TABLE notes
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE INDEX idx_notes_seq ON notes (author_id, server_sequence ASC);

-- ── Add server_sequence to drafts ──────────────
ALTER TABLE drafts
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE INDEX idx_drafts_seq ON drafts (author_id, server_sequence ASC);

-- ── Add server_sequence to posts ───────────────
ALTER TABLE posts
    ADD COLUMN server_sequence BIGINT
        NOT NULL DEFAULT nextval('global_sequence');

CREATE INDEX idx_posts_seq ON posts (author_id, server_sequence ASC);
