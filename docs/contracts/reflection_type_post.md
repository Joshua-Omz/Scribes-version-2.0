# Scribes — Reflection Post Type Contract
**Version 1.0 · The third post type: short-form, immutable, quoted verse + inline image**

> Scribes has three post types, not two. Standard is long-form manuscript writing. Passage is a structured, panel-based devotional. **Reflection** is the lightweight third surface — a short thought or question, optionally paired with a quoted verse and an inline image, published as a single immutable unit. This document specifies it fully: schema, endpoints, immutability rules, and how it renders differently from its two siblings everywhere it appears.

---

## 1. Why Reflection Exists

Standard and Passage both ask something significant of an author — a full piece of writing, or a structured multi-panel build. There was no surface for the smaller thing: a single verse that struck someone that morning, a question raised in a Bible study, a photo from a church gathering with a short caption and a scripture attached. Reflection is that surface. It lowers the barrier to publishing without diluting what Standard and Passage are for.

**The test for which type an author should reach for:**
- Writing something substantial, meant to be read start to finish → **Standard**
- Building a structured, ordered devotional experience across multiple panels → **Passage**
- Sharing one thought, in the moment, possibly with a verse and a photo → **Reflection**

---

## 2. Database Schema

```sql
-- 017_reflection_post_type.up.sql

-- Extend the existing post_type enum (defined in migration 010)
ALTER TYPE post_type ADD VALUE 'reflection';

-- Reflection-specific fields on posts
ALTER TABLE posts
    ADD COLUMN reflection_image_url TEXT;

-- This is explicitly NOT cover_image_url. cover_image_url is a Standard-only
-- hero image (full-width, sets the tone of a long piece). reflection_image_url
-- is a smaller, inline attachment — part of the thought itself, not a banner.
-- The two are mutually exclusive by post_type already, but named separately
-- for clarity and so a future reviewer never has to wonder which type a
-- given image column belongs to.

ALTER TABLE posts
    ADD CONSTRAINT reflection_image_only_on_reflection
    CHECK (
        reflection_image_url IS NULL
        OR post_type = 'reflection'
    );

-- Body length enforcement — hard cap at the database level, not just
-- service-layer validation, so the rule can never be silently bypassed
-- by a future direct-insert path or admin tool.
ALTER TABLE posts
    ADD CONSTRAINT reflection_body_length
    CHECK (
        post_type != 'reflection'
        OR char_length(body_plain_text) <= 500
    );

-- Reflections are immutable, exactly like Passage — no revision history.
-- This reuses the existing immutability enforcement pattern from Passage
-- (405 on any PATCH/PUT attempt post-publish) rather than introducing
-- a new mechanism. See §5.
```

```sql
-- 017_reflection_post_type.down.sql
ALTER TABLE posts DROP CONSTRAINT IF EXISTS reflection_body_length;
ALTER TABLE posts DROP CONSTRAINT IF EXISTS reflection_image_only_on_reflection;
ALTER TABLE posts DROP COLUMN IF EXISTS reflection_image_url;
-- Note: PostgreSQL does not support removing a value from an enum type
-- directly. A full down-migration for the enum addition would require
-- recreating the post_type enum without 'reflection' and remapping any
-- existing rows — treat this as a one-way migration in practice.
```

