# Sprint — API Contract (Phase 1.5)

**Phase**: 1.5 (API Freeze)  
**Week**: 5  
**Status**: 🔲 Pending

---

## Goal

Freeze the backend–frontend boundary so that the Flutter client can be built against a stable, documented API contract.

---

## Deliverables

| Task | Status | Notes |
|---|---|---|
| Generate OpenAPI 3.0 spec | 🔲 | Use `swaggo/swag` or hand-author `openapi.yaml` |
| Document Auth payloads | 🔲 | `/api/auth/register`, `/api/auth/login`, `/api/auth/me` |
| Document Sync payloads | 🔲 | `/api/sync/pull`, `/api/sync/push` |
| Document CRUD payloads | 🔲 | Notes, Drafts, Posts |
| Serve Swagger UI | 🔲 | Optional: mount `swagger-ui` at `/docs` |
| Share spec with Flutter team | 🔲 | Commit `openapi.yaml` to repo root |

---

## Approach

1. Install `swaggo/swag`:
   ```bash
   go install github.com/swaggo/swag/cmd/swag@latest
   ```
2. Annotate handlers with `swag` doc comments.
3. Run `swag init -g cmd/server/main.go -o docs/openapi`.
4. Mount `swagger-ui` as a static handler at `/docs`.
5. Commit the generated `docs/openapi/swagger.json` + `swagger.yaml`.

---

## API Freeze Policy

Once the spec is published at the end of Week 5:

- All breaking changes (field renames, removed endpoints) require a version bump (`/api/v2/…`).
- Additive changes (new optional fields, new endpoints) are backward-compatible and allowed.
- The Flutter client is treated as a **strict third-party consumer** — no "quick hacks" across the boundary.
