# Scribes — Urgent Patches
**Version 1.0 · Two critical fixes to apply before any further feature work**

> These are concrete, minimal patches to close the security gap and complete the sync protocol identified in `context_discrepancy_report.md`. Apply both before touching Media, Bible, or any other new feature.

---

## Patch 1 — Admin Role Guard (Security, apply first)

### The problem

`router.go` currently mounts admin routes to the standard protected group with no role check. Any authenticated standard user can call `/admin/reports` and `/admin/reports/:id/status`. This is a live authorization bypass.

### The fix

```go
// internal/server/router.go — BEFORE (the bug)

protected := r.Group("/")
protected.Use(middleware.ValidateJWT(cfg.JWTSecret))

protected.GET("/reports", adminHandler.ListReports)                    // ❌ no role check
protected.GET("/admin/reports", adminHandler.ListReports)               // ❌ no role check
protected.PATCH("/admin/reports/:id/status", adminHandler.UpdateStatus) // ❌ no role check
```

```go
// internal/server/router.go — AFTER (the fix)

protected := r.Group("/")
protected.Use(middleware.ValidateJWT(cfg.JWTSecret))
// ... all genuinely standard-user routes stay here, unchanged

admin := r.Group("/admin")
admin.Use(middleware.ValidateJWT(cfg.JWTSecret))
admin.Use(middleware.RequireRole("super_admin"))

admin.GET("/reports", adminHandler.ListReports)
admin.PATCH("/reports/:id/status", adminHandler.UpdateStatus)
admin.POST("/categories", adminHandler.CreateCategory)               // was entirely missing — add now
admin.PATCH("/categories/:id/deprecate", adminHandler.DeprecateCategory)  // was entirely missing — add now
```

### Two things to verify, not assume

1. **Remove the duplicate unguarded `/reports` route entirely.** The report shows both `/reports` and `/admin/reports` pointing at the same handler — that's two paths to the same unguarded door. Only `/admin/reports` should exist, and it must sit inside the guarded group. Delete the bare `/reports` mount.

2. **Confirm `middleware.RequireRole` actually exists and is wired correctly** — per `scribes_backend_scaffold_prompt.md`, this middleware was specified in Sprint 1 (`internal/middleware/require_role.go`) with the exact contract: reads claims from context, returns 401 if missing, 403 if `claims.Role != role`. If it was never implemented in the real codebase (possible, given the router comment admitting the gap), it needs to be written now, not assumed to already exist.

### Verification after patching

```bash
# As a standard user (get a real JWT from a standard test account)
curl -H "Authorization: Bearer $STANDARD_USER_JWT" \
     https://your-api/admin/reports
# Expected: 403, not 200

# As a super_admin user
curl -H "Authorization: Bearer $SUPER_ADMIN_JWT" \
     https://your-api/admin/reports
# Expected: 200 with report data

# With no token at all
curl https://your-api/admin/reports
# Expected: 401
```

**This verification must be run against the real deployed backend, not assumed from reading the code.** The whole reason this gap existed is that "should be guarded" and "is guarded" silently diverged once already.

---

## Patch 2 — Complete the Sync Protocol

### The problem

Only `GET /sync?seq=N` (pull) exists. `POST /sync/push` was never implemented. The frontend's `endpoints.dart` doesn't reference `/sync` at all. Offline-created Notes and Drafts have no path back to the server.

### Backend fix

```go
// internal/sync/handler.go — add the missing handler

func (h *Handler) Push(c *gin.Context) {
    var req PushRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        respond.Error(c, http.StatusBadRequest, "invalid request body")
        return
    }

    claims, _ := middleware.ClaimsFromCtx(c.Request.Context())

    results, err := h.service.PushPending(c.Request.Context(), claims.UserID, req.Records)
    if err != nil {
        respond.Error(c, http.StatusInternalServerError, "sync push failed")
        return
    }

    respond.JSON(c, http.StatusOK, PushResponse{
        Synced:      results,
        MaxSequence: results.MaxSequence(),
    })
}
```

```go
// internal/sync/service.go — add PushPending if missing

func (s *Service) PushPending(ctx context.Context, userID uuid.UUID, records []PendingRecord) (*SyncResult, error) {
    // For each record:
    //   1. Verify it belongs to userID (never trust a client-supplied owner field)
    //   2. Reject if the record includes a client-supplied server_sequence
    //      (per the non-negotiable: server_sequence is ALWAYS server-assigned)
    //   3. Assign server_sequence via nextval('global_sequence')
    //   4. Upsert into the correct table (notes/drafts/posts based on record.Type)
    //   5. Return the mapping: local_id → server_sequence
    return s.repo.BulkUpsert(ctx, userID, records)
}
```

```go
// internal/server/router.go — mount the push route beside the existing pull route

protected.GET("/sync", syncHandler.Pull)
protected.POST("/sync/push", syncHandler.Push)   // ← this line was missing
```

### Frontend fix

```dart
// client/lib/core/network/endpoints.dart — add both, since neither currently exists

class Endpoints {
  // ... existing endpoints ...

  static const String syncPull = '/sync';
  static const String syncPush = '/sync/push';
}
```

```dart
// client/lib/core/storage/sync_service.dart — this file needs to exist per
// scribes_frontend_guide.md §9. If it doesn't exist yet, it needs to be built now,
// not deferred further — the sync protocol is only real once both ends call it.

class SyncService {
  Future<void> syncNow() async {
    final lastSeq = await _storage.getLastServerSequence();

    // Pull
    final delta = await _api.get(Endpoints.syncPull, queryParams: {'seq': lastSeq});
    await _storage.applyDelta(delta);

    // Push
    final pending = await _storage.getLocalOnlyRecords();
    if (pending.isNotEmpty) {
      final result = await _api.post(Endpoints.syncPush, body: {'records': pending});
      await _storage.confirmSynced(result);
    }
  }
}
```

### Verification after patching

```bash
# 1. Create a note with no server connection (simulate offline)
#    Confirm it exists locally in Drift with server_sequence = null, local_only = true

# 2. Reconnect, trigger sync

# 3. Confirm:
curl -H "Authorization: Bearer $JWT" https://your-api/sync?seq=0
# Should now include the previously-offline note in the response,
# with a real server_sequence assigned by the backend — not by the client
```

---

## Patch 3 — The `/dm` Follow Mapping Bug

### The problem

```dart
// client/lib/core/network/endpoints.dart — the bug
static const String follow = '/dm';   // ❌ wrong endpoint entirely
```

### The fix

```dart
// client/lib/core/network/endpoints.dart — corrected

static String follow(String userId) => '/users/$userId/follow';
```

**Check for the pattern, not just this one instance.** If `follow` was hardcoded to the wrong string, it's worth a quick pass through `endpoints.dart` for any other endpoint that might have been copy-pasted from a neighboring constant and never corrected. This class of bug — a constant that compiles fine and fails silently at runtime — doesn't surface in `go build` or `flutter analyze`. It only surfaces when someone taps the button and watches the network tab.

### Verification

```dart
// Confirm every follow/unfollow call in the app actually hits /users/:id/follow
// Search the codebase for any remaining reference to the old `/dm` constant
// in a follow-related context
```

---

## What NOT to Do Yet

Per the earlier discussion — do not scaffold Media or Bible endpoints until Patches 1 and 2 are verified working against the real running backend. Building new features on top of an unverified sync layer and an open admin route means any new feature's tests could pass while sitting on a broken foundation.

---

*Scribes Urgent Patches v1.0*
*Apply and verify against the real backend before any further feature work*