This will serve as your source of truth that will guide to creation of migration in sprints 

# Scribes — Migration Source of Truth
**Version 1.0 · SQL per sprint · golang-migrate format**

> Every migration here is forward-only by default. Down migrations are provided for development rollback only — never run a down migration in production. Each sprint's SQL must be run in order. Never edit a migration file that has already been executed anywhere.

---

## How to run

```bash
# Up — apply all pending
migrate -path ./migrations -database "$DATABASE_URL" up

# Up — apply exactly one
migrate -path ./migrations -database "$DATABASE_URL" up 1

# Down — roll back one (dev only)
migrate -path ./migrations -database "$DATABASE_URL" down 1

# Makefile shorthand
make migrate-up
make migrate-down
```

---

## Global types and sequences

These are referenced across multiple migrations.
They are created in `001` and must never be recreated.

```sql
-- Enums created in 001, extended never replaced
-- user_role, note_source_type, post_visibility,
-- reaction_type, saved_type, request_status, notif_type
-- global_sequence — single monotonic counter for all syncable tables
```

---

## Sprint 1 — Foundation & Auth

### 001_users.up.sql

```sql
-- ═══════════════════════════════════════════════
-- SPRINT 1: Users, roles, global sequence
-- ═══════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── Enums ──────────────────────────────────────
CREATE TYPE user_role AS ENUM (
    'standard',
    'super_admin'
);

-- ── Global sequence ────────────────────────────
-- Single monotonic counter for all syncable tables.
-- NEVER use client-supplied values for ordering.
-- ALWAYS use nextval('global_sequence') server-side.
CREATE SEQUENCE global_sequence
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    CACHE 1;

-- ── Users ──────────────────────────────────────
CREATE TABLE users (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    handle        TEXT        UNIQUE NOT NULL,
    display_name  TEXT        NOT NULL,
    email         TEXT        UNIQUE NOT NULL,
    password_hash TEXT        NOT NULL,
    bio           TEXT,
    role          user_role   NOT NULL DEFAULT 'standard',
    is_deleted    BOOLEAN     NOT NULL DEFAULT false,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_handle    ON users (handle)
    WHERE is_deleted = false;
CREATE INDEX idx_users_email     ON users (email)
    WHERE is_deleted = false;
CREATE INDEX idx_users_role      ON users (role);

-- ── Constraints ────────────────────────────────
-- handle: alphanumeric + underscore, 3-30 chars
ALTER TABLE users
    ADD CONSTRAINT handle_format
    CHECK (handle ~ '^[a-zA-Z0-9_]{3,30}$');

-- email: basic format
ALTER TABLE users
    ADD CONSTRAINT email_format
    CHECK (email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');
```

### 001_users.down.sql

```sql
DROP TABLE IF EXISTS users;
DROP SEQUENCE IF EXISTS global_sequence;
DROP TYPE IF EXISTS user_role;
DROP EXTENSION IF EXISTS "pgcrypto";
```

---

## Sprint 2 — Notes, Drafts, Posts

### 002_content.up.sql

```sql
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
```

### 002_content.down.sql

```sql
DROP TABLE IF EXISTS user_onboarding_categories;
DROP TABLE IF EXISTS draft_categories;
DROP TABLE IF EXISTS post_categories;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS scripture_refs;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS drafts;
DROP TABLE IF EXISTS notes;
DROP TABLE IF EXISTS notebooks;
DROP TYPE IF EXISTS post_visibility;
DROP TYPE IF EXISTS note_source_type;
```

---

## Sprint 3 — Post Versioning & Correction Posts

### 003_versioning.up.sql

```sql
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

-- Revision flow (handled in Go service layer, documented here):
-- 1. SELECT current content from posts WHERE id = $1
-- 2. INSERT INTO post_versions (snapshot of current content, version_number = current_version)
-- 3. UPDATE posts SET content = $new, current_version = current_version + 1
-- Steps 2 and 3 MUST run inside a single transaction.
-- If the transaction fails, no version is snapshotted and no content changes.
```

### 003_versioning.down.sql

```sql
DROP TABLE IF EXISTS post_versions;
```

---

## Sprint 4 — Offline Sync

### 004_sync.up.sql

