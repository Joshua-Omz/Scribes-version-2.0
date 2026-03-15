# Sprint 1 — Infrastructure, Identity & Data

**Phase**: 1 (Backend Foundation)  
**Weeks**: 1–2  
**Status**: ✅ Complete

---

## Goal

Bootstrap the Go service with a reliable PostgreSQL schema, secure authentication, and complete CRUD endpoints for the core domain resources.

---

## Deliverables

### Infrastructure

| Task | Status | Notes |
|---|---|---|
| `docker-compose.yml` with PostgreSQL 16 | ✅ | No Redis; PostgreSQL is the sole system of record |
| Multi-stage `Dockerfile` (scratch image) | ✅ | `builder` stage on `golang:1.24-alpine`; runtime on `scratch` |

### Routing & Schema

| Task | Status | Notes |
|---|---|---|
| Go module `github.com/Joshua-Omz/scribes` | ✅ | `go.mod` initialised |
| Chi router wired in `cmd/server/main.go` | ✅ | `github.com/go-chi/chi/v5` |
| SQL schema migrations | ✅ | `migrations/000001_init_schema.{up,down}.sql` via `golang-migrate` |
| Tables: `users`, `notes`, `drafts`, `posts`, `interactions` | ✅ | Full schema with indexes |

### Authentication

| Task | Status | Notes |
|---|---|---|
| JWT generation (HS256, 72-hour TTL) | ✅ | `golang-jwt/jwt/v5` |
| Argon2id password hashing | ✅ | `golang.org/x/crypto/argon2` |
| `POST /api/auth/register` | ✅ | Returns JWT + user object |
| `POST /api/auth/login` | ✅ | Returns JWT + user object |
| `GET /api/auth/me` | ✅ | Returns authenticated user |

### CRUD Endpoints

| Resource | List | Create | Get | Update | Delete |
|---|---|---|---|---|---|
| Notes | ✅ | ✅ | ✅ | ✅ | ✅ (soft) |
| Drafts | ✅ | ✅ | ✅ | ✅ | ✅ (soft) |
| Posts | ✅ (feed) | ✅ | ✅ | ✅ | ✅ (soft) |

### Observability

| Task | Status | Notes |
|---|---|---|
| Structured JSON logging | ✅ | `log/slog` with JSON handler |
| Request logging middleware | ✅ | method, path, status, duration_ms, remote |
| Graceful shutdown | ✅ | SIGINT/SIGTERM handled |

---

## Package Layout

```
cmd/server/main.go          # Entry point, router wiring
internal/auth/handler.go    # Auth HTTP handlers + JWT + Argon2
internal/users/repository.go
internal/notes/repository.go
internal/notes/handler.go
internal/drafts/drafts.go   # Model + repository + handlers
internal/posts/posts.go     # Model + repository + handlers
pkg/config/config.go        # Env-based configuration
pkg/database/database.go    # pgxpool + golang-migrate runner
pkg/middleware/middleware.go # Logger, Authenticate, ClaimsFromContext
migrations/
  000001_init_schema.up.sql
  000001_init_schema.down.sql
docker-compose.yml
Dockerfile
```

---

## API Reference (Sprint 1)

### Auth

```
POST /api/auth/register
Body: { "username": "...", "email": "...", "password": "..." }
Response 201: { "token": "...", "user": { ... } }

POST /api/auth/login
Body: { "email": "...", "password": "..." }
Response 200: { "token": "...", "user": { ... } }

GET /api/auth/me        [Bearer required]
Response 200: { "id": "...", "username": "...", "email": "...", ... }
```

### Notes  *(all require Bearer token)*

```
GET    /api/notes
POST   /api/notes          Body: { "title": "...", "body": "..." }
GET    /api/notes/{id}
PUT    /api/notes/{id}     Body: { "title": "...", "body": "..." }
DELETE /api/notes/{id}     → 204 No Content (soft delete)
```

### Drafts  *(all require Bearer token)*

```
GET    /api/drafts
POST   /api/drafts         Body: { "note_id": "...", "title": "...", "body": "..." }
GET    /api/drafts/{id}
PUT    /api/drafts/{id}    Body: { "title": "...", "body": "..." }
DELETE /api/drafts/{id}    → 204 No Content (soft delete)
```

### Posts

```
GET  /api/posts            ?category=<name>   (public, no auth required)
GET  /api/posts/{id}                          (public, no auth required)
POST /api/posts            [Bearer required]  Body: { "title": "...", "body": "...", "category": "...", "scripture": "..." }
PUT  /api/posts/{id}       [Bearer required]
DELETE /api/posts/{id}     [Bearer required] → 204 No Content
```

### Health

```
GET /health  → { "status": "ok" }
```

---

## Running Locally

```bash
# Copy and edit environment
cp .env.example .env

# Start the database
docker compose up -d db

# Run migrations and start the API
DATABASE_URL=postgres://scribes:scribes_secret@localhost:5432/scribes?sslmode=disable \
JWT_SECRET=dev_secret \
go run ./cmd/server
```

Or start everything with Docker Compose:

```bash
docker compose up --build
```
