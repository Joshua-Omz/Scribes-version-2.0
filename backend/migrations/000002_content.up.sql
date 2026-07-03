-- ═══════════════════════════════════════════════
-- SPRINT 2: Notes, Notebooks, Drafts, Posts,
--           ScriptureRefs, PostCategories
-- ═══════════════════════════════════════════════

-- ── Enums ──────────────────────────────────────
CREATE TYPE note_source_type AS ENUM (
    'sermon',
    'study',
    'received',  -- personal impression — most sacred, use sparingly in UI
    'personal'
);

CREATE TYPE post_visibility AS ENUM (
    'public',
    'private'
);

-- ── Notebooks ──────────────────────────────────
CREATE TABLE notebooks (
    id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id   UUID        NOT NULL REFERENCES users(id),
    name       TEXT        NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notebooks_owner ON notebooks (owner_id);

-- ── Notes ──────────────────────────────────────
-- Private writing workspace.
-- Not shown publicly under any circumstance.
-- server_sequence added in 004 migration.
CREATE TABLE notes (
    id           UUID             PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id    UUID             NOT NULL REFERENCES users(id),
    content      JSONB            NOT NULL DEFAULT '{}',
    title        TEXT,
    notebook_id  UUID             REFERENCES notebooks(id) ON DELETE SET NULL,
    source_type  note_source_type,
    source_label TEXT,            -- e.g. "Pastor Adeyemi · 14 Jun 2026"
    updated_at   TIMESTAMPTZ      NOT NULL DEFAULT now(),
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT now()
);

CREATE INDEX idx_notes_author    ON notes (author_id);
CREATE INDEX idx_notes_notebook  ON notes (notebook_id);

-- ── Drafts ─────────────────────────────────────
-- Temporary staging queue. Deleted on publish.
-- server_sequence added in 004 migration.
CREATE TABLE drafts (
    id             UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id      UUID        NOT NULL REFERENCES users(id),
    content        JSONB       NOT NULL DEFAULT '{}',
    caption        TEXT,
    sermon_source  TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_drafts_author ON drafts (author_id);

-- ── Posts ──────────────────────────────────────
-- Published knowledge artifacts.
-- Durable — soft-deleted only, never hard-deleted.
-- server_sequence added in 004 migration.
CREATE TABLE posts (
    id                UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id         UUID            NOT NULL REFERENCES users(id),
    content           JSONB           NOT NULL,
    caption           TEXT,
    visibility        post_visibility NOT NULL DEFAULT 'public',
    current_version   INT             NOT NULL DEFAULT 1,
    is_correction     BOOLEAN         NOT NULL DEFAULT false,
    corrects_post_id  UUID            REFERENCES posts(id),
    sermon_source     TEXT,
    is_deleted        BOOLEAN         NOT NULL DEFAULT false,
    published_at      TIMESTAMPTZ     NOT NULL DEFAULT now()
);

CREATE INDEX idx_posts_author      ON posts (author_id);
CREATE INDEX idx_posts_published   ON posts (published_at DESC)
    WHERE is_deleted = false;
CREATE INDEX idx_posts_visibility  ON posts (visibility)
    WHERE is_deleted = false;
CREATE INDEX idx_posts_correction  ON posts (corrects_post_id)
    WHERE corrects_post_id IS NOT NULL;

-- ── Scripture references ────────────────────────
CREATE TABLE scripture_refs (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id      UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    book         TEXT NOT NULL,
    chapter      INT  NOT NULL,
    verse_start  INT  NOT NULL,
    verse_end    INT,
    CONSTRAINT verse_order CHECK (
        verse_end IS NULL OR verse_end >= verse_start
    )
);

CREATE INDEX idx_scripture_post ON scripture_refs (post_id);

-- ── Categories ─────────────────────────────────
-- Managed by SUPER_ADMIN only (enforced at service layer).
-- Deprecated categories remain on existing posts.
CREATE TABLE categories (
    id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT    NOT NULL UNIQUE,
    is_deprecated BOOLEAN NOT NULL DEFAULT false
);

-- Seed canonical v1 categories
INSERT INTO categories (name) VALUES
    ('Theology'),
    ('Hermeneutics'),
    ('Church History'),
    ('Prayer'),
    ('Prophecy'),
    ('Apologetics'),
    ('Old Testament'),
    ('New Testament'),
    ('Discipleship'),
    ('Worship'),
    ('Eschatology'),
    ('Systematic Theology'),
    ('Missions'),
    ('Spiritual Formation'),
    ('Sermon Notes');

-- ── Post ↔ Category join ───────────────────────
CREATE TABLE post_categories (
    post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    PRIMARY KEY (post_id, category_id)
);

CREATE INDEX idx_post_categories_category ON post_categories (category_id);

-- ── Draft ↔ Category join ──────────────────────
-- Tracks category selections on a draft before publish.
CREATE TABLE draft_categories (
    draft_id    UUID NOT NULL REFERENCES drafts(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    PRIMARY KEY (draft_id, category_id)
);

-- ── User onboarding categories ─────────────────
-- Set once during signup. Used for cold-start feed.
CREATE TABLE user_onboarding_categories (
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id),
    PRIMARY KEY (user_id, category_id)
);
