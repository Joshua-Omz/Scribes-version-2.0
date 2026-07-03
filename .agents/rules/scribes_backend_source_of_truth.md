# Scribes — Backend Source of Truth
**Version 1.0 · Single reference document for backend development**

> This document is the authority. If a future decision conflicts with something written here, either the new decision is wrong, or this document needs to be explicitly updated — never silently overridden in code.

---

## 1. What Scribes Is

Scribes is a knowledge publishing and preservation platform for believers to compose, preserve, and share spiritual insights. Published content is treated as a durable, traceable knowledge artifact — not a disposable social post.

**Strategic note:** Scribes has an outward evangelistic purpose. Public-facing read surfaces must remain open to unauthenticated visitors with zero friction. This affects backend design: public GET endpoints (Post Detail, Public Profile, Explore) must never require auth.

---

## 2. Core Principles (Backend Implications)

| Principle | What it means for the backend |
|---|---|
| **Versioned transparency, not strict immutability** | Posts can be revised. Every revision snapshots the prior version into `post_versions` before overwriting. Snapshots are never updated or deleted. |
| **Traceability** | Every Post always has an `author_id`. On account deletion, the user row is soft-deleted and anonymised — the Post row is untouched. |
| **No in-product AI (v1 scope exclusion, not identity)** | No AI-powered endpoints in v1. Do not build hooks for it either — premature abstraction. |
| **Minimalist analytics** | Only `reactions` and `comments` are ever counted or stored as engagement signals. No view counts, no read-time tracking, no implicit signals — anywhere, including internal admin tooling. |
| **Quiet asymmetric following** | No follower/following counts in any API response, public or private. Counts are never computed, let alone exposed. |
| **Server is the source of truth for time and order** | Client timestamps are NEVER trusted for ordering. All sequencing uses a Postgres-assigned `server_sequence` (via `nextval()`). |

---

## 3. Technology Stack — Fixed Decisions

| Layer | Choice | Do not substitute without explicit reason |
|---|---|---|
| Language | Go (Golang) | — |
| HTTP Router | Gin | — |
| DB Access | sqlc (typed SQL, generated Go) | Never write raw `database/sql` queries by hand outside `db/generated` |
| Database | PostgreSQL | JSONB for rich text payloads |
| Migrations | golang-migrate | One numbered file per schema change, forward-only |
| Auth | JWT (golang-jwt/jwt/v5), HS256 | No OAuth/SSO in v1 |
| Password hashing | bcrypt, cost factor 12 | — |
| Containerization | Docker + Docker Compose | api + postgres services |
| Background jobs | Native Go goroutines + buffered channels | No external queue (Kafka/RabbitMQ) in v1 |
| Client (for context) | Flutter — Riverpod + Drift (SQLite) | Web compiles to Wasm |

---

## 4. System Architecture (One Diagram)

```
Flutter Client (Web/Mobile)
        │  HTTPS / REST / JSON
        ▼
Go API (Gin router)
  handler/  →  service/  →  repository/  →  db/generated (sqlc)
        │
        ├──▶ PostgreSQL (single source of truth)
        └──▶ goroutine workers (notifications, retention)
```

No microservices. No message queue. No Redis. No Elasticsearch. These are deliberately excluded at this stage — see `system-design-rationale` section below if revisiting this decision.

**Why this is enough:** One team, one codebase, no measured scaling problem yet. Splitting into services now would cost weeks of infra work to solve problems Scribes doesn't have. Revisit only when a specific, measured bottleneck justifies it.

---

## 5. Folder Architecture — Feature-Based with Repository Layer

