---
trigger: always_on
---

# Scribes — Frontend Source of Truth
**Version 1.0 · Flutter Client · Guide, not gospel**

> **Read this first.** This document is built entirely from the plans we designed together across this conversation — the design brief, the twelve Stitch screen prompts, and the 43-endpoint backend source of truth. It has not been verified against the backend as it was actually implemented. Treat every API shape, field name, and status code below as **the intended contract**, not a confirmed fact. Before wiring any screen to a live endpoint, hit that endpoint directly (curl, Postman, or a quick Go test) and confirm the real response shape matches what's assumed here. Where it doesn't match, this document is wrong and the real API wins — update this file, don't paper over the difference in the Flutter code.

---

## 1. What This Document Is For

This is the frontend equivalent of the backend source of truth. It exists so that:
- Every screen's data needs are mapped to a specific (assumed) endpoint
- The design system tokens from the design brief become actual Dart constants, not re-derived per screen
- State management boundaries are decided once, not re-argued every sprint
- A coding agent building the Flutter app has one reference instead of needing to re-read the entire conversation history

---

## 2. Assumptions That Need Verification (read before Sprint 1)

These are the specific places where "plan" and "actual backend" are most likely to have drifted. Verify each one against the real API before building the screen that depends on it.

| Assumption | Where it's used | How to verify |
|---|---|---|
| JWT is returned as `{"token": "...", "user": {...}}` on register/login | Auth screens, token storage | `curl -X POST .../auth/register` and inspect the real response body |
| `GET /posts/:id` returns `content` as JSONB matching a specific rich-text shape | Post Detail, Compose preview | Fetch a real post, inspect the actual `content` field structure |
| Reaction response shape differs for author vs public viewer | Post Detail reaction bar | Confirm the API actually returns two different shapes, or if it's one shape with a conditional field |
| `GET /sync?seq=N` response includes `max_sequence` | Sync engine | Confirm this field exists and is named exactly this |
| Error responses follow `{"error": "message"}` uniformly | Every screen's error handling | Trigger a 400, 401, 403, 404, 409 and check they're all shaped the same |
| Pagination cursor is opaque (base64 or similar) vs. a raw timestamp+id pair | Feed, Explore, Comments | Check what `pkg/pagination/cursor.go` actually encodes and how the client is meant to pass it back |
| Category IDs vs category names in requests | Compose, Explore filters | Confirm whether the client sends UUIDs or string names for categories |

**If any of these differ from what's assumed in this document, that's not a crisis — it's one field name change in one API client method. The architecture below is built specifically so that kind of drift stays contained to a single file per feature.**

---

## 3. Technology Stack — Fixed Decisions

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter (Dart) | Web → Wasm, Mobile → native iOS/Android |
| State management | Riverpod | `AsyncNotifier` for API-backed state, plain `Notifier` for local UI state |
| Local storage | Drift (SQLite) | Offline-first cache for Notes, Drafts, cached Posts |
| HTTP client | `dio` | Interceptors for JWT attachment, retry, error normalisation |
| Routing | `go_router` | Declarative routes, deep-link support for shared post URLs |
| Rich text | `flutter_quill` or equivalent JSONB-compatible editor | Must serialize to whatever shape the backend `content` field expects — verify this first |
| Fonts | Cormorant Garamond (display) + DM Sans (body/UI) | Bundled, not loaded from Google Fonts CDN, for offline reliability |
| Icons | Lucide Icons (via `lucide_icons` package) | Matches the outlined, 1.5px stroke spec in the design brief |

---

## 4. Design Tokens — From Brief to Dart

The three themes (Night, Parchment, Silver) from the design brief become a single `ThemeExtension` per theme, switchable at runtime via Riverpod state — not baked into `MaterialApp.theme` statically, since the Settings screen requires live theme switching.

```dart
// lib/core/theme/scribes_colors.dart

class ScribesColors extends ThemeExtension<ScribesColors> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color primaryText;
  final Color secondaryText;
  final Color gold;
  final Color goldMuted;
  final Color orange;
  final Color orangeSoft;
  final Color border;

  const ScribesColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.primaryText,
    required this.secondaryText,
    required this.gold,
    required this.goldMuted,
    required this.orange,
    required this.orangeSoft,
    required this.border,
  });

  static const night = ScribesColors(
    background:    Color(0xFF0A0A0A),
    surface:       Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1714),
    primaryText:   Color(0xFFF0EDE6),
    secondaryText: Color(0xFF8A8070),
    gold:          Color(0xFFC9A84C),
    goldMuted:     Color(0xFF7A6230),
    orange:        Color(0xFFD4621A),
    orangeSoft:    Color(0xFF3D2010),
    border:        Color(0xFF2A2520),
  );

  static const parchment = ScribesColors(
    background:    Color(0xFFF5F0E8),
    surface:       Color(0xFFFDFAF4),
    surfaceRaised: Color(0xFFFFFFFF),
    primaryText:   Color(0xFF1A1612),
    secondaryText: Color(0xFF6B6055),
    gold:          Color(0xFF9A7020),
    goldMuted:     Color(0xFFC8B070),
    orange:        Color(0xFFC4511A),
    orangeSoft:    Color(0xFFFAEADE),
    border:        Color(0xFFDDD5C0),
  );

  static const silver = ScribesColors(
    background:    Color(0xFFF2F2F4),
    surface:       Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFAFAFC),
    primaryText:   Color(0xFF111116),
    secondaryText: Color(0xFF72727A),
    gold:          Color(0xFFB08A2A),
    goldMuted:     Color(0xFFD4C080),
    orange:        Color(0xFFD4520A),
    orangeSoft:    Color(0xFFFAEDE4),
    border:        Color(0xFFE0E0E6),
  );

  @override
  ScribesColors copyWith({...}) { /* standard boilerplate */ }

  @override
  ScribesColors lerp(ThemeExtension<ScribesColors>? other, double t) {
    // Themes switch instantly, no animation — return `this` unless
    // a future design decision wants a cross-fade
    return this;
  }
}
```

