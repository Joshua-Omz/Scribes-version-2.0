# Scribes — Search & Recommendations System Design
**Version 2.0 · Revised with author intent and semantic layer**

> This replaces v1.0 entirely. All decisions reflect the author's confirmed intent: hashtag-style tag growth, title-first search priority, pgvector semantic layer, and engagement ratio index for recommendations.

---

## Part 1 — The Two Systems at a Glance

```
SEARCH                              RECOMMENDATIONS
──────                              ───────────────
User-initiated.                     Platform-initiated.
"Find me something specific."       "Here is what you should read next."

Stack:                              Stack:
  PostgreSQL tsvector (keyword)       Engagement ratio index (SQL)
  + pgvector (semantic)               + pgvector similarity (semantic)
  = hybrid search                     = hybrid recommendation

Priority order:                     Surfaces:
  1. Post title (caption) — A         Most Insightful
  2. Post body content — B            Most Thought-Provoking
  3. Keyword tags — C                 Most Affirmed (Amen)
  4. Semantic similarity              Trending (velocity)
                                      Similar to this post
```

---

## Part 2 — Tag System (Categories That Grow Like Hashtags)

### The decision: one database, hashtag behaviour

The instinct to separate categories into their own store is architecturally sound as a concept. The problem is operational: two databases in one write transaction creates a distributed consistency problem — if one write fails, the other does not automatically roll back unless you implement a two-phase commit, which is significant complexity for a lookup table.

**The resolution:** one PostgreSQL instance, hashtag-style tag growth. The separation you want is achieved through table design, not a separate database. Tags emerge from author usage — no Super Admin needed to create them.

### Schema

```sql
-- ── Tags — the growing hashtag pool ───────────────────
CREATE TABLE tags (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT        NOT NULL UNIQUE,  -- normalised: lowercase, trimmed, no spaces
    display_name  TEXT        NOT NULL,          -- original casing the author used first
    post_count    INT         NOT NULL DEFAULT 1,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for search and autocomplete
CREATE INDEX idx_tags_name       ON tags (name);
CREATE INDEX idx_tags_post_count ON tags (post_count DESC);
CREATE INDEX idx_tags_name_trgm  ON tags USING GIN (name gin_trgm_ops);
-- ^ trigram index enables partial-match autocomplete ("proph" → "prophecy")
-- Requires: CREATE EXTENSION pg_trgm;

-- ── Post ↔ Tag join ────────────────────────────────────
CREATE TABLE post_tags (
    post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id     UUID NOT NULL REFERENCES tags(id),
    PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_post_tags_tag  ON post_tags (tag_id);
CREATE INDEX idx_post_tags_post ON post_tags (post_id);

-- ── Tag upsert function ────────────────────────────────
-- Called when an author adds a tag to a post.
-- If the tag exists: increment post_count, update last_used_at.
-- If new: create it. Returns the tag ID.
CREATE OR REPLACE FUNCTION upsert_tag(
    p_name         TEXT,
    p_display_name TEXT
) RETURNS UUID AS $$
DECLARE
    v_id UUID;
    v_normalised TEXT := lower(trim(regexp_replace(p_name, '[^a-zA-Z0-9]', '', 'g')));
BEGIN
    INSERT INTO tags (name, display_name)
    VALUES (v_normalised, p_display_name)
    ON CONFLICT (name) DO UPDATE
        SET post_count   = tags.post_count + 1,
            last_used_at = now()
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
```

### Tag rules

| Rule | Enforcement |
|---|---|
| Lowercase normalised internally | `upsert_tag()` function |
| Display name preserves original casing | First author's casing is kept |
| Max 8 tags per post | Service layer validation |
| Max 30 characters per tag | Service layer validation |
| Only alphanumeric + no spaces | `regexp_replace` in `upsert_tag()` |
| Trending tags = most used in last 30 days | `ORDER BY last_used_at DESC, post_count DESC` |

### The tag compose experience