```
scribes-api/
├── cmd/api/main.go                 — bootstrap: config → db → routes → workers → serve
├── internal/
│   ├── config/                     — typed Config struct from env
│   ├── server/router.go            — Gin setup, mounts every feature's routes
│   ├── middleware/                 — auth.go, require_role.go, ratelimit.go, logger.go
│   ├── db/
│   │   ├── generated/              — sqlc output. NEVER hand-edited.
│   │   ├── query/                  — hand-written SQL, one file per feature
│   │   └── sqlc.yaml
│   │
│   ├── auth/        {handler.go, service.go, repository.go}
│   ├── note/         {handler.go, service.go, repository.go}
│   ├── draft/         {handler.go, service.go, repository.go}
│   ├── post/         {handler.go, service.go, repository.go}
│   ├── sync/         {handler.go, service.go, repository.go}
│   ├── social/       {handler.go, service.go, repository.go}  — follows, reactions, comments, saved
│   ├── feed/         {handler.go, service.go, repository.go}  — feed, explore, categories
│   ├── message/      {handler.go, service.go, repository.go}
│   ├── notification/ {handler.go, service.go, repository.go, worker.go}
│   ├── admin/        {handler.go, service.go, repository.go}
│   └── profile/      {handler.go, service.go, repository.go}
│
├── pkg/                            — no Scribes domain types allowed here
│   ├── token/jwt.go
│   ├── password/bcrypt.go
│   ├── respond/json.go
│   ├── pagination/cursor.go
│   └── mention/parse.go
│
├── migrations/                     — one numbered file per sprint that touches schema
└── test/
    ├── integration_test.go
    └── testutil/db.go
```

### Import rules (strict — a linter or code reviewer should enforce these)

| From | May import | Must NOT import |
|---|---|---|
| `handler.go` | own `service.go` only | `repository.go`, `db/generated`, other features' internals |
| `service.go` | own `repository.go`, other features' **service** (for cross-feature calls), `pkg/` | `db/generated` directly |
| `repository.go` | `db/generated` only | nothing else |
| `worker.go` | own feature's `repository.go` | — |
| `middleware/` | `pkg/token`, `config` | feature packages |

**Cross-feature calls** (e.g. `draft.Service` calling `post.Service.Create()`) happen by injecting the dependency in the constructor, wired in `main.go`. Never reach into another feature's repository directly.

---

## 6. Database — Full Schema Reference

