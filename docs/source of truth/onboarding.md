# Scribes — Onboarding Document
**Version 1.0 · For new contributors, collaborators, and team members**

> This document is the entry point for anyone joining the Scribes project. It consolidates what Scribes is, why it exists, how it is built, and how to orient yourself within the codebase and product decisions already made. Read it before reading anything else. It will tell you which document to read next.

---

## 1. What Scribes Is

Scribes is a spiritual knowledge publishing and preservation platform. It exists for believers to compose, preserve, and share the insights, meditations, charges, and questions that emerge from genuine encounter with God — so that every person, believer or not, may taste the knowledge of the Lord.

Every published post on Scribes is treated as a **durable knowledge artifact** — not a social media update. It carries its author's name permanently. It cannot be silently altered. It is open to anyone who wants to read it.

### The mission in one sentence
> That everyone gets a taste of the Word of God — in the form of excerpts, ideas, meditations, and charges used to nourish and bless people.

### The vision in one verse
> *"For the earth will be filled with the knowledge of the glory of the Lord, as the waters cover the sea."*
> — Habakkuk 2:14

Scribes is one instrument in that filling. Every post is a drop. Every reader is the sea receiving it.

### The strategic intent
Scribes is built by believers, for believers — but its public face is open to everyone. The platform is designed so that an unbeliever who encounters a Scribes post may feel, before anything else, that what they are reading is worth reading. The word does the evangelism. The platform refuses to get in the way.

---

## 2. What Has Already Been Decided

Scribes is not a greenfield project for a new contributor. Significant architecture, design, and product decisions have already been made and documented. A new contributor does not re-litigate these decisions — they work within them, and propose changes through an explicit update to the relevant source-of-truth document.

### Decisions that are final for v1

| Area | Decision |
|---|---|
| Backend language | Go (Gin framework) |
| Database | PostgreSQL with JSONB for rich text |
| DB access | sqlc (typed generated queries) |
| Migrations | golang-migrate, forward-only, one file per sprint |
| Auth | JWT (golang-jwt/jwt/v5), HS256, 7-day expiry |
| Frontend | Flutter (Dart) — Web (Wasm) + Mobile (iOS/Android) |
| State management | Riverpod |
| Local storage | Drift (SQLite) |
| HTTP client | Dio |
| Routing | go_router |
| Folder architecture | Feature-based vertical slices (both backend and frontend) |
| Theming | Three themes: Night · Parchment · Silver |
| Display typeface | Cormorant Garamond |
| Body/UI typeface | DM Sans |
| Engagement signals | Reactions and comments only — no view counts, ever |
| Follow counts | Never exposed, never computed in responses |
| Immutability | Versioned transparency (not strict) — revisions snapshot prior versions |
| Sync strategy | Server-assigned monotonic sequence, never client clock |
| AI features | Out of scope for v1 |
| Infrastructure | Single Go API + PostgreSQL + Docker, horizontally scalable |
| **Monetization** | **None. No subscriptions, no tiers, no payment processing, no premium features. Every user has identical access. A single fair-use allowance on image/sound uploads exists only to prevent storage abuse — it is not a paid tier.** |
| Search | Hybrid PostgreSQL tsvector (keyword) + pgvector (semantic) |
| Recommendations | Engagement ratio index — reactions/comments only, no implicit signals |
| Media storage | Cloudflare R2 — single bucket, five path prefixes |
| Bible | Self-hosted BSB (Berean Standard Bible), public domain, imported once |

---

## 3. The Document Map

Every major decision in this project lives in one of these documents. Read the ones relevant to your role before writing a line of code.

### For everyone
| Document | What it contains |
|---|---|
| `scribes_onboarding.md` | This file — start here |
| `scribes_backend_source_of_truth.md` | Core principles, full DB schema, API surface, engineering rules |
| `scribes_migrations_source_of_truth.md` | All SQL migrations per sprint, with rationale |

### For backend contributors
| Document | What it contains |
|---|---|
| `scribes_sprint_plan.md` | 9-sprint backend plan, done-criteria per sprint, endpoint auth reference, main.go wiring |
| `scribes_agent_rules.md` | Mandatory 13-step workflow chain for every sprint |
| `scribes_backend_scaffold_prompt.md` | Sprint 1 scaffolding prompt for coding agents |