Authors type freely. The client queries `GET /tags/suggest?q=proph` as they type — returns matching tags with post counts. Selecting one attaches it. If their tag doesn't exist yet, it is created on post publish. Maximum 8 tags per post.

### Tag API endpoints

```
GET  /tags/suggest?q=partial      PUBLIC   — autocomplete (trigram match)
GET  /tags/:name/posts             PUBLIC   — all posts for a tag (paginated)
GET  /tags/trending                PUBLIC   — top 20 tags by recent usage
```

### Tag response shape

```json
GET /tags/suggest?q=proph
{
  "tags": [
    { "name": "prophecy",        "display_name": "Prophecy",        "post_count": 147 },
    { "name": "propheticword",   "display_name": "PropheticWord",   "post_count": 34  },
    { "name": "propheticseason", "display_name": "PropheticSeason", "post_count": 12  }
  ]
}
```

---

## Part 3 — Hybrid Search (tsvector + pgvector)

### Architecture

```
User query: "the silence of God in suffering"
                    │
        ┌───────────┴───────────┐
        │                       │
   KEYWORD PATH           SEMANTIC PATH
   (tsvector)             (pgvector)
        │                       │
   Weighted rank:          Embed query →
   Title (A)               vector similarity
   Content (B)             against posts.embedding
   Tags (C)                        │
        │                       │
        └───────────┬───────────┘
                    │
              Merge + re-rank
              (RRF or weighted sum)
                    │
              Return results
```

### Schema additions

```sql
-- Add to posts table (new migration: 014_search.up.sql)

-- Semantic embedding vector
-- 768 dimensions = all-MiniLM-L6-v2 output size
-- 1536 dimensions if using OpenAI text-embedding-3-small
ALTER TABLE posts
    ADD COLUMN embedding vector(768);

-- IVFFlat index for approximate nearest neighbour search
-- lists = sqrt(post_count) — start with 100, tune as data grows
CREATE INDEX idx_posts_embedding ON posts
    USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- Extended search_vector trigger — now includes tags
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        -- A: Title (caption) — highest priority
        setweight(to_tsvector('english', COALESCE(NEW.caption, '')), 'A') ||
        -- B: Body content (extracted plain text from JSONB)
        setweight(to_tsvector('english',
            COALESCE(NEW.content->>'text', '')), 'B') ||
        -- C: Sermon source / tags (tags appended at publish time via trigger or service)
        setweight(to_tsvector('english',
            COALESCE(NEW.sermon_source, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tags contribute to search_vector via a separate update
-- called after post_tags rows are inserted:
-- UPDATE posts SET search_vector = search_vector ||
--   setweight(to_tsvector('english', string_agg(t.name, ' ')), 'C')
-- FROM post_tags pt JOIN tags t ON t.id = pt.tag_id
-- WHERE pt.post_id = $post_id
-- This runs in the post publish transaction.
```

### The embedding pipeline

```go
// internal/search/embedding.go

// Embeddings are generated asynchronously after publish.
// The author does not wait for embedding generation.
// A post is fully published and readable before its embedding exists.

type EmbeddingService interface {
    Embed(ctx context.Context, text string) ([]float32, error)
}

// v1: local model via inference API (e.g. Ollama running all-MiniLM-L6-v2)
// v2: OpenAI text-embedding-3-small (very cheap — ~$0.02 per 1M tokens)
// The interface is the same regardless of provider.

// What gets embedded per post:
// caption + first 500 chars of body_text + tag names
// This keeps the embedding focused on meaning, not filler words.

// Embedding worker:
// On post publish → handler enqueues embedding job
// Worker goroutine picks up job → calls EmbeddingService.Embed()
// → UPDATE posts SET embedding = $vector WHERE id = $post_id
```

### The hybrid search query

