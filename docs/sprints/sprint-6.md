# Sprint 6 — Observability & Deployment

**Phase**: 3 (Integration & Launch)  
**Week**: 11  
**Status**: 🔲 Pending

---

## Goal

Add production observability (Sentry) and deploy the full stack to the cloud.

---

## Deliverables

### Observability

| Task | Status | Notes |
|---|---|---|
| Sentry SDK in Go | 🔲 | `github.com/getsentry/sentry-go` |
| Sentry SDK in Flutter | 🔲 | `sentry_flutter` package |
| Capture sync engine errors in Sentry | 🔲 | Wrap sync handler errors with `sentry.CaptureException` |
| Capture Flutter errors | 🔲 | Override `FlutterError.onError` + `PlatformDispatcher.instance.onError` |

### Containerisation

| Task | Status | Notes |
|---|---|---|
| Finalise multi-stage Dockerfile | 🔲 | Already scaffolded; verify scratch image works end-to-end |
| `.dockerignore` | 🔲 | Exclude `vendor/`, `.git/`, test files |

### Cloud Deployment

| Task | Status | Notes |
|---|---|---|
| PostgreSQL on managed DB | 🔲 | AWS RDS or DigitalOcean Managed PostgreSQL |
| Set `DATABASE_URL` secret | 🔲 | Via platform env vars / secrets manager |
| Go container on Cloud Run / App Platform | 🔲 | Set `JWT_SECRET`, `DATABASE_URL` env vars |
| Flutter Web (Wasm) compiled | 🔲 | `flutter build web --wasm` |
| Flutter Web deployed to static host | 🔲 | Vercel / Netlify / Firebase Hosting |

---

## Environment Variables (Production)

| Variable | Description |
|---|---|
| `DATABASE_URL` | Full PostgreSQL connection string (sslmode=require) |
| `JWT_SECRET` | Strong random secret (min 32 chars) |
| `SERVER_PORT` | Default `8080` |
| `MIGRATIONS_PATH` | Default `file://migrations` |
| `SENTRY_DSN` | Sentry project DSN |

---

## Go Sentry Integration Sketch

```go
import "github.com/getsentry/sentry-go"

func main() {
    sentry.Init(sentry.ClientOptions{
        Dsn:              os.Getenv("SENTRY_DSN"),
        TracesSampleRate: 0.1,
    })
    defer sentry.Flush(2 * time.Second)
    // … rest of startup
}
```

---

## 🚀 V1.0 MVP Launch Checklist

- [ ] All Sprint 1–5 items complete
- [ ] Sentry integrated in both Go and Flutter
- [ ] PostgreSQL managed DB provisioned
- [ ] Go API deployed and reachable at production URL
- [ ] Flutter Web deployed and reachable
- [ ] Smoke test: Register → Create Note → Publish Post → View Feed → Sync