### users
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
handle          TEXT UNIQUE NOT NULL          -- permanent, never editable
display_name    TEXT NOT NULL
email           TEXT UNIQUE NOT NULL
password_hash   TEXT NOT NULL
bio             TEXT
role            user_role NOT NULL DEFAULT 'standard'   -- enum: standard | super_admin
is_deleted      BOOLEAN NOT NULL DEFAULT false
created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
```

### notes
```sql
id               UUID PRIMARY KEY DEFAULT gen_random_uuid()
author_id        UUID NOT NULL REFERENCES users(id)
content          JSONB NOT NULL
title            TEXT                          -- optional, often blank
notebook_id      UUID REFERENCES notebooks(id)
source_type      note_source_type              -- enum: sermon | study | received | personal | NULL
source_label     TEXT                          -- e.g. "Pastor Adeyemi · 14 Jun 2026"
server_sequence  BIGINT NOT NULL DEFAULT nextval('global_sequence')
updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
```

### notebooks
```sql
id          UUID PRIMARY KEY DEFAULT gen_random_uuid()
owner_id    UUID NOT NULL REFERENCES users(id)
name        TEXT NOT NULL
created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
```

### drafts
```sql
id               UUID PRIMARY KEY DEFAULT gen_random_uuid()
author_id        UUID NOT NULL REFERENCES users(id)
content          JSONB NOT NULL
caption          TEXT
category_ids     UUID[]
scripture_refs   JSONB                         -- array of {book, chapter, verse_start, verse_end}
server_sequence  BIGINT NOT NULL DEFAULT nextval('global_sequence')
created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
```

### posts
```sql
id                 UUID PRIMARY KEY DEFAULT gen_random_uuid()
author_id          UUID NOT NULL REFERENCES users(id)
content            JSONB NOT NULL
caption            TEXT
visibility         post_visibility NOT NULL DEFAULT 'public'   -- enum: public | private
current_version    INT NOT NULL DEFAULT 1
is_correction      BOOLEAN NOT NULL DEFAULT false
corrects_post_id   UUID REFERENCES posts(id)
sermon_source      TEXT
is_deleted         BOOLEAN NOT NULL DEFAULT false
server_sequence    BIGINT NOT NULL DEFAULT nextval('global_sequence')
published_at       TIMESTAMPTZ NOT NULL DEFAULT now()
```

### post_versions  (immutable — INSERT only, never UPDATE/DELETE)
```sql
id                 UUID PRIMARY KEY DEFAULT gen_random_uuid()
post_id            UUID NOT NULL REFERENCES posts(id)
version_number     INT NOT NULL
content_snapshot   JSONB NOT NULL
snapshotted_at     TIMESTAMPTZ NOT NULL DEFAULT now()
snapshotted_by     UUID NOT NULL REFERENCES users(id)
```

### categories
```sql
id              UUID PRIMARY KEY DEFAULT gen_random_uuid()
name            TEXT NOT NULL UNIQUE
is_deprecated   BOOLEAN NOT NULL DEFAULT false
-- write access: SUPER_ADMIN only, enforced at service layer
```

### post_categories  (join table)
```sql
post_id      UUID NOT NULL REFERENCES posts(id)
category_id  UUID NOT NULL REFERENCES categories(id)
PRIMARY KEY (post_id, category_id)
```

### scripture_refs
```sql
id            UUID PRIMARY KEY DEFAULT gen_random_uuid()
post_id       UUID NOT NULL REFERENCES posts(id)
book          TEXT NOT NULL
chapter       INT NOT NULL
verse_start   INT NOT NULL
verse_end     INT
```

### follows
```sql
follower_id  UUID NOT NULL REFERENCES users(id)
followee_id  UUID NOT NULL REFERENCES users(id)
created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
PRIMARY KEY (follower_id, followee_id)
-- NEVER expose counts derived from this table in any API response
```

### reactions
```sql
id        UUID PRIMARY KEY DEFAULT gen_random_uuid()
post_id   UUID NOT NULL REFERENCES posts(id)
user_id   UUID NOT NULL REFERENCES users(id)
type      reaction_type NOT NULL   -- enum: amen | insightful | thought_provoking
UNIQUE (post_id, user_id)          -- one reaction per user per post
```

### comments
```sql
id          UUID PRIMARY KEY DEFAULT gen_random_uuid()
post_id     UUID NOT NULL REFERENCES posts(id)
author_id   UUID NOT NULL REFERENCES users(id)
body        TEXT NOT NULL
is_hidden   BOOLEAN NOT NULL DEFAULT false   -- set by post author
is_deleted  BOOLEAN NOT NULL DEFAULT false
mentions    UUID[]                            -- resolved @handle → user_id list
created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
```

### saved  (bookmarks + imports)
```sql
id         UUID PRIMARY KEY DEFAULT gen_random_uuid()
user_id    UUID NOT NULL REFERENCES users(id)
post_id    UUID NOT NULL REFERENCES posts(id)
type       saved_type NOT NULL   -- enum: bookmark | import
snapshot   JSONB                 -- only populated for type = import
created_at TIMESTAMPTZ NOT NULL DEFAULT now()
```

### conversations / message_requests / messages
```sql
conversations:
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid()
  user_a_id   UUID NOT NULL REFERENCES users(id)
  user_b_id   UUID NOT NULL REFERENCES users(id)
  blocked     BOOLEAN NOT NULL DEFAULT false
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()

message_requests:
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid()
  from_user_id UUID NOT NULL REFERENCES users(id)
  to_user_id   UUID NOT NULL REFERENCES users(id)
  status       request_status NOT NULL DEFAULT 'pending'   -- pending | approved | rejected
  first_message TEXT NOT NULL
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()

messages:
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid()
  conversation_id  UUID NOT NULL REFERENCES conversations(id)
  sender_id        UUID NOT NULL REFERENCES users(id)
  body             TEXT NOT NULL
  is_deleted       BOOLEAN NOT NULL DEFAULT false
  sent_at          TIMESTAMPTZ NOT NULL DEFAULT now()
  -- retention: purged after 12 months of conversation inactivity (background job)