```sql
-- name: HybridSearchPosts :many
-- Combines keyword rank (tsvector) with semantic similarity (pgvector)
-- using Reciprocal Rank Fusion to merge the two result sets.

WITH keyword_results AS (
    SELECT
        p.id,
        ts_rank(p.search_vector, query) AS kw_rank,
        ts_headline('english', p.caption, query,
            'MaxWords=12, MinWords=6, StartSel=<mark>, StopSel=</mark>'
        ) AS headline
    FROM posts p,
         plainto_tsquery('english', $1) query
    WHERE p.search_vector @@ query
      AND p.is_deleted = false
      AND p.visibility = 'public'
    ORDER BY kw_rank DESC
    LIMIT 20
),
semantic_results AS (
    SELECT
        id,
        1 - (embedding <=> $2::vector) AS sem_score
    FROM posts
    WHERE is_deleted = false
      AND visibility = 'public'
      AND embedding IS NOT NULL
    ORDER BY embedding <=> $2::vector
    LIMIT 20
),
-- Reciprocal Rank Fusion: score = 1 / (k + rank)
-- k=60 is standard. Merges two differently-scaled rankings fairly.
keyword_ranked AS (
    SELECT id, headline, row_number() OVER (ORDER BY kw_rank DESC) AS kw_position
    FROM keyword_results
),
semantic_ranked AS (
    SELECT id, row_number() OVER (ORDER BY sem_score DESC) AS sem_position
    FROM semantic_results
),
fused AS (
    SELECT
        COALESCE(k.id, s.id) AS id,
        COALESCE(k.headline, '') AS headline,
        (COALESCE(1.0 / (60 + k.kw_position), 0) +
         COALESCE(1.0 / (60 + s.sem_position), 0)) AS rrf_score
    FROM keyword_ranked k
    FULL OUTER JOIN semantic_ranked s ON k.id = s.id
)
SELECT
    p.id,
    p.caption,
    p.cover_image_url,
    p.post_type,
    p.published_at,
    p.author_id,
    f.headline,
    f.rrf_score
FROM fused f
JOIN posts p ON p.id = f.id
ORDER BY f.rrf_score DESC
LIMIT $3;
-- $1 = text query string
-- $2 = query embedding vector
-- $3 = limit (default 10)
```

### When embedding is not yet available

A post published seconds ago may not have an embedding yet. The search query handles this gracefully:

```sql
AND embedding IS NOT NULL
```

The semantic results simply don't include very new posts. The keyword results still find them immediately. No error, no degraded experience — the keyword path always works.

### Author search (separate, simpler)

```sql
-- name: SearchAuthors :many
SELECT
    id,
    handle,
    display_name,
    bio,
    similarity(display_name, $1) AS name_score
FROM users
WHERE (
    display_name ILIKE '%' || $1 || '%'
    OR handle ILIKE '%' || $1 || '%'
    OR to_tsvector('english', COALESCE(bio, ''))
       @@ plainto_tsquery('english', $1)
)
AND is_deleted = false
ORDER BY name_score DESC
LIMIT 5;
-- Uses pg_trgm similarity for fuzzy name matching
-- A search for "samuel" finds "Samuel Okonkwo" and "@samuel.o"
```

---

## Part 4 — Engagement Ratio Index (Recommendations)

### The index formula

```
engagement_ratio = (
    COUNT(amen)              * 1.0  +
    COUNT(insightful)        * 1.5  +
    COUNT(thought_provoking) * 2.0
) / NULLIF(
    EXTRACT(EPOCH FROM (now() - published_at)) / 86400.0,
    0
)
-- Denominator: days since published as a decimal
-- A post published 2.5 days ago divides by 2.5
-- This gives velocity — rising posts beat old popular posts
```

**Why the weights are 1.0 / 1.5 / 2.0:**

Amen is broad affirmation — low signal per reaction, high volume. Insightful is deliberate — it costs the reader a moment of reflection. Thought-Provoking is the deepest signal — it means the reader was genuinely challenged. The weights reflect the cognitive cost and intentionality behind each reaction.

### The four recommendation surfaces

Each surface is the same base query sorted differently:

```sql
-- name: GetRecommendationsByType :many
-- $1 = category_id filter (optional, NULL = all categories)
-- $2 = days window (90 for trending, 365 for all-time)
-- $3 = primary sort column ("amen_ratio" | "insightful_ratio" | "thoughtprovoking_ratio" | "overall_ratio")
-- $4 = limit

WITH engagement AS (
    SELECT
        p.id,
        p.caption,
        p.cover_image_url,
        p.post_type,
        p.published_at,
        p.author_id,

        -- Per-type counts
        COUNT(CASE WHEN r.type = 'amen'              THEN 1 END) AS amen_count,
        COUNT(CASE WHEN r.type = 'insightful'        THEN 1 END) AS insightful_count,
        COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) AS tp_count,

        -- Days since published (minimum 0.1 to avoid division by zero on same-day posts)
        GREATEST(
            EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0,
            0.1
        ) AS age_days

    FROM posts p
    LEFT JOIN reactions r
        ON r.post_id = p.id
        AND r.created_at > now() - ($2 || ' days')::INTERVAL
    LEFT JOIN post_categories pc ON pc.post_id = p.id
    WHERE p.is_deleted = false
      AND p.visibility = 'public'
      AND ($1::uuid IS NULL OR pc.category_id = $1)
    GROUP BY p.id
),
scored AS (
    SELECT
        *,
        -- Individual reaction velocity ratios
        (amen_count * 1.0)  / age_days AS amen_ratio,
        (insightful_count * 1.5) / age_days AS insightful_ratio,
        (tp_count * 2.0)    / age_days AS tp_ratio,

        -- Overall weighted velocity
        (amen_count * 1.0 + insightful_count * 1.5 + tp_count * 2.0) / age_days
            AS overall_ratio
    FROM engagement
)
SELECT * FROM scored
WHERE overall_ratio > 0  -- exclude posts with zero engagement
ORDER BY
    CASE $3
        WHEN 'amen_ratio'    THEN amen_ratio
        WHEN 'insightful'    THEN insightful_ratio
        WHEN 'prophetic'     THEN tp_ratio         -- thought_provoking = prophetic in context
        WHEN 'overall'       THEN overall_ratio
        ELSE overall_ratio
    END DESC
LIMIT $4;
```

### The four named surfaces

| Surface name | sort param | window | Description |
|---|---|---|---|
| Most Affirmed | `amen_ratio` | 90 days | Highest Amen velocity |
| Most Insightful | `insightful_ratio` | 90 days | Highest Insightful velocity |
| Prophetic of the Times | `prophetic` | 30 days | Highest Thought-Provoking velocity, shorter window emphasises recency |
| Trending | `overall` | 7 days | Overall weighted velocity, 7-day window = truly trending |

**"Prophetic of the Times"** gets a shorter 30-day window because prophetic content is by nature timely — it speaks to what is happening now. A 90-day window would dilute it with older content.

**Trending** uses a 7-day window — the tightest. A post needs to be rising fast right now, not just historically popular.

### Semantic "Similar to this post" (Post Detail)

```sql
-- name: GetSemanticallySimilarPosts :many
-- Uses pgvector cosine similarity against the viewed post's embedding

SELECT
    p.id,
    p.caption,
    p.cover_image_url,
    p.post_type,
    p.published_at,
    p.author_id,
    1 - (p.embedding <=> $2::vector) AS similarity
FROM posts p
WHERE p.id != $1
  AND p.is_deleted = false
  AND p.visibility = 'public'
  AND p.embedding IS NOT NULL
ORDER BY p.embedding <=> $2::vector
LIMIT 4;

-- $1 = current post ID (excluded)
-- $2 = current post's embedding vector (fetched once, reused)
```

This is semantically aware — a post about "the silence of God" will surface posts about "waiting on God", "unanswered prayer", and "dark night of the soul" even if those exact phrases aren't in the query. The vector captures meaning, not just words.

---

## Part 5 — Complete API Surface

### Search endpoints