### For frontend contributors
| Document | What it contains |
|---|---|
| `scribes_frontend_guide.md` | Tech stack, design tokens in Dart, folder architecture, state management pattern, offline sync, unverified assumption list |
| `scribes_frontend_sprint_plan.md` | 9-sprint Flutter client plan, screen-to-endpoint mapping, done-criteria |

### For design and product contributors
| Document | What it contains |
|---|---|
| `scribes_design_brief.md` | Full design language — three themes, typography, ornamental system, component behaviour notes, Stitch prompt templates |
| `scribes_landing_aesthetic_laws.md` | 37 inviolable laws governing the landing page — colour, typography, layout, motion, copy, and forbidden elements |
| `scribes_qa_checklist.md` | 13-section QA and hardening checklist — functional + aesthetic requirements per screen |

### For DevOps and infrastructure
| Document | What it contains |
|---|---|
| `scribes_backend_source_of_truth.md` §3 | Fixed technology stack |
| `scribes_sprint_plan.md` §main.go wiring | Container and service startup sequence |
| Scale planning (in conversation history) | Railway free tier ceiling, 3M user architecture, scaling sequence |

### For feature expansion work (post-v1 additions)
These documents extend the original 43-endpoint v1 surface. Read the source-of-truth documents above first — these build on them, not replace them.

| Document | What it contains |
|---|---|
| `scribes_media_migration_v2.md` | Migrations 010–013: cover images, passage panels, sound pool, fair-use allowance (supersedes v1 which included billing — billing was removed) |
| `scribes_media_contracts_v2.md` | Full implementation contract for cover images, Passage post type, sound pool, and R2 fair-use rate limiting (no billing) |
| `scribes_r2_storage_contract.md` | The single `internal/storage/` service used by every feature that stores a file — avatars, post covers, panel images, sounds |
| `scribes_search_recommendations_v2.md` | Hybrid search (tsvector + pgvector), hashtag-style tag system, engagement ratio index recommendations (supersedes v1) |
| `scribes_bible_drawer_contract.md` | Self-hosted Bible (BSB), quick-read scripture tap, the Bible Drawer feature |
| `scribes_notification_contract.md` | Full backend + frontend contract for the two-path notification system |

**Note on versioned documents:** where a `_v2` file exists, it fully supersedes its predecessor. Do not implement from the v1 version of `scribes_media_migration.md`, `scribes_media_contracts.md`, or `scribes_search_recommendations.md` — they are kept only for historical record of the design conversation that led to the v2 decisions.

---

## 4. The Codebase Structure

### Backend (`scribes-api/`)

```
scribes-api/
├── cmd/api/main.go              — bootstrap entry point
├── internal/
│   ├── config/                  — typed env config
│   ├── server/router.go         — Gin router, all route groups
│   ├── middleware/              — JWT, role guard, rate limit, logger
│   ├── db/
│   │   ├── query/               — hand-written SQL (edit these)
│   │   ├── generated/           — sqlc output (never edit)
│   │   └── sqlc.yaml
│   ├── auth/                    — handler · service · repository · model
│   ├── note/                    — handler · service · repository · model
│   ├── draft/                   — handler · service · repository · model
│   ├── post/                    — handler · service · repository · model
│   ├── sync/                    — handler · service · repository · model
│   ├── social/                  — handler · service · repository · model
│   ├── feed/                    — handler · service · repository · model
│   ├── message/                 — handler · service · repository · model
│   ├── notification/            — handler · service · repository · worker
│   ├── admin/                   — handler · service · repository
│   └── profile/                 — handler · service · repository · model
├── pkg/
│   ├── token/jwt.go             — Sign · Parse · Claims
│   ├── password/bcrypt.go       — Hash · Compare
│   ├── respond/json.go          — JSON · Error helpers
│   ├── pagination/cursor.go     — keyset cursor
│   └── mention/parse.go         — @handle → user_id resolution
├── migrations/                  — 001 through 009
└── test/                        — integration tests + testutil
```

**The import rule in one line:** `handler` → `service` → `repository` → `db/generated`. Nothing flows backwards. Features talk to each other only through injected service interfaces, never through each other's repositories.

### Frontend (`scribes-app/`)

```
lib/
├── main.dart
├── core/
│   ├── theme/                   — ScribesColors · ScribesTextStyles · ScribesRadius
│   ├── router/                  — go_router config + route name constants
│   ├── network/                 — ApiClient (dio) · ApiException · endpoints.dart
│   ├── storage/                 — Drift schema · SecureStorage JWT
│   └── widgets/                 — shared design-system components
├── features/
│   ├── auth/                    — data · domain · application · presentation
│   ├── note/
│   ├── draft/
│   ├── post/
│   ├── feed/
│   ├── social/
│   ├── message/
│   ├── notification/
│   ├── profile/
│   └── settings/
```

