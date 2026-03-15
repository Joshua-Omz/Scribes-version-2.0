# Scribes — Software Design Document (SDD)

> **Version**: 1.0 — Draft  
> **Project**: Scribes (Local-First Note-Taking & Publishing App)

---

## 1. System Architecture

Scribes is structured as a **monorepo** with two independently deployable workloads:

```
scribes/
├── backend/   # Go REST API (modular monolith)
└── client/    # Flutter app (local-first, offline-capable)
```

---

## 2. Backend Design

### 2.1 Technology Stack
| Component | Technology |
|-----------|-----------|
| Language | Go 1.24+ |
| Router | `github.com/go-chi/chi/v5` |
| Database | PostgreSQL 16 |
| Driver | `github.com/jackc/pgx/v5` |
| Migrations | `github.com/golang-migrate/migrate/v4` |
| Auth | HS256 JWT via `github.com/golang-jwt/jwt/v5` |
| Password hashing | Argon2id via `golang.org/x/crypto/argon2` |
| Logging | `log/slog` (structured JSON) |

### 2.2 Module Structure
```
backend/
├── cmd/api/           # Entry point (main.go)
├── internal/
│   ├── auth/          # Registration, login, JWT generation
│   ├── users/         # User repository
│   ├── notes/         # Notes CRUD + repository
│   ├── drafts/        # Drafts CRUD + repository
│   ├── posts/         # Posts CRUD + repository
│   └── sync/          # Delta sync push/pull handler
├── pkg/
│   ├── config/        # Environment variable loading
│   ├── database/      # PGX connection pool + migrate runner
│   └── middleware/    # JWT auth middleware, request logger
└── migrations/        # SQL migration files (golang-migrate)
```

### 2.3 Authentication Flow
1. Client sends `POST /api/auth/register` or `POST /api/auth/login`.
2. Password is verified against the Argon2id hash stored as `<salt_hex>:<hash_hex>`.
3. On success, a signed HS256 JWT (72 h TTL) is returned.
4. Subsequent requests include the token in `Authorization: Bearer <token>`.
5. The `mw.Authenticate` middleware validates the token and injects claims into the request context.

### 2.4 Sync Engine
- **Pull**: Returns all Notes, Drafts, and Posts where `updated_at > last_synced_at`.
- **Push**: Upserts client mutations using `ON CONFLICT … WHERE updated_at < EXCLUDED.updated_at` (Last-Write-Wins).
- **Soft deletes**: Records are never physically deleted; a `deleted_at` column marks deletion.

---

## 3. Client Design

### 3.1 Technology Stack
| Component | Technology |
|-----------|-----------|
| Language | Dart 3+ |
| Framework | Flutter 3+ |
| State management | Riverpod (planned) |
| Local database | Drift / SQLite (planned) |
| HTTP client | Dio (planned) |

### 3.2 Offline-First Strategy
- All writes go to the local Drift SQLite database first.
- A background sync worker periodically pushes local mutations to the backend and pulls server deltas.
- Conflict resolution is LWW, mirroring the backend.

---

## 4. Deployment

### 4.1 Local Development
```bash
# Start PostgreSQL
docker compose up -d db

# Run backend
cd backend
DATABASE_URL=postgres://scribes:scribes_secret@localhost:5432/scribes?sslmode=disable \
JWT_SECRET=dev_secret \
go run ./cmd/api
```

### 4.2 Container Build
```bash
docker compose up --build
```

The `docker-compose.yml` builds the backend image from `./backend/Dockerfile` using a multi-stage scratch-based build.

### 4.3 CI/CD
The `.github/workflows/ci.yml` pipeline runs on every push and pull request to `main`:
- **Backend job**: `go vet` + `go build` in `./backend`
- **Client job**: `flutter analyze` + `flutter test` in `./client`
- **Docker job**: builds the backend Docker image to validate the `Dockerfile`