```
GET  /search                       PUBLIC
     ?q=query string
     ?type=posts|authors|all       (default: all)
     ?tag=prophecy                 (filter to tag)
     ?limit=10
     Returns: { posts[], authors[], total_posts, total_authors }

GET  /search/suggestions           PUBLIC
     ?q=partial query
     Returns: { suggestions: string[] }
     Phase 1: not implemented (empty array returned, no error)
     Phase 2: trigram-based prefix match on tag names + post captions
```

### Tag endpoints

```
GET  /tags/suggest                 PUBLIC
     ?q=partial tag name
     Returns: { tags: [{ name, display_name, post_count }] }

GET  /tags/:name/posts             PUBLIC
     Paginated list of posts for a given tag
     Same post card shape as explore feed

GET  /tags/trending                PUBLIC
     Top 20 tags by (post_count DESC, last_used_at DESC) in 30-day window
```

### Recommendation endpoints

```
GET  /recommendations/most-insightful    PUBLIC   ?category=uuid&limit=10
GET  /recommendations/most-affirmed      PUBLIC   ?category=uuid&limit=10
GET  /recommendations/prophetic          PUBLIC   ?category=uuid&limit=10
GET  /recommendations/trending           PUBLIC   ?limit=10
GET  /posts/:id/similar                  PUBLIC   — semantic similarity, 4 posts
GET  /recommendations/for-you            PROTECTED — personalised, uses engagement history
```

**All recommendation endpoints are PUBLIC** except `/recommendations/for-you`. This is the outward principle: an unbeliever who finishes reading "On the Silence of God" should be offered "Most Insightful" posts without a login wall.

---

## Part 6 — Backend Package Structure

```
internal/
├── search/
│   ├── handler.go           — GET /search, GET /search/suggestions
│   ├── service.go           — hybrid query orchestration, RRF merge
│   ├── repository.go        — HybridSearchPosts, SearchAuthors queries
│   ├── embedding.go         — EmbeddingService interface + implementations
│   └── worker.go            — async embedding generation after publish
│
├── tag/
│   ├── handler.go           — GET /tags/suggest, /tags/:name/posts, /tags/trending
│   ├── service.go           — upsert logic, normalisation, max-8 enforcement
│   └── repository.go        — upsert_tag(), tag queries
│
└── recommendation/
    ├── handler.go           — 6 recommendation endpoints
    ├── service.go           — surface routing, personalisation logic
    └── repository.go        — GetRecommendationsByType, GetSemanticallySimilarPosts
```

### New wiring in `main.go`

```go
// Embedding service (choose one at deploy time via env var EMBEDDING_PROVIDER)
var embeddingSvc search.EmbeddingService
switch cfg.EmbeddingProvider {
case "ollama":
    embeddingSvc = search.NewOllamaEmbedder(cfg.OllamaURL)  // local, free
case "openai":
    embeddingSvc = search.NewOpenAIEmbedder(cfg.OpenAIKey)   // API, cheap
default:
    embeddingSvc = search.NewNoOpEmbedder()  // disables semantic search, keyword only
}

searchWorker := search.NewEmbeddingWorker(embeddingSvc, postRepo)
go searchWorker.Start(ctx)

searchRepo   := search.NewRepository(queries)
searchSvc    := search.NewService(searchRepo, embeddingSvc)
searchHandler := search.NewHandler(searchSvc)

tagRepo      := tag.NewRepository(queries)
tagSvc       := tag.NewService(tagRepo)
tagHandler   := tag.NewHandler(tagSvc)

recRepo      := recommendation.NewRepository(queries)
recSvc       := recommendation.NewService(recRepo)
recHandler   := recommendation.NewHandler(recSvc)
```

---

## Part 7 — New Migration (014_search.up.sql)