```

### notifications
```sql
id            UUID PRIMARY KEY DEFAULT gen_random_uuid()
recipient_id  UUID NOT NULL REFERENCES users(id)
type          notif_type NOT NULL   -- enum: mention | reaction | comment | follow | admin_alert
ref_id        UUID NOT NULL          -- polymorphic — points to comment/post/etc
is_realtime   BOOLEAN NOT NULL       -- mention & admin_alert = true, rest = false
is_read       BOOLEAN NOT NULL DEFAULT false
sent_at       TIMESTAMPTZ
created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
```

### Global sequence (used by ALL syncable tables)
```sql
CREATE SEQUENCE global_sequence;
-- notes, drafts, posts all default server_sequence to nextval('global_sequence')
-- This is what makes delta sync correct — one monotonic counter, never the client clock.
```

---

## 7. The Sync Protocol — Non-Negotiable Rules

This is the single most security/correctness-critical piece of the backend.

1. **The client clock is NEVER trusted for ordering.** Every syncable row (notes, drafts, posts) gets its `server_sequence` from `nextval('global_sequence')` — assigned by Postgres, not sent by the client.
2. **`GET /sync?seq=N`** returns every row WHERE `server_sequence > N` AND `owner = caller`. The `owner = caller` filter is mandatory and must be unit tested in isolation — a missing filter here leaks one user's private data to another.
3. **`POST /sync/push`** accepts bulk upserts of client-local-only records, assigns each a fresh `server_sequence`, and returns the mapping back to the client.
4. **Conflict policy for v1: last-write-wins**, using the server's `updated_at`. This is a deliberate, documented simplification — not an oversight. Revisit only if/when collaborative editing becomes a real feature.

---

## 8. API Surface — Grouped by Feature

```
AUTH            POST   /auth/register
                POST   /auth/login

NOTE            GET    /notes
                POST   /notes
                PATCH  /notes/:id
                DELETE /notes/:id
                POST   /notes/:id/promote        → creates Draft

DRAFT           POST   /drafts
                PATCH  /drafts/:id
                DELETE /drafts/:id
                POST   /drafts/:id/publish       → creates Post

POST            GET    /posts/:id                ← PUBLIC, no auth required
                PATCH  /posts/:id/revise
                DELETE /posts/:id
                POST   /posts/:id/correction
                GET    /posts/:id/versions
                GET    /posts/:id/export?format=md|txt

SYNC            GET    /sync?seq=N
                POST   /sync/push

SOCIAL          POST   /users/:id/follow
                DELETE /users/:id/follow
                POST   /posts/:id/react
                GET    /posts/:id/comments
                POST   /posts/:id/comments
                PATCH  /comments/:id/hide
                DELETE /comments/:id
                POST   /saved

FEED            GET    /feed                     (auth required — following feed)
                GET    /explore                   ← PUBLIC, no auth required
                GET    /categories                ← PUBLIC

MESSAGE         POST   /messages/request
                PATCH  /messages/request/:id
                POST   /conversations/:id/messages
                DELETE /messages/:id
                POST   /conversations/:id/block

NOTIFICATION    GET    /notifications

ADMIN           GET    /admin/reports             (SUPER_ADMIN only)
                PATCH  /admin/content/:id/action
                POST   /admin/categories
                PATCH  /admin/categories/:id/deprecate

PROFILE         GET    /users/:handle             ← PUBLIC, no auth required
                DELETE /account