```dart
// lib/core/theme/scribes_text_styles.dart

class ScribesTextStyles {
  static const displayXl = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 40, fontWeight: FontWeight.w300,
    height: 1.15, letterSpacing: 0.4,
  );
  static const displayLg = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 32, fontWeight: FontWeight.w600,
    height: 1.15,
  );
  static const displayMd = TextStyle(
    fontFamily: 'CormorantGaramond',
    fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const bodyLg = TextStyle(
    fontFamily: 'DMSans', fontSize: 17,
    fontWeight: FontWeight.w400, height: 1.75,
  );
  static const bodyMd = TextStyle(
    fontFamily: 'DMSans', fontSize: 15,
    fontWeight: FontWeight.w400, height: 1.7,
  );
  static const labelLg = TextStyle(
    fontFamily: 'DMSans', fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  static const labelSm = TextStyle(
    fontFamily: 'DMSans', fontSize: 11,
    fontWeight: FontWeight.w500, letterSpacing: 0.5,
  );
  static const caption = TextStyle(
    fontFamily: 'DMSans', fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}
```

**Shape tokens** (border radius, from the design brief §5):

```dart
class ScribesRadius {
  static const card    = 10.0;
  static const chip    = 4.0;
  static const button  = 6.0;
  static const sheet   = 16.0; // top corners only
  static const input   = 6.0;
}
```

---

## 5. Folder Architecture — Mirrors the Backend's Feature-Based Pattern

Same philosophy as the backend: one folder per feature, each screen's data logic isolated so a backend contract mismatch stays contained.

```
lib/
├── main.dart
├── core/
│   ├── theme/                  — ScribesColors, ScribesTextStyles, ScribesRadius, theme_provider.dart
│   ├── router/                 — go_router config, route names as constants
│   ├── network/
│   │   ├── api_client.dart     — dio instance, base URL, JWT interceptor
│   │   ├── api_exception.dart  — normalises all error responses into one type
│   │   └── endpoints.dart      — string constants for every path — SINGLE SOURCE for path strings
│   ├── storage/
│   │   ├── drift_database.dart — Drift schema, tables mirror backend's syncable entities
│   │   └── secure_storage.dart — JWT persistence (flutter_secure_storage)
│   └── widgets/                — shared design-system widgets (see §7)
│
├── features/
│   ├── auth/
│   │   ├── data/                — AuthApi (raw dio calls), AuthRepository (domain mapping)
│   │   ├── domain/               — User model, AuthState
│   │   ├── application/          — AuthNotifier (Riverpod)
│   │   └── presentation/         — screens: splash, auth_gate, onboarding_topics
│   ├── note/
│   │   ├── data/ domain/ application/ presentation/
│   ├── draft/
│   ├── post/                     — includes compose, post_detail, version_history
│   ├── feed/                     — includes explore
│   ├── social/                   — reactions, comments, follow, saved
│   ├── message/
│   ├── notification/
│   ├── profile/
│   └── settings/
│
└── l10n/                         — not in v1 scope, folder reserved
```

**The layer rule, Flutter version:**

| Layer | May import | Must NOT import |
|---|---|---|
| `presentation/` (widgets, screens) | own `application/` provider only | `data/` directly, other features' internals |
| `application/` (Riverpod notifiers) | own `domain/` + own `data/repository` | `core/network` API classes directly |
| `domain/` (models, pure logic) | nothing feature-specific | any Flutter widget, any dio type |
| `data/` (API + repository) | `core/network`, own `domain/` models | other features' data layers |

This mirrors the backend's `handler → service → repository` discipline. If a backend field name changes, the fix is contained to one `data/` file per feature — never a cascading rewrite through widgets.

---

## 6. State Management Pattern

**Every screen that shows server data uses this exact shape:**

```dart
// features/post/application/post_detail_provider.dart

@riverpod
class PostDetailNotifier extends _$PostDetailNotifier {
  @override
  Future<Post> build(String postId) async {
    final repo = ref.read(postRepositoryProvider);
    return repo.getById(postId);
  }

  Future<void> react(ReactionType type) async {
    final repo = ref.read(postRepositoryProvider);
    await repo.react(state.value!.id, type);
    ref.invalidateSelf(); // refetch — simplest correct approach for v1
  }
}
```

**Why `ref.invalidateSelf()` and not optimistic updates in v1:** Optimistic UI (updating local state before the server confirms) is a real UX improvement but it's also where most sync bugs live. Given the offline-first sync layer already adds real complexity, v1 favours simple invalidate-and-refetch. Revisit optimistic updates for reactions/follows specifically once the app is stable — those are the two interactions where the wait is most noticeable.

**Local-only state** (theme selection, compose draft-in-progress before autosave, UI toggle states) uses plain `Notifier`, never touches the network layer.

---

## 7. Shared Design-System Widgets

Build these once in `core/widgets/` before any screen — every screen in the design brief depends on them.

| Widget | Used by | Key behaviour |
|---|---|---|
| `ScribesOrnamentDivider` | Post Detail, Compose, Profile, Explore | 0.5px rule + centred gold medallion SVG, 12–20% opacity |
| `ScribesPostCa