```sql
-- ═══════════════════════════════════════════════════════
-- MIGRATION 014: Search + Tags + Semantic layer
-- ═══════════════════════════════════════════════════════

-- Prerequisites
CREATE EXTENSION IF NOT EXISTS vector;    -- pgvector
CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- trigram for tag autocomplete

-- ── Semantic embedding column ──────────────────────────
ALTER TABLE posts
    ADD COLUMN embedding vector(768);

-- IVFFlat approximate nearest neighbour index
-- Adjust 'lists' as post count grows: lists ≈ sqrt(total_posts)
CREATE INDEX idx_posts_embedding
    ON posts USING ivfflat (embedding vector_cosine_ops)
    WITH (lists = 100);

-- ── Tag system ─────────────────────────────────────────
CREATE TABLE tags (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT        NOT NULL UNIQUE,
    display_name  TEXT        NOT NULL,
    post_count    INT         NOT NULL DEFAULT 1,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_tags_name       ON tags (name);
CREATE INDEX idx_tags_post_count ON tags (post_count DESC);
CREATE INDEX idx_tags_name_trgm  ON tags USING GIN (name gin_trgm_ops);

CREATE TABLE post_tags (
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  UUID NOT NULL REFERENCES tags(id),
    PRIMARY KEY (post_id, tag_id)
);

CREATE INDEX idx_post_tags_tag  ON post_tags (tag_id);
CREATE INDEX idx_post_tags_post ON post_tags (post_id);

-- Tag upsert function
CREATE OR REPLACE FUNCTION upsert_tag(
    p_name         TEXT,
    p_display_name TEXT
) RETURNS UUID AS $$
DECLARE
    v_id         UUID;
    v_normalised TEXT :=
        lower(trim(regexp_replace(p_name, '[^a-zA-Z0-9]', '', 'g')));
BEGIN
    INSERT INTO tags (name, display_name)
    VALUES (v_normalised, p_display_name)
    ON CONFLICT (name) DO UPDATE
        SET post_count   = tags.post_count + 1,
            last_used_at = now()
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- ── Extended search vector trigger ─────────────────────
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.caption, '')), 'A') ||
        setweight(to_tsvector('english',
            COALESCE(NEW.content->>'text', '')), 'B') ||
        setweight(to_tsvector('english',
            COALESCE(NEW.sermon_source, '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── Recommendation: engagement ratio index (materialised) ─
-- Refreshed every 6 hours by goroutine scheduler
-- Phase 1: refresh manually or on a cron; Phase 2: goroutine worker
CREATE MATERIALIZED VIEW post_engagement_scores AS
SELECT
    p.id AS post_id,
    COUNT(CASE WHEN r.type = 'amen'              THEN 1 END) AS amen_count,
    COUNT(CASE WHEN r.type = 'insightful'        THEN 1 END) AS insightful_count,
    COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) AS tp_count,
    GREATEST(
        EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0,
        0.1
    ) AS age_days,
    -- Pre-computed ratios
    (COUNT(CASE WHEN r.type = 'amen' THEN 1 END) * 1.0) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS amen_ratio,
    (COUNT(CASE WHEN r.type = 'insightful' THEN 1 END) * 1.5) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS insightful_ratio,
    (COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) * 2.0) /
        GREATEST(EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1)
        AS tp_ratio,
    (
        COUNT(CASE WHEN r.type = 'amen' THEN 1 END) * 1.0 +
        COUNT(CASE WHEN r.type = 'insightful' THEN 1 END) * 1.5 +
        COUNT(CASE WHEN r.type = 'thought_provoking' THEN 1 END) * 2.0
    ) / GREATEST(
        EXTRACT(EPOCH FROM (now() - p.published_at)) / 86400.0, 0.1
    ) AS overall_ratio
FROM posts p
LEFT JOIN reactions r ON r.post_id = p.id
WHERE p.is_deleted = false AND p.visibility = 'public'
GROUP BY p.id;

CREATE UNIQUE INDEX ON post_engagement_scores (post_id);
CREATE INDEX ON post_engagement_scores (overall_ratio DESC);
CREATE INDEX ON post_engagement_scores (amen_ratio DESC);
CREATE INDEX ON post_engagement_scores (insightful_ratio DESC);
CREATE INDEX ON post_engagement_scores (tp_ratio DESC);
```

