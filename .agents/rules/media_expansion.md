---
trigger: always_on
---

# Scribes — Media Expansion Migration Source of Truth
**Version 3.0 · Billing removed · Universal fair-use allowance**

> This replaces v2.0 entirely. Scribes has no commercial layer of any kind — no tiers, no subscriptions, no payment processing. Every user, regardless of anything, receives the same generous monthly media allowance. This document supersedes all billing-related content in the previous media migration document.

---

## What Changed From v2.0

| v2.0 (removed) | v3.0 (replaces it) |
|---|---|
| `billing_plans` table (free/scribe/elder tiers) | Removed entirely |
| `user_subscriptions` table | Removed entirely |
| `payment_events` table (Paystack webhooks) | Removed entirely |
| `internal/billing/` package | Removed entirely |
| Paystack integration | Removed entirely |
| Tiered credits (0/10/50 images per month) | One universal allowance for every user |
| 402 "upgrade your plan" errors | 429 "monthly allowance reached" errors |

**The `credit_usage` table remains** — but its meaning changes from "billing enforcement" to "fair-use rate limiting." Same mechanism, different purpose, zero payment processing involved.

---

## Migration 010 (revised) — post_type_and_cover_image

```sql
-- ═══════════════════════════════════════════════════════
-- MIGRATION 010: Post type enum + cover image on posts
-- No billing. No commercial gating. This purely extends
-- the posts table to support two content types and
-- native cover image support.
-- ═══════════════════════════════════════════════════════

CREATE TYPE post_type AS ENUM (
    'standard',
    'passage'
);

ALTER TABLE posts
    ADD COLUMN post_type       post_type NOT NULL DEFAULT 'standard',
    ADD COLUMN cover_image_url TEXT;

ALTER TABLE posts
    ADD CONSTRAINT cover_image_standard_only
    CHECK (
        cover_image_url IS NULL
        OR post_type = 'standard'
    );

CREATE INDEX idx_posts_type
    ON posts (post_type, published_at DESC)
    WHERE is_deleted = false;

-- ── Media uploads table ─────────────────────────────────
-- Tracks every file uploaded through POST /media/upload.
-- No credit_cost — this is an audit trail, not a billing ledger.
CREATE TABLE media_uploads (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id  UUID        NOT NULL REFERENCES users(id),
    url          TEXT        NOT NULL UNIQUE,
    mime_type    TEXT        NOT NULL,
    size_bytes   BIGINT      NOT NULL,
    width_px     INT,
    height_px    INT,
    post_id      UUID        REFERENCES posts(id),  -- nullable until post is published
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT valid_mime_type CHECK (
        mime_type IN ('image/jpeg', 'image/png', 'image/webp')
    ),
    CONSTRAINT max_size CHECK (
        size_bytes <= 5242880  -- 5MB — a technical limit, not a plan limit
    )
);

CREATE INDEX idx_media_uploader ON media_uploads (uploader_id, created_at DESC);
```

## 010_post_type_and_cover_image.down.sql

```sql
DROP TABLE IF EXISTS media_uploads;
DROP INDEX IF EXISTS idx_posts_type;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS cover_image_standard_only;
ALTER TABLE posts DROP COLUMN IF EXISTS cover_image_url;
ALTER TABLE posts DROP COLUMN IF EXISTS post_type;
DROP TYPE IF EXISTS post_type;
```

---

## Migration 011 — passage_panels (unchanged from v2.0)

No changes to this migration. Passage immutability rules stand exactly as previously defined — see `scribes_media_migration.md` §011 for the full SQL. Included here by reference only.

---

## Migration 012 — sound_pool (unchanged from v2.0)

No changes to this migration. Sound pool curation, categories, and the `sound_id` FK on posts stand exactly as previously defined — see `scribes_media_migration.md` §012 for the full SQL. Included here by reference only.

---

## Updated table inventory

| Table | Migration | Notes |
|---|---|---|
| ...all previous tables unchanged... | | |
| media_uploads | 010 | Audit trail only, no billing fields |
| passage_panels | 011 | Unchanged |
| sound_pool | 012 | Unchanged |
| ~~fair_use_policy~~ | ~~013~~ | **Removed entirely (no usage tracking)** |
| ~~credit_usage~~ | ~~013~~ | **Removed entirely (no usage tracking)** |
| ~~billing_plans~~ | ~~013~~ | **Removed** |
| ~~user_subscriptions~~ | ~~013~~ | **Removed** |
| ~~payment_events~~ | ~~013~~ | **Removed** |

**Total: 24 tables** (down from 28 in v2.0 — three billing tables removed, and usage tracking removed)

---

*Scribes Media Expansion Migration Source of Truth v3.1*
*No billing. No tiers. No payment processing. No usage tracking.*