HEALTH          GET    /health                    ← PUBLIC
```

**Rule:** any endpoint marked PUBLIC must work with zero `Authorization` header. This is not optional — it's the technical backbone of the outward evangelism principle.

---

## 9. Sprint Plan — 9 Weeks, 1 Sprint/Week

| # | Sprint | Feature folder(s) touched | Migration |
|---|---|---|---|
| 1 | Foundation & Auth | `auth/`, `middleware/` | `001_users.sql` |
| 2 | Notes, Drafts, Post creation | `note/`, `draft/`, `post/` | `002_content.sql` |
| 3 | Post versioning & corrections | `post/` | `003_versioning.sql` |
| 4 | Offline sync | `sync/` | `004_sync.sql` (adds `server_sequence` + global sequence) |
| 5 | Follows, reactions, comments | `social/` | `005_social.sql` |
| 6 | Feed, explore, categories | `feed/` | `006_feed.sql` |
| 7 | Direct messaging | `message/` | `007_dm.sql` |
| 8 | Notifications & admin | `notification/`, `admin/` | `008_notifications.sql` |
| 9 | Export, profiles, hardening | `profile/`, integration tests | — |

Each sprint's done-criteria and detailed task breakdown follows the same shape as the Sprint 1 plan (see §10). Do not start a sprint's tasks until the prior sprint's done-criteria all pass.

---

## 10. Sprint 1 — Detailed (Reference Pattern for All Sprints)

**Scope:** `POST /auth/register`, `POST /auth/login`, JWT middleware, `RequireRole` guard, users table, `GET /health`, working Docker Compose.

**Explicitly out of scope:** password reset, email verification, OAuth/SSO, refresh tokens, token revocation, rate limiting (Sprint 9), profile update.

**Key decisions:**
- JWT: `golang-jwt/jwt/v5`, HS256, 7-day expiry (configurable via `JWT_EXPIRY_HOURS`)
- Claims: `user_id`, `role`, standard `exp` — nothing else
- bcrypt cost: 12
- ctx key: unexported `type ctxKey struct{}` — never a string key
- Login always returns generic "invalid credentials" on any failure — never confirms whether an email exists
- Login runs bcrypt even on email-not-found (timing attack mitigation) using a pre-hashed dummy value

**Done criteria:**
- [ ] `docker compose up` starts cleanly, migrations run, `/health` returns 200
- [ ] Register creates a user, returns token; duplicate email/handle → 409
- [ ] Login with correct creds → token; wrong password or unknown email → 401 (identical response)
- [ ] A stub protected route returns 401 with no token, 200 with valid token
- [ ] `RequireRole` returns 403 for a standard user hitting a super_admin route
- [ ] `password_hash` never appears in any API response
- [ ] Expired token → 401, not 500

*(Sprints 2–9 follow this exact pattern: scope / out-of-scope / key decisions / done criteria. Generate each sprint's detail just before starting it, not all up front — requirements sharpen as earlier sprints complete.)*

---

## 11. Non-Negotiable Engineering Rules

1. **Never write raw SQL in Go code.** All queries go through `db/query/*.sql` → `sqlc generate` → `db/generated`.
2. **Never put business logic in a handler.** If you're writing an `if` that isn't HTTP-parsing or error-to-status mapping, it belongs in `service.go`.
3. **Every migration is forward-only and numbered.** Never edit a migration that has already run anywhere.
4. **`post_versions` rows are never updated or deleted.** Enforce this at the repository layer — no `UPDATE`/`DELETE` query should exist for this table.
5. **Public endpoints (marked PUBLIC in §8) must work with zero auth header.** Test this explicitly, not just "it works when I'm logged in."
6. **No follower/following counts, ever, anywhere** — not even in admin tooling.
7. **No view counts, read-time tracking, or implicit engagement signals** — anywhere in the schema or codebase. The only engagement signals that exist are `reactions` and `comments`.
8. **`server_sequence` is always assigned server-side** via `nextval('global_sequence')`. A client-supplied sequence value must be rejected, not just ignored.
9. **Sync's `owner = caller` filter is mandatory** on `GetDelta` and must have a dedicated unit test before any other sync work proceeds.
10. **The deletion asymmetry is intentional:** Posts persist (anonymised), Notes/Drafts/Messages are purged. Don't "fix" this without a product conversation — it traces directly to the SRS's Orphaned Posts policy.

---

## 12. Open Items (Deferred Past v1 — Do Not Build Now)

- Community-proposed taxonomy (v1 = Super Admin only)
- AI-powered features (semantic search, auto-tagging, recommendations)
- Real-time collaborative post editing / proper conflict resolution beyond last-write-wins
- Native media hosting (v1 = external URL preview cards only)
- Refresh tokens / token revocation
- Redis caching, Elasticsearch, message queues, microservices — revisit only with a measured, specific bottleneck

---

*This document is the single source of truth for Scribes backend development. Update it explicitly when a decision changes — do not let implementation drift silently away from what's written here.*