## 014_search.down.sql

```sql
DROP MATERIALIZED VIEW IF EXISTS post_engagement_scores;
DROP FUNCTION IF EXISTS upsert_tag(TEXT, TEXT);
DROP TABLE IF EXISTS post_tags;
DROP TABLE IF EXISTS tags;
ALTER TABLE posts DROP COLUMN IF EXISTS embedding;
DROP EXTENSION IF EXISTS pg_trgm;
DROP EXTENSION IF EXISTS vector;
```

---

## Part 8 — Flutter Implementation

### Search screen

```dart
lib/features/search/
├── data/
│   ├── search_api.dart
│   └── search_repository.dart
├── domain/
│   └── search_result.dart
├── application/
│   └── search_notifier.dart      — 350ms debounce
└── presentation/
    ├── search_screen.dart
    ├── search_post_card.dart     — compact, shows headline snippet
    ├── search_author_card.dart
    └── tag_chip_row.dart         — trending tags on empty state
```

**Empty state (before typing):**

```
"What are you looking for?"

Trending tags (horizontal scrollable chips):
[Prophecy 147] [Grace 203] [Prayer 89] [Kingdom 156] ...

Tapping a tag chip pre-fills the search field and runs the query immediately.
```

**Result rendering priority — matches the search priority order:**

```
Search: "grace"

─── Posts (47) ──────────────────────────
[Card] On Grace — the misunderstood gift        ← title match (A weight)
       "...the grace of God is not permission..."  ← highlighted headline
[Card] The Cost of <mark>Grace</mark>
[Card] Unearned Favour                          ← semantic match (meaning of grace)
       ↑ this post never mentions "grace" but
         its embedding is close to the query

─── Authors (2) ─────────────────────────
[@grace.a]  Grace Adeyemi
[@gracelord] Grace Lord

See all 47 posts →
```

### Recommendation surfaces in the app

**Explore screen — four named sections:**

```
TRENDING THIS WEEK
[engagement: overall, 7d window, standard explore cards]

MOST INSIGHTFUL
[engagement: insightful_ratio, 90d, horizontal scroll strip]

PROPHETIC OF THE TIMES
[engagement: tp_ratio, 30d, horizontal scroll strip]

MOST AFFIRMED
[engagement: amen_ratio, 90d, horizontal scroll strip]
```

**Post Detail — "More on this theme" (semantic):**

```
After the comment section:

────────────────── ◆ ──────────────────
MORE ON THIS THEME

[4 horizontally scrollable mini-cards]
Rendered using pgvector similarity against the current post's embedding
```

---

## Part 9 — New Environment Variables

```bash
# Embedding provider (choose one)
EMBEDDING_PROVIDER=ollama          # local, free — use during development
EMBEDDING_PROVIDER=openai          # API — use in production

# Ollama (local)
OLLAMA_URL=http://localhost:11434
OLLAMA_MODEL=all-minilm             # 768-dim embeddings, fast, small

# OpenAI (production)
OPENAI_API_KEY=sk-...
OPENAI_EMBEDDING_MODEL=text-embedding-3-small  # 1536-dim, ~$0.02/1M tokens
```

**Cost estimate for OpenAI embeddings at 3M users:**
- Average post body: ~500 tokens
- At 1000 new posts/day: 500,000 tokens/day
- At $0.02/1M tokens: $0.01/day — essentially free

---

## Part 10 — Updated Total Counts

| Metric | Previous | After this design |
|---|---|---|
| Endpoints | 58 | 58 + 9 new = **67 endpoints** |
| Tables | 28 | 28 + 2 (tags, post_tags) = **30 tables** |
| Materialized views | 1 | 1 + 1 (post_engagement_scores) = **2** |
| Migrations | 013 | + 014 = **14 migrations** |

---

*Scribes Search & Recommendations System Design v2.0*
*Hybrid tsvector + pgvector search · Hashtag-style tags · Engagement ratio index*
*One database · 67 endpoints · 30 tables · 14 migrations*