**The import rule in one line:** `presentation` → `application` → `domain` ← `data`. Presentation never imports data directly. Data never imports other features' data.

---

## 5. The Content Model — How Posts Come to Exist

This is the single most important product concept to understand before building anything.

```
PRIVATE CAPTURE         STAGING              PUBLISHED ARTIFACT
─────────────          ─────────            ──────────────────
   Note          →       Draft        →           Post
(private,              (private,              (public, durable,
 plain text,            rich text,             permanent author
 never published        not yet               attribution,
 directly)              committed)             open to all)
```

**Notes** are reception vessels — where a believer captures what they received. A sermon line that stayed with them. A 2am impression. A verse that meant something different today. Plain text. No formatting. Often no title. Most notes never become posts. That is correct.

**Drafts** are the refinement stage. An author promotes a Note to a Draft when they are ready to shape something for others. Full rich text. Categories. Scripture references. Still private.

**Posts** are the published artifact. Once published, the content is versioned — a revision snapshots the prior version immutably before overwriting. The post carries the author's name permanently. If the author deletes their account, the post remains, attributed to `[Deleted Author]`.

---

## 6. The Three Themes

Every screen in Scribes adapts to the user's chosen theme. Themes are switched in Settings and take effect immediately without restarting.

| Theme | Atmosphere | Background | Primary accent |
|---|---|---|---|
| **Night** | The manuscript read by candlelight | `#0C0A08` | Gold `#C9A84C` |
| **Parchment** | The manuscript in afternoon light | `#F5F0E8` | Gold `#9A7020` |
| **Silver** | The manuscript in a modern archive | `#F2F2F4` | Gold `#B08A2A` |

All three themes share the same layout, typography, and ornamental system. Only the colour values change. A new contributor should never hardcode a colour — always use the theme extension tokens.

---

## 7. The Twelve Screens

| Screen | Public access | Auth required |
|---|---|---|
| Splash | ✅ | — |
| Auth Gate (Register / Login) | ✅ | — |
| Onboarding — Topic Selection | — | ✅ First login only |
| Primary Feed | — | ✅ |
| Explore | ✅ | — |
| Post Detail | ✅ | Interactions only |
| Compose | — | ✅ |
| Notes | — | ✅ |
| Profile (public state) | ✅ | — |
| Profile (private state) | — | ✅ |
| Notifications | — | ✅ |
| Direct Messages | — | ✅ |
| Settings | — | ✅ |

The three public screens (Explore, Post Detail, public Profile) are the outward face of Scribes. They are the screens an unbeliever may encounter. They must render fully with zero Authorization header. No exceptions.

---

## 8. The 43 Endpoints

A quick reference. Full detail including request/response shapes belongs in `scribes_backend_source_of_truth.md`.

```
PUBLIC (no auth)
  GET  /health
  POST /auth/register
  POST /auth/login
  GET  /posts/:id
  GET  /posts/:id/versions
  GET  /posts/:id/export
  GET  /explore
  GET  /categories
  GET  /users/:handle
  GET  /posts/:id/comments

PROTECTED (JWT required)
  GET/POST/PATCH/DELETE /notes + /notes/:id/promote
  POST/PATCH/DELETE     /drafts + /drafts/:id/publish
  DELETE/PATCH          /posts/:id (revise, soft-delete, correction)
  POST/DELETE           /users/:id/follow
  POST                  /posts/:id/react
  POST/PATCH/DELETE     /posts/:id/comments + /comments/:id/hide
  POST                  /saved
  GET                   /feed
  GET/POST              /sync + /sync/push
  POST/PATCH            /messages/request + /messages/request/:id
  POST/DELETE           /conversations/:id/messages + /messages/:id
  POST                  /conversations/:id/block
  GET                   /notifications
  DELETE                /account
  GET                   /me

SUPER_ADMIN only
  GET    /admin/reports
  PATCH  /admin/content/:id/action
  POST   /admin/categories
  PATCH  /admin/categories/:id/deprecate
```

