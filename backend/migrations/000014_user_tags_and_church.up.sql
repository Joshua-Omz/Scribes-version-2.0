-- ═══════════════════════════════════════════════════════
-- MIGRATION 014: User Tags and Church Flag
-- ═══════════════════════════════════════════════════════

ALTER TABLE users ADD COLUMN is_church BOOLEAN NOT NULL DEFAULT false;

CREATE TABLE user_tags (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tag_id  UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, tag_id)
);

CREATE INDEX idx_user_tags_user ON user_tags (user_id);