```sql
-- ═══════════════════════════════════════════════
-- SPRINT 4: server_sequence on all syncable tables
-- ═══════════════════════════════════════════════
-- The global_sequence was created in 001.
-- This migration wires it to the content tables.
-- CRITICAL: server_sequence is ALWAYS assigned
-- by the server via nextval('global_sequence').
-- A client-supplied sequence value must be
-- rejected at the service layer, not just ignored.

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

-- ── Sync query pattern (documented here) ───────
-- GET /sync?seq=N executes:
--
-- SELECT 'note' AS type, id, content, title,
--        notebook_id, server_sequence, updated_at
-- FROM notes
-- WHERE author_id = $caller_id
--   AND server_sequence > $last_seq
--
-- UNION ALL
--
-- SELECT 'draft' AS type, id, content, caption,
--        NULL, server_sequence, updated_at
-- FROM drafts
-- WHERE author_id = $caller_id
--   AND server_sequence > $last_seq
--
-- UNION ALL
--
-- SELECT 'post' AS type, id, content, caption,
--        NULL, server_sequence, published_at
-- FROM posts
-- WHERE author_id = $caller_id
--   AND server_sequence > $last_seq
--
-- ORDER BY server_sequence ASC;
--
-- THE author_id = $caller_id FILTER IS MANDATORY.
-- A missing filter leaks one user's private data
-- to another. This query has a dedicated unit test
-- in internal/sync/repository_test.go that must
-- pass before any other sync work proceeds.
```

### 004_sync.down.sql

```sql
DROP INDEX IF EXISTS idx_posts_seq;
DROP INDEX IF EXISTS idx_drafts_seq;
DROP INDEX IF EXISTS idx_notes_seq;

ALTER TABLE posts  DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE drafts DROP COLUMN IF EXISTS server_sequence;
ALTER TABLE notes  DROP COLUMN IF EXISTS server_sequence;
```

---

## Sprint 5 — Social Layer

### 005_social.up.sql

```sql
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
    id        UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id   UUID          NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id   UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type      reaction_type NOT NULL,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
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
```

### 005_social.down.sql

```sql
DROP TABLE IF EXISTS saved;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS reactions;
DROP TABLE IF EXISTS follows;
DROP TYPE IF EXISTS saved_type;
DROP TYPE IF EXISTS reaction_type;
```

---

## Sprint 6 — Feed & Discovery

### 006_feed.up.sql

```sql
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

-- ── Explore score query pattern (documented) ───
-- SELECT
--   p.id,
--   p.author_id,
--   p.content,
--   p.published_at,
--   (
--     SELECT COUNT(*) FROM reactions r
--     WHERE r.post_id = p.id
--     AND r.created_at > now() - INTERVAL '90 days'
--   ) +
--   (
--     SELECT COUNT(*) FROM comments c
--     WHERE c.post_id = p.id
--     AND c.is_deleted = false
--     AND c.created_at > now() - INTERVAL '90 days'
--   ) AS interaction_score
-- FROM posts p
-- JOIN post_categories pc ON pc.post_id = p.id
-- WHERE pc.category_id = ANY($category_ids)
--   AND p.is_deleted = false
--   AND p.visibility = 'public'
-- ORDER BY interaction_score DESC, p.published_at DESC
-- LIMIT $limit;
```

### 006_feed.down.sql

```sql
DROP INDEX IF EXISTS idx_post_categories_explore;
DROP INDEX IF EXISTS idx_posts_keyset;
DROP INDEX IF EXISTS idx_comments_score;
DROP INDEX IF EXISTS idx_reactions_score;
DROP INDEX IF EXISTS idx_posts_feed;
```

---

## Sprint 7 — Direct Messaging

### 007_dm.up.sql