**This was the original v1 surface.** Feature expansion work since then (media, search, tags, recommendations, Bible) has grown the platform to **70 total endpoints**. Nearly all of the additions are PUBLIC — consistent with there being no commercial layer and no reason to gate discovery, search, or scripture reading behind authentication. See `scribes_backend_source_of_truth.md` §8 for the complete current list, or the individual contract documents listed in §3 above.

---

## 9. What Never Changes (The Non-Negotiables)

These are the product and engineering rules that exist across every sprint, every screen, and every contributor. They do not get overridden by convenience or by a well-intentioned proposal. If a change conflicts with one of these, the change is wrong — not the rule.

### Product non-negotiables
1. Follower and following counts are never displayed, never computed in API responses, never stored as a metric — anywhere
2. View counts, read times, and implicit engagement signals do not exist in the schema, in any query, or in any UI element — anywhere
3. Reactions (Amen, Insightful, Thought-Provoking) and comments are the only engagement signals
4. Public posts (Post Detail, Explore, public Profile) are fully accessible without a JWT — no soft-gate before the content, only after attempting to interact
5. The handle a user registers with is permanent — it cannot be changed, it cannot be shown as editable in the UI
6. When a user deletes their account, their public posts remain — attributed to `[Deleted Author]` — their notes, drafts, and messages are purged
7. `post_versions` rows are never updated or deleted — they are immutable snapshots
8. Scribes has no commercial layer — no subscriptions, no tiers, no payment processing, no premium features. Every user has identical access to every capability. The fair-use allowance on media uploads is a rate limit, not a paywall, and applies uniformly to everyone

### Engineering non-negotiables
1. No raw SQL in Go files — all queries live in `internal/db/query/*.sql`
2. `handler` → `service` → `repository` — nothing flows backwards
3. `repository` is the only layer that imports `db/generated`
4. `server_sequence` is always assigned by `nextval('global_sequence')` — client-supplied values are rejected
5. The `owner = caller` filter on sync queries is mandatory and has a dedicated unit test
6. `password_hash` never appears in any API response — confirmed by grep at every sprint boundary

### Design non-negotiables
1. Cormorant Garamond for all display text, headings, pull quotes, and the wordmark
2. DM Sans for all body text, UI labels, buttons, navigation, and captions
3. No third typeface
4. The six colour tokens are the only colours (plus the delete-account warning red used once)
5. No drop shadows — elevation through border contrast only
6. No follower counts, view counts, or red badge numbers anywhere in the UI
7. The `ScribesUnauthBanner` on public screens is fixed, non-blocking, and never a modal

---

## 10. How to Propose a Change

Changes to any decision documented in the source-of-truth files follow this process:

1. **Identify the document** that owns the decision you want to change
2. **Write the proposed change** as a diff — what the current decision says, what the new decision would say, and why
3. **Evaluate it against the non-negotiables** in §9 of this document — if it conflicts with a non-negotiable, it does not proceed
4. **Update the relevant document** explicitly — the change is not adopted by implementing it in code and hoping no one notices
5. **Note the change** in the document's version history or with a dated comment

A change that is implemented in code without a corresponding update to the source-of-truth document is a drift — not a feature. Drifts compound and eventually make the source-of-truth documents useless.

---

## 11. The Aesthetic at a Glance

For a new contributor who needs the design system in thirty seconds:

> **Byzantine illuminated manuscript, reframed through a postmodern editorial lens. Spacious and editorial — premium magazine layout. Gold leaf on deep vellum. Ancient geometry. Modern restraint.**

- Serious, not religious. Welcoming, not exclusive.
- Every screen feels like opening a significant book, not launching an app.
- Ornament recedes. Content leads.
- The word does the evangelism. The interface steps back.

For the full design system, read `scribes_design_brief.md`.
For the landing page aesthetic laws, read `scribes_landing_aesthetic_laws.md`.
For QA verification of the aesthetic, read `scribes_qa_checklist.md`.

---

## 12. Who to Ask

Since Scribes is a solo-founded project (Joshua Omisanya, `@Joshua-Omz` on GitHub, `joshuaomisanya41@gmail.com`), all product decisions flow through the founder. A coding agent working autonomously should:

- Follow the source-of-truth documents as the authority
- Leave `// TODO: [question]` comments at genuine ambiguities rather than inventing decisions
- Flag ambiguities in its completion report rather than silently resolving them
- Never make a product decision that conflicts with §9 of this document without explicit instruction

---

*Scribes Onboarding Document v1.0*
*The entry point for every new contributor — human or agent.*
*When in doubt about where to start, this document tells you where to go next.*