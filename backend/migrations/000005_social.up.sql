-- ═══════════════════════════════════════════════
-- SPRINT 5: Follows, Reactions, Comments, Saved
-- ═══════════════════════════════════════════════

-- ── Enums ──────────────────────────────────────
CREATE TYPE reaction_type AS ENUM (
    'amen',
    'insightful',
    'thought_provoking'
);

CREATE TYPE saved_type AS ENUM (
    'bookmark',
    'import'    -- import stores a content snapshot
);

-- ── Follows ────────────────────────────────────
-- Quiet asymmetric following.
-- Follower/following counts are NEVER computed
-- or exposed in any API response — public or private.
-- No count column here by design.
CREATE TABLE follows (
    follower_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    followee_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (follower_id, followee_id),
    CONSTRAINT no_self_follow CHECK (follower_id != followee_id)
);

CREATE INDEX idx_follows_follower ON follows (follower_id);
CREATE INDEX idx_follows_followee ON follows (followee_id);

-- ── Reactions ──────────────────────────────────
-- One reaction per user per post.
-- Public: aggregate counts only.
-- Author: counts + reactor identities.
-- This asymmetry is enforced at the repository layer,
-- NOT at the database layer.
CREATE TABLE reactions (
    id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id    UUID          NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id    UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       reaction_type NOT NULL,
    created_at TIMESTAMPTZ   NOT NULL DEFAULT now(),
    UNIQUE (post_id, user_id)  -- one reaction per user per post
);

CREATE INDEX idx_reactions_post ON reactions (post_id);
CREATE INDEX idx_reactions_user ON reactions (user_id);

-- ── Comments ───────────────────────────────────
-- Single-level flat stream. No nesting.
-- Post author can hide (is_hidden) or delete (is_deleted).
-- Hidden comments show as "[Response hidden by author]"
-- Deleted comments show as "[Response removed]"
-- Neither ever hard-deletes the row.
CREATE TABLE comments (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id    UUID        NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    author_id  UUID        NOT NULL REFERENCES users(id),
    body       TEXT        NOT NULL,
    is_hidden  BOOLEAN     NOT NULL DEFAULT false,
    is_deleted BOOLEAN     NOT NULL DEFAULT false,
    mentions   UUID[]      NOT NULL DEFAULT '{}',  -- resolved @handle → user_id[]
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_comments_post   ON comments (post_id, created_at ASC)
    WHERE is_deleted = false;
CREATE INDEX idx_comments_author ON comments (author_id);
CREATE INDEX idx_comments_mentions ON comments USING GIN (mentions);

-- ── Saved (Bookmarks + Imports) ────────────────
-- Both types are strictly private.
-- Import stores a JSONB snapshot of post content
-- at time of saving — preserved even if post is deleted.
CREATE TABLE saved (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id    UUID        NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    type       saved_type  NOT NULL,
    snapshot   JSONB,      -- populated only for type = 'import'
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, post_id, type)
);

CREATE INDEX idx_saved_user ON saved (user_id, created_at DESC);