```sql
-- ═══════════════════════════════════════════════
-- SPRINT 7: Conversations, Message Requests,
--           Messages
-- ═══════════════════════════════════════════════

CREATE TYPE request_status AS ENUM (
    'pending',
    'approved',
    'rejected'
);

-- ── Conversations ──────────────────────────────
-- A conversation is created when a message request
-- is approved. Not before.
-- blocked = true prevents further messages from
-- either party. Does not reveal who blocked whom.
CREATE TABLE conversations (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id   UUID        NOT NULL REFERENCES users(id),
    user_b_id   UUID        NOT NULL REFERENCES users(id),
    blocked     BOOLEAN     NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_active TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_a_id, user_b_id),
    CONSTRAINT no_self_conversation CHECK (user_a_id != user_b_id)
);

CREATE INDEX idx_conversations_user_a ON conversations (user_a_id, last_active DESC);
CREATE INDEX idx_conversations_user_b ON conversations (user_b_id, last_active DESC);
CREATE INDEX idx_conversations_active ON conversations (last_active ASC);  -- for retention worker

-- ── Message requests ───────────────────────────
-- A non-mutual sender must request before messaging.
-- first_message is shown in the request preview.
-- No conversation row exists until status = approved.
CREATE TABLE message_requests (
    id            UUID           PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id  UUID           NOT NULL REFERENCES users(id),
    to_user_id    UUID           NOT NULL REFERENCES users(id),
    status        request_status NOT NULL DEFAULT 'pending',
    first_message TEXT           NOT NULL,
    created_at    TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CONSTRAINT no_self_request CHECK (from_user_id != to_user_id)
);

CREATE INDEX idx_requests_to   ON message_requests (to_user_id, status)
    WHERE status = 'pending';
CREATE INDEX idx_requests_from ON message_requests (from_user_id);

-- ── Messages ───────────────────────────────────
-- Text only. No attachments. No media.
-- Soft-delete: body replaced with '[Message deleted]'
-- at the repository layer — the row is never removed.
-- Retention: background worker purges conversations
-- with last_active older than 12 months.
CREATE TABLE messages (
    id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id  UUID        NOT NULL REFERENCES conversations(id),
    sender_id        UUID        NOT NULL REFERENCES users(id),
    body             TEXT        NOT NULL,
    is_deleted       BOOLEAN     NOT NULL DEFAULT false,
    sent_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT body_not_empty CHECK (length(trim(body)) > 0),
    CONSTRAINT body_max_length CHECK (length(body) <= 4000)
);

CREATE INDEX idx_messages_conversation
    ON messages (conversation_id, sent_at ASC);
CREATE INDEX idx_messages_sender
    ON messages (sender_id);

-- ── Retention policy trigger (update last_active) ──
CREATE OR REPLACE FUNCTION update_conversation_last_active()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE conversations
    SET last_active = now()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_message_last_active
    AFTER INSERT ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_conversation_last_active();
```

### 007_dm.down.sql

```sql
DROP TRIGGER IF EXISTS trg_message_last_active ON messages;
DROP FUNCTION IF EXISTS update_conversation_last_active();
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS message_requests;
DROP TABLE IF EXISTS conversations;
DROP TYPE IF EXISTS request_status;
```

---

## Sprint 8 — Notifications & Admin

### 008_notifications.up.sql

```sql
-- ═══════════════════════════════════════════════
-- SPRINT 8: Notifications
-- ═══════════════════════════════════════════════

CREATE TYPE notif_type AS ENUM (
    'mention',       -- real-time
    'reaction',      -- batched digest
    'comment',       -- batched digest
    'follow',        -- batched digest
    'admin_alert'    -- real-time
);

-- ── Notifications ──────────────────────────────
-- Two delivery paths:
-- is_realtime = true  → mention, admin_alert → immediate push
-- is_realtime = false → reaction, comment, follow → batched digest
-- ref_id is polymorphic — points to comment/post/user
-- depending on type. Resolved at the service layer.
CREATE TABLE notifications (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type         notif_type  NOT NULL,
    ref_id       UUID        NOT NULL,
    is_realtime  BOOLEAN     NOT NULL,
    is_read      BOOLEAN     NOT NULL DEFAULT false,
    sent_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_recipient
    ON notifications (recipient_id, created_at DESC)
    WHERE is_read = false;
CREATE INDEX idx_notifications_unsent
    ON notifications (is_realtime, sent_at)
    WHERE sent_at IS NULL;

-- ── Content reports ────────────────────────────
-- Standard user reporting. Content stays active
-- until a SUPER_ADMIN reviews and actions it.
CREATE TYPE report_status AS ENUM (
    'pending',
    'reviewed',
    'actioned',
    'dismissed'
);

CREATE TABLE reports (
    id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id   UUID          NOT NULL REFERENCES users(id),
    content_type  TEXT          NOT NULL,   -- 'post' | 'comment' | 'message'
    content_id    UUID          NOT NULL,
    reason        TEXT          NOT NULL,
    status        report_status NOT NULL DEFAULT 'pending',
    reviewed_by   UUID          REFERENCES users(id),
    reviewed_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_status ON reports (status, created_at ASC)
    WHERE status = 'pending';
```

### 008_notifications.down.sql

```sql
DROP TABLE IF EXISTS reports;
DROP TYPE IF EXISTS report_status;
DROP TABLE IF EXISTS notifications;
DROP TYPE IF EXISTS notif_type;
```

---

## Sprint 9 — Hardening & Final Indexes

### 009_hardening.up.sql

