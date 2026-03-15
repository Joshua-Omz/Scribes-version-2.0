# Scribes MVP Engineering Roadmap

> **Architecture**: Local-First Mobile/Web Client + Go Modular Monolith

---

## Philosophy & Constraints

| Constraint | Detail |
|---|---|
| Sequential Focus | Backend → API Contract → Local-First Frontend → Integration |
| No Premature Scaling | Redis, complex feed ranking and AI features are **excluded** from MVP. PostgreSQL is the sole system of record. |
| Data Integrity First | The Sync Engine and Authentication are the only areas requiring exhaustive integration testing. |

---

## Milestone Overview

| Phase | Scope | Timeline |
|---|---|---|
| Phase 1 | Backend Foundation (Go + PostgreSQL + Sync Engine) | Weeks 1–4 |
| Phase 1.5 | API Contract (OpenAPI Freeze) | Week 5 |
| Phase 2 | Local-First Client & Publishing (Flutter) | Weeks 6–8 |
| Phase 3 | Integration & Launch | Weeks 9–11 |

---

## Phase 1 — The Backend Foundation (Weeks 1–4)

**Goal**: Build a bulletproof system of record and delta sync engine.

### Sprint 1: Infrastructure, Identity & Data (Weeks 1–2)

- [x] **Infrastructure** — `docker-compose.yml` with PostgreSQL 16 (no Redis)
- [x] **Routing & Schema** — Chi router (`github.com/go-chi/chi/v5`) wired in `cmd/server/main.go`; SQL schema applied via `golang-migrate`
- [x] **Auth** — JWT generation (`golang-jwt/jwt/v5`) and Argon2id password hashing (`golang.org/x/crypto/argon2`)
- [x] **Endpoints** — Basic CRUD REST endpoints for Notes, Drafts, and Posts
- [x] **Observability** — Structured JSON logging via `log/slog`
- [x] **Dockerfile** — Multi-stage scratch-based Docker image

See [`docs/sprints/sprint-1.md`](docs/sprints/sprint-1.md) for details.

### Sprint 2: The Delta Sync Engine (Weeks 3–4)

- [x] **Pull Endpoint** — `GET /api/sync/pull?last_synced_at=<RFC3339>` returns rows where `updated_at > last_synced_at`
- [x] **Push Endpoint** — `POST /api/sync/push` accepts client mutations (created/updated/deleted records)
- [x] **Conflict Resolution** — Last-Write-Wins (LWW) via PostgreSQL `ON CONFLICT … WHERE updated_at < EXCLUDED.updated_at`
- [x] **Soft Deletes** — `deleted_at` markers on Notes and Drafts
- [x] **Chronological Feeds** — All feed endpoints `ORDER BY created_at DESC`

See [`docs/sprints/sprint-2.md`](docs/sprints/sprint-2.md) for details.

---

## Phase 1.5 — The API Contract (Week 5)

**Goal**: Freeze the backend–frontend boundary.

- [ ] Generate OpenAPI (Swagger) specification for the Go API
- [ ] Document exact JSON payloads for Auth, Sync, and Publishing
- [ ] Treat the Flutter client as a strict "third-party consumer" of the spec

See [`docs/sprints/sprint-api-contract.md`](docs/sprints/sprint-api-contract.md) for details.

---

## Phase 2 — Local-First Client & Publishing (Weeks 6–8)

**Goal**: Build the offline experience and the core product transformation.

### Sprint 3: Offline Database & The Editor (Weeks 6–7)

- [ ] Initialize Flutter with Riverpod (state) and Drift (SQLite)
- [ ] Replicate backend schema locally in Drift for Notes and Drafts
- [ ] Build the WYSIWYG Rich Text Editor UI
- [ ] Implement fully offline CRUD + soft-delete for Notes

See [`docs/sprints/sprint-3.md`](docs/sprints/sprint-3.md) for details.

### Sprint 4: The Publishing Pipeline & Feeds (Week 8)

- [ ] Build Note → Draft extraction UI flow
- [ ] Build Publish screen (Category + Scripture Tag selection)
- [ ] Build Primary and Explore feeds (strictly chronological)

See [`docs/sprints/sprint-4.md`](docs/sprints/sprint-4.md) for details.

---

## Phase 3 — Integration & Launch (Weeks 9–11)

**Goal**: Connect the pipes, monitor for failures, and deploy.

### Sprint 5: The Sync Worker (Weeks 9–10)

- [ ] Background sync queue in Flutter
- [ ] Full loop: Push local mutations → Pull server deltas → Resolve LWW → Update Drift SQLite
- [ ] Offline queuing and retry with exponential backoff (`dio`, `connectivity_plus`)
- [ ] Exhaustive integration tests for the sync boundary

See [`docs/sprints/sprint-5.md`](docs/sprints/sprint-5.md) for details.

### Sprint 6: Observability & Deployment (Week 11)

- [ ] Integrate Sentry into Go and Flutter
- [ ] Finalise Go Docker multi-stage build (`scratch` image)
- [ ] Deploy PostgreSQL to a managed database (AWS RDS / DigitalOcean Managed DB)
- [ ] Deploy Go container to Cloud Run / App Platform
- [ ] Compile Flutter Web (Wasm) → deploy to static host

See [`docs/sprints/sprint-6.md`](docs/sprints/sprint-6.md) for details.

---

## V1.0 MVP Launch 🚀
