# Scribes 2.0

A local-first writing platform for thoughtful publishing.  
**Architecture**: Go Modular Monolith API + Flutter local-first client (SQLite via Drift).

[![CI](https://github.com/Joshua-Omz/Scribes-version-2.0/actions/workflows/ci.yml/badge.svg)](https://github.com/Joshua-Omz/Scribes-version-2.0/actions/workflows/ci.yml)
[![Docker](https://github.com/Joshua-Omz/Scribes-version-2.0/actions/workflows/docker-image.yml/badge.svg)](https://github.com/Joshua-Omz/Scribes-version-2.0/actions/workflows/docker-image.yml)

---

## Quick Start (Backend)

### Prerequisites

- [Go 1.24+](https://go.dev/dl/)
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)

### Run with Docker Compose

```bash
# Start PostgreSQL + the API server
docker compose up --build
```

The API will be available at `http://localhost:8080`.

### Run locally (Go only)

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Start PostgreSQL
docker compose up -d db

# 3. Run the API (migrations are applied automatically on startup)
go run ./cmd/server
```

---

## API Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | — | Create account |
| POST | `/api/auth/login` | — | Sign in, receive JWT |
| GET | `/api/auth/me` | Bearer | Current user |
| GET | `/api/notes` | Bearer | List notes |
| POST | `/api/notes` | Bearer | Create note |
| GET | `/api/notes/{id}` | Bearer | Get note |
| PUT | `/api/notes/{id}` | Bearer | Update note |
| DELETE | `/api/notes/{id}` | Bearer | Soft-delete note |
| GET | `/api/drafts` | Bearer | List drafts |
| POST | `/api/drafts` | Bearer | Create draft |
| GET | `/api/drafts/{id}` | Bearer | Get draft |
| PUT | `/api/drafts/{id}` | Bearer | Update draft |
| DELETE | `/api/drafts/{id}` | Bearer | Soft-delete draft |
| GET | `/api/posts` | — | Public chronological feed |
| GET | `/api/posts/{id}` | — | Get post |
| POST | `/api/posts` | Bearer | Publish post |
| PUT | `/api/posts/{id}` | Bearer | Update post |
| DELETE | `/api/posts/{id}` | Bearer | Soft-delete post |
| GET | `/api/sync/pull` | Bearer | Pull server deltas |
| POST | `/api/sync/push` | Bearer | Push client mutations |
| GET | `/health` | — | Health check |

---

## Project Roadmap

See [ROADMAP.md](ROADMAP.md) for the full MVP engineering roadmap and sprint tracking.

Sprint documentation lives in [`docs/sprints/`](docs/sprints/):

| Sprint | Status |
|---|---|
| [Sprint 1 — Infrastructure, Identity & Data](docs/sprints/sprint-1.md) | ✅ Complete |
| [Sprint 2 — Delta Sync Engine](docs/sprints/sprint-2.md) | ✅ Complete |
| [API Contract (Phase 1.5)](docs/sprints/sprint-api-contract.md) | 🔲 Pending |
| [Sprint 3 — Offline Database & Editor](docs/sprints/sprint-3.md) | 🔲 Pending |
| [Sprint 4 — Publishing Pipeline & Feeds](docs/sprints/sprint-4.md) | 🔲 Pending |
| [Sprint 5 — Sync Worker](docs/sprints/sprint-5.md) | 🔲 Pending |
| [Sprint 6 — Observability & Deployment](docs/sprints/sprint-6.md) | 🔲 Pending |

---

## Repository Structure

```
cmd/server/main.go          # Entry point
internal/
  auth/handler.go           # JWT + Argon2 auth handlers
  users/repository.go       # User model & data access
  notes/                    # Notes (private workspace)
  drafts/                   # Drafts (staging area)
  posts/                    # Posts (public square)
  sync/handler.go           # Delta sync engine (pull & push)
pkg/
  config/config.go          # Env-based configuration
  database/database.go      # pgxpool + golang-migrate
  middleware/middleware.go   # Logger, JWT auth middleware
migrations/
  000001_init_schema.up.sql
  000001_init_schema.down.sql
docs/sprints/               # Sprint documentation & tracking
docker-compose.yml
Dockerfile
ROADMAP.md
.github/workflows/
  ci.yml                    # Lint, build, and test on every push/PR
  docker-image.yml          # Docker image build on every push/PR
```

---

## CI/CD

All workflows live in [`.github/workflows/`](.github/workflows/) and run on every push and pull request targeting `main`.

### `ci.yml` — Lint, Build & Test

| Job | What it does |
|---|---|
| **Lint & Build** | Runs `go vet ./...` to catch suspicious constructs, then `go build ./...` to verify the binary compiles cleanly. |
| **Test** | Spins up a PostgreSQL 16 service container (matching the `docker-compose.yml` setup) and runs `go test -v -race -timeout 60s ./...` against it. The `-race` flag enables the Go data-race detector. |

Environment variables injected into the **Test** job:

| Variable | Value |
|---|---|
| `DATABASE_URL` | `postgres://scribes:scribes_secret@localhost:5432/scribes_test?sslmode=disable` |
| `JWT_SECRET` | `test_secret_key_for_ci` |
| `MIGRATIONS_PATH` | `file://migrations` |

### `docker-image.yml` — Docker Build

Builds the multi-stage Docker image defined in `Dockerfile` using **Docker Buildx** with GitHub Actions layer caching (`type=gha`). The image is tagged with the commit SHA (`scribes-api:<sha>`) but is **not pushed** — pushing to a registry is deferred to Sprint 6 once a deployment target is chosen (Cloud Run / DigitalOcean App Platform).

### Adding tests

Per the [ROADMAP](ROADMAP.md), exhaustive integration tests are required for the **Sync Engine** and **Authentication** modules. Place test files alongside the package they test (e.g. `internal/auth/handler_test.go`) and they will be picked up automatically by the CI `test` job.