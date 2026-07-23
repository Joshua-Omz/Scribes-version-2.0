# Scribes 2.0

Scribes is a local-first writing and publishing platform with a Go backend API and a Flutter client.

## Repository structure

- `/backend` — Go (Gin + PostgreSQL) API
- `/client` — Flutter app (Android/iOS/Web/Desktop)
- `/docs` — product and engineering documentation
- `/mcp-server` — Python MCP server for AI-assisted posting workflows

## Core backend capabilities

- Auth + profile discovery
- Notes, drafts, and publishing pipeline
- Post revisions + correction history
- Social layer (follow, reactions, comments, saves)
- Feeds (`/feed`, `/feed/following`, `/explore`) with category/scripture filters
- Direct messages and message requests
- Notifications
- Basic moderation/reporting endpoints

## Quick start (backend)

### Prerequisites

- Go 1.24+
- Docker + Docker Compose

### Run with Docker

```bash
cp /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/backend/.env.example /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/backend/.env
docker compose -f /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/backend/docker-compose.yml up --build
```

API default URL: `http://localhost:8080`

### Run backend without Docker (API process)

```bash
cd /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/backend
go run ./cmd/api
```

> Requires a running PostgreSQL instance and a valid `DATABASE_URL` in `backend/.env`.

## Quick start (Flutter client)

```bash
cd /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/client
flutter pub get
flutter run
```

## Development checks

Backend:

```bash
cd /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/backend
go build ./...
go test ./...
```

Client:

```bash
cd /home/runner/work/Scribes-version-2.0/Scribes-version-2.0/client
flutter test
```

## API route map

All routes are mounted at root (no `/api` prefix).

### Public

- `GET /health`
- `POST /auth/register`
- `POST /auth/login`
- `GET /users/search`
- `GET /users/:id`
- `GET /users/:id/posts`
- `GET /posts/:id`
- `GET /posts/:id/versions`
- `GET /posts/:id/versions/:version`
- `GET /posts/:id/reactions`
- `GET /posts/:id/comments`
- `GET /explore`
- `GET /categories`

### Auth required (JWT)

- `GET /me`
- `GET /feed`
- `GET /feed/following`
- `GET /sync`

**Notes**
- `GET /notes`
- `POST /notes`
- `PATCH /notes/:id`
- `DELETE /notes/:id`
- `POST /notes/:id/promote`

**Drafts**
- `GET /drafts`
- `GET /drafts/:id`
- `POST /drafts`
- `PATCH /drafts/:id`
- `DELETE /drafts/:id`
- `POST /drafts/:id/publish`

**Posts**
- `GET /posts`
- `POST /posts`
- `PATCH /posts/:id`
- `DELETE /posts/:id`
- `PATCH /posts/:id/revise`
- `POST /posts/:id/correct`

**Social**
- `POST /users/:id/follow`
- `DELETE /users/:id/follow`
- `GET /users/:id/is-following`
- `POST /posts/:id/reactions`
- `DELETE /posts/:id/reactions`
- `POST /posts/:id/comments`
- `PATCH /comments/:id`
- `POST /posts/:id/save`
- `DELETE /posts/:id/save`
- `GET /saved`

**Messaging**
- `POST /message-requests`
- `GET /message-requests`
- `POST /message-requests/:id/approve`
- `POST /message-requests/:id/reject`
- `GET /conversations`
- `GET /conversations/:id/messages`
- `GET /conversations/:id/stream`
- `POST /conversations/:id/messages`
- `POST /conversations/:id/block`
- `DELETE /messages/:id`

**Notifications**
- `GET /notifications`
- `POST /notifications/:id/read`

**Moderation/Admin**
- `POST /reports`
- `GET /admin/reports`
- `POST /admin/reports/:id/status`

## Documentation

- `/docs/scribes_srs.md`
- `/docs/scribes_sdd.md`
- `/docs/scribes_roadmap.md`
- `/docs/sprints/`

## MCP server

See `/mcp-server/README.md` for setup and usage.