```sql
-- ═══════════════════════════════════════════════
-- SPRINT 9: Final indexes, full-text search prep,
--           and data integrity constraints
-- ═══════════════════════════════════════════════

-- ── Full-text search on posts ──────────────────
-- Postgres native tsvector — no Elasticsearch needed.
-- Used for future search feature. Not exposed in v1 API.
-- Adding the column and index now is low-cost;
-- building the search endpoint later is a single handler.
ALTER TABLE posts
    ADD COLUMN search_vector TSVECTOR;

CREATE INDEX idx_posts_search ON posts USING GIN (search_vector)
    WHERE is_deleted = false;

-- Trigger to auto-update search_vector on post content change
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        to_tsvector('english',
            COALESCE(NEW.caption, '') || ' ' ||
            COALESCE(NEW.sermon_source, '')
        );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_post_search_vector
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION update_post_search_vector();

-- ── Composite index: public profile feed ───────
-- Supports GET /users/:handle — public posts, reverse-chron
CREATE INDEX idx_posts_public_profile
    ON posts (author_id, published_at DESC)
    WHERE is_deleted = false
    AND visibility = 'public';

-- ── Index: scripture refs for explore ──────────
CREATE INDEX idx_scripture_book_chapter
    ON scripture_refs (book, chapter);

-- ── Partial index: unread notifications ────────
-- Already created in 008 — confirmed correct, no change.

-- ── Constraint: post_versions is insert-only ───
-- Documented constraint — enforced at Go layer.
-- Cannot be enforced with a pure SQL constraint,
-- but left here as a reminder for code reviewers:
-- NO UPDATE or DELETE should exist for post_versions
-- in any .sql query file or generated Go code.
COMMENT ON TABLE post_versions IS
    'INSERT-ONLY. No UPDATE or DELETE permitted. '
    'Enforced at repository layer in internal/post/repository.go.';

-- ── Index: saved content for profile/library ───
CREATE INDEX idx_saved_bookmarks
    ON saved (user_id, created_at DESC)
    WHERE type = 'bookmark';
CREATE INDEX idx_saved_imports
    ON saved (user_id, created_at DESC)
    WHERE type = 'import';

-- ── Retention: index for DM purge worker ───────
-- Already created in 007 (idx_conversations_active).
-- Worker query: WHERE last_active < now() - INTERVAL '12 months'
-- Confirmed index covers this. No change needed.
```

### 009_hardening.down.sql

```sql
DROP TRIGGER IF EXISTS trg_post_search_vector ON posts;
DROP FUNCTION IF EXISTS update_post_search_vector();
DROP INDEX IF EXISTS idx_saved_imports;
DROP INDEX IF EXISTS idx_saved_bookmarks;
DROP INDEX IF EXISTS idx_scripture_book_chapter;
DROP INDEX IF EXISTS idx_posts_public_profile;
DROP INDEX IF EXISTS idx_posts_search;
ALTER TABLE posts DROP COLUMN IF EXISTS search_vector;
```

---

## Complete table inventory

| Table | Created in | Type | Notes |
|---|---|---|---|
| users | 001 | Core | soft-delete only |
| notebooks | 002 | Core | single-level grouping |
| notes | 002 | Core | server_sequence added in 004 |
| drafts | 002 | Core | deleted on publish |
| posts | 002 | Core | soft-delete only, server_sequence added in 004 |
| categories | 002 | Reference | SUPER_ADMIN write only |
| scripture_refs | 002 | Child | CASCADE delete with post |
| post_categories | 002 | Join | — |
| draft_categories | 002 | Join | CASCADE delete with draft |
| user_onboarding_categories | 002 | Join | set once, never updated |
| post_versions | 003 | Immutable | INSERT only, never UPDATE/DELETE |
| follows | 005 | Social | counts never exposed |
| reactions | 005 | Social | one per user per post |
| comments | 005 | Social | soft-delete only |
| saved | 005 | Social | bookmark + import |
| conversations | 007 | DM | created on request approval only |
| message_requests | 007 | DM | — |
| messages | 007 | DM | soft-delete, 12mo retention |
| notifications | 008 | System | two delivery paths |
| reports | 008 | Admin | SUPER_ADMIN reviewed |

**Total: 20 tables across 5 migrations (001–009)**

---

## Non-negotiable rules — re-stated

1. `global_sequence` is created once in `001`. Never recreated, never reset.
2. `server_sequence` on notes/drafts/posts uses `nextval('global_sequence')` — always server-assigned.
3. `post_versions` — no `UPDATE` or `DELETE` query may exist anywhere in the codebase for this table.
4. Follower/following counts — no `COUNT(*)` on `follows` table may appear in any query that feeds a public or private API response.
5. `reactions` and `comments` counts are the ONLY engagement signals. No view counts, no read times — not in the schema, not in any query, not in any index.
6. Migration files are forward-only and numbered. Never edit a file that has run. Always add a new numbered migration.
7. Down migrations exist for development rollback only. They must never run in production.

---

*Scribes Migration Source of Truth v1.0*
*20 tables · 9 migration pairs · 43 endpoints*