**Note on `body_plain_text`:** this assumes posts already maintain a plain-text-extracted column alongside the rich Delta content, used for search indexing (per `scribes_search_recommendations_v2.md`'s tsvector approach) and now reused here for length enforcement. If no such column exists yet, confirm with whoever owns the Post schema before this migration ships — the constraint needs a plain-text length, not a raw Delta JSON string length, since counting JSON structural characters would make the 500-character limit meaningless.

---

## 3. What Reflection Reuses vs. What's New

| Component | Reflection's behavior |
|---|---|
| `scripture_refs` table | **Reused as-is.** A Reflection with a quoted verse gets a row here exactly like a Standard post does — no schema change needed |
| `body` (Delta content) | **Reused as-is.** Same Delta-based rich text field and rendering pipeline as Standard — just capped at 500 characters of plain text |
| `media_uploads` / R2 storage | **Reused as-is.** `reflection_image_url` is populated by the same `internal/storage/` service and `AssetType` pattern already defined — likely needs one new `AssetType.reflectionImage` entry with its own size/dimension rule (see §4) |
| `post_versions` (revision history) | **Not used.** Reflections never generate a version row — publish is final, exactly like Passage |
| Fair-use allowance (`credit_usage`) | **Reused, extended.** Reflection images count against the same monthly panel-image allowance already defined in `scribes_media_contracts_v2.md`, rather than introducing a fourth allowance category |

---

## 4. Storage Service Addition

Per `scribes_r2_storage_contract.md` §3, one new `AssetType` and its rule:

```go
// internal/storage/model.go — addition to the existing AssetRules map

AssetTypeReflectionImage: {
    AllowedMIME:   []string{"image/jpeg", "image/png", "image/webp"},
    MaxSizeBytes:  5 * 1024 * 1024,  // same 5MB ceiling as other post images
    MaxWidthPx:    4096,
    MaxHeightPx:   4096,
    BucketPrefix:  "posts/reflections/",  // new prefix, sibling to posts/covers/ and posts/panels/
},
```

Bucket structure gains one new prefix, extending the existing five:

```
scribes-media/
├── avatars/
├── posts/
│   ├── covers/
│   ├── panels/
│   └── reflections/        ← new
├── notes/
└── sounds/
```

---

## 5. Immutability — Reusing the Passage Pattern Exactly

Per the existing media contract, Passage posts return `405 Method Not Allowed` on any attempt to PATCH or PUT after publish. Reflection adopts this identically rather than inventing a parallel mechanism:

```go
// internal/post/service.go

func (s *PostService) UpdatePost(ctx context.Context, postID uuid.UUID, updates UpdatePostInput) error {
    post, err := s.repo.GetByID(ctx, postID)
    if err != nil { return err }

    if post.PostType == PostTypePassage || post.PostType == PostTypeReflection {
        return ErrPostImmutable  // maps to 405 in the handler, same as Passage today
    }

    // ...existing Standard post update + versioning logic, unchanged
}
```

**Why immutable, not versioned:** a Reflection is a moment, not a document — "this is what I thought reading this verse today" doesn't really have a meaningful "v2." If an author wants to say something differently, the honest action is publishing a new Reflection, not editing the old one. This mirrors the same reasoning already applied to Passage, extended to a second post type for a related but distinct reason (Passage is immutable because it's a structured artifact; Reflection is immutable because it's a timestamped moment).

If a Reflection needs correcting for accuracy (not just rephrasing), the existing Correction Post / erratum mechanism (per the core content model) still applies — same as it does for Passage.

---

## 6. API Surface

No new endpoints required. Reflection publishes through the existing `POST /posts` endpoint with `post_type: "reflection"` — the same pattern Passage already uses. The service-layer validation branches on `post_type` to apply Reflection-specific rules:

```go
// internal/post/service.go — validation branch

func (s *PostService) CreatePost(ctx context.Context, input CreatePostInput) (*Post, error) {
    if input.PostType == PostTypeReflection {
        if len(input.BodyPlainText) > 500 {
            return nil, ErrReflectionTooLong  // 400
        }
        if input.CoverImageURL != nil {
            return nil, ErrReflectionNoCoverImage  // 400 — must use reflection_image_url instead
        }
    }
    // ...existing creation logic
}
```

---

## 7. Flutter — Composer Experience

Reflection needs its own lightweight compose surface, distinct from Standard's full editor and Passage's panel builder:

```
lib/features/compose/presentation/
├── standard_composer.dart      — existing, full Quill editor + cover image picker
├── passage_composer.dart        — existing, panel builder
└── reflection_composer.dart     — new
```

**Reflection composer, conceptually:**
- A single, compact text input — still backed by Quill/Delta for consistency with the rest of the platform (so bold/italic/scripture-chip insertion still works), but visually presented as a lightweight box, not a full-page editor
- A live character counter, visible once the author approaches the 500-character limit (e.g., appears at 400+, per common UX convention — exact threshold is a small implementation decision, not a contract requirement)
- An "Attach scripture" action — reuses the exact same scripture picker Standard already has
- An "Attach photo" action — a single image picker, populating `reflection_image_url`, visually smaller/inline compared to Standard's full-width cover image picker
- A clear, upfront notice before publish: **"Reflections can't be edited after posting."** This should appear once, plainly, before the publish action — not buried in a tooltip — since immutability is a real behavioral difference from what Standard authors are used to

---

## 8. Rendering — Feed Card, Post Detail, and Export

Each surface needs a distinct treatment so Reflection doesn't just look like a short Standard post:

### Feed / Explore card
- Compact card, noticeably shorter than a Standard card — no cover image banner
- If `reflection_image_url` is present, the image renders small and inline, alongside or beneath the text — not full-width hero treatment
- Scripture chip, if present, renders in its existing compact gold-border style
- No "read time" indicator (already forbidden platform-wide) — but worth noting Reflection's brevity makes this especially moot

### Post Detail
- Simpler layout than Standard's — no cover image at the top, body text at conversational size rather than full manuscript display typography (still Cormorant Garamond, per platform law, just not scaled up to feel like a long-form piece)
- No "last edited" or version indicator anywhere — reinforces the immutability at the reading surface too, not just at compose time

### Export (per `scribes_export_template_design_guide.md`)
- Reflections are exportable, same as Standard and Passage — the export template's existing body rules apply, with the same immutability note already established for Passage extended to cover Reflection: *"exported version is always a faithful, permanent snapshot"*
- Given a Reflection's brevity, most exports will be single-page — the multi-page rules in the export guide's §7 rarely trigger, but remain correct if a Reflection with a long scripture quote happens to span two pages

---

## 9. Non-Negotiables for This Feature

1. **500-character hard cap on body text, enforced at the database level**, not just client-side validation — per §2's constraint
2. **Immutable after publish.** No `post_versions` row, no edit endpoint — identical enforcement to Passage
3. **`reflection_image_url` is never used interchangeably with `cover_image_url`.** They are semantically and visually different — one is a hero banner, one is an inline attachment
4. **Scripture verse text, when present, is sourced from the Bible feature's real data** — same rule already established platform-wide, never re-typed by the author
5. **Counts against the same fair-use image allowance as panel images** — no new allowance category introduced for this

---

## 10. Done Criteria

### Backend
- [ ] `post_type = 'reflection'` accepted by `POST /posts`
- [ ] A Reflection body over 500 characters (plain text) is rejected with a clear 400 error
- [ ] A Reflection with `cover_image_url` set is rejected — must use `reflection_image_url`
- [ ] Any PATCH/PUT attempt on a published Reflection returns 405, confirmed by direct API call, not just UI behavior
- [ ] Reflection image uploads correctly land in `posts/reflections/` in R2 and count against the existing panel-image fair-use allowance

### Frontend
- [ ] Reflection composer is visually distinct from both Standard and Passage composers
- [ ] Character counter appears and updates correctly as the author approaches 500 characters
- [ ] The immutability notice is shown clearly before publish, not buried
- [ ] Feed card renders Reflection distinctly from Standard (no cover banner, compact layout)
- [ ] Post Detail for a Reflection shows no edit affordance and no version indicator
- [ ] Export produces a correct, faithful PDF for a Reflection carrying both a scripture quote and an image simultaneously

---

## 11. Updated Totals

| Metric | Before | After |
|---|---|---|
| Post types | 2 (Standard, Passage) | **3** (Standard, Passage, Reflection) |
| Migrations | 016 (Bible) | **017** |
| R2 bucket prefixes | 5 | **6** (`posts/reflections/` added) |
| New endpoints | — | **0** — reuses `POST /posts` with a new `post_type` value |

---

*Scribes Reflection Post Type Contract v1.0*
*Short-form · Immutable · Verse and image together, in one lightweight moment*