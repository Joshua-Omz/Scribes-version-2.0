-- ═══════════════════════════════════════════════
-- SPRINT 3: Post versions
-- IMMUTABLE TABLE — INSERT only.
-- No UPDATE or DELETE queries must ever exist
-- for post_versions in any repository file.
-- Enforced by convention and code review.
-- ═══════════════════════════════════════════════

CREATE TABLE post_versions (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id          UUID        NOT NULL REFERENCES posts(id),
    version_number   INT         NOT NULL,
    content_snapshot JSONB       NOT NULL,
    snapshotted_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    snapshotted_by   UUID        NOT NULL REFERENCES users(id),
    UNIQUE (post_id, version_number)
);

CREATE INDEX idx_post_versions_post ON post_versions (post_id, version_number ASC);
