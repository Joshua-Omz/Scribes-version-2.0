# Scribes Flutter Client — Coding Standards & Engineering Invariants
**Version 1.0 · Engineering Source of Truth for Flutter Development**

---

## 1. Core Philosophy: Foundation Before Syntax

Every line of Dart in the Scribes codebase must adhere to **predictable data flow, zero-allocation rendering, and strict layer isolation**. We build local-first, liturgical software designed to feel as reliable and enduring as an ancient manuscript.

```
┌────────────────────────────────────────────────────────┐
│   PRESENTATION (Screens, Widgets, Dialogs, Sheets)     │
│   • Only watches Application layer providers           │
│   • Consumes ScribesColors, ScribesTextStyles tokens    │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│   APPLICATION (Riverpod Notifiers & AsyncNotifiers)     │
│   • Orchestrates domain logic & mutations              │
│   • Interacts exclusively with Domain & Repositories   │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│   DOMAIN (Pure Models, Value Objects, Freezed Types)   │
│   • Zero dependencies on Flutter UI or Network packages│
│   • Immutable, pure serialization (JSON/Drift)         │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│   DATA (API Clients, Repositories, Drift SQLite)       │
│   • Isolates HTTP/DB contracts and error normalization │
│   • Maps remote DTOs to Domain models                  │
└────────────────────────────────────────────────────────┘
```

---

## 2. Layer Isolation Rules

| Layer | Permitted Imports | Prohibited Imports |
|---|---|---|
| `presentation/` | Feature's `application/`, shared `core/` design widgets, `domain/` models | `data/` classes directly, Dio/HTTP clients, raw database tables |
| `application/` | Feature's `domain/`, feature's `data/repository`, `core/storage` | Flutter UI widgets, Material elements, raw Dio types |
| `domain/` | Pure Dart packages (`freezed_annotation`, `uuid`, etc.) | Any Flutter UI library (`material.dart`), Dio, Drift tables |
| `data/` | `core/network`, `core/storage`, feature's `domain/` | Presentation widgets, other features' internal data implementations |

---

## 3. State Management Standards (Riverpod)

### 3.1 Notifier Selection
- **`AsyncNotifier<T>` / `AsyncNotifierProvider`**: Use for all server/database-backed domain state (e.g. `PostDetailNotifier`, `DraftListNotifier`, `FeedNotifier`).
- **`Notifier<T>` / `NotifierProvider`**: Use exclusively for synchronous, local-only UI state (e.g. `themeProvider`, active tab indices, draft-in-progress input controllers).

### 3.2 Granular Selectors in Scrollable Lists
Never watch an entire global collection or unselected state inside list items:
```dart
// ❌ WRONG: Rebuilds every card whenever ANY post is saved/unsaved anywhere in the app
final isSaved = ref.watch(savedPostsProvider).value?.contains(post.id) ?? false;

// ✅ CORRECT: Isolates rebuilds strictly to the card whose individual ID state changed
final isSaved = ref.watch(
  savedPostsProvider.select((state) {
    final list = state.value;
    if (list == null) return false;
    return list.any((p) => p['id'] == post.id || p['post_id'] == post.id);
  }),
);
```

### 3.3 State Invalidation Strategy
- For server mutations, prefer `ref.invalidateSelf()` or refreshing the repository stream.
- When optimistic UI is necessary for immediate tactile feedback (e.g. cover image preview or local draft saving), assign the local path immediately and confirm with background cloud confirmation.

---

## 4. UI & Rendering Performance Invariants

### 4.1 Viewport Geometry Stability (Zero Relayout Jitter)
- **Never resize `bottomNavigationBar` or viewport height during scroll flings**:
  ```dart
  // ❌ WRONG: Resizing height changes Scaffold body constraints, forcing full list relayout every 16ms
  AnimatedContainer(
    duration: Duration(milliseconds: 250),
    height: isVisible ? 85 : 0,
    child: ...
  )

  // ✅ CORRECT: Translates off-screen on the GPU without altering viewport box constraints
  AnimatedSlide(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
    offset: isVisible ? Offset.zero : const Offset(0, 1.0),
    child: SizedBox(height: 85, child: ...),
  )
  ```

### 4.2 GPU Shader & BackdropFilter Discipline
- Never place unconstrained `BackdropFilter(filter: ImageFilter.blur(...))` over active scroll viewports.
- Use solid tokens (`colors.background`, `colors.surface`) for pinned headers to eliminate offscreen Gaussian blur passes.

### 4.3 App Bar Scroll Inertia
- In `NestedScrollView`, configure `SliverAppBar(pinned: true, floating: false)` to prevent coordinate handoff contention and maintain natural scroll momentum.

### 4.4 Image Decoding & Memory Management
- Never use raw `Image.network` in feeds, explore carousels, or profile streams.
- Always use `ScribesImageResolver.buildImage()` with `memCacheWidth: 800` and `ScribesCacheManager.instance`.
- Always wrap scrollable cards in `ClipRRect` with explicit fallback containers.

### 4.5 RepaintBoundary Hygiene
- Apply a single `RepaintBoundary` at the root of list item wrappers (`ScribesConnectedPostCard`, `ScribesPostTile`).
- Never nest redundant `RepaintBoundary` widgets inside leaf child containers.

---

## 5. Design System Tokens: Zero Hardcoding

All colors, typography, and corner radiuses must originate from design system tokens:

```dart
// ❌ WRONG
Container(
  color: Color(0xFF111111),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
  child: Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
)

// ✅ CORRECT
final colors = ref.watch(themeProvider);
Container(
  color: colors.surface,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(ScribesRadius.card),
    border: Border.all(color: colors.border),
  ),
  child: Text('Title', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
)
```

### Required Token Classes
- **Colors**: `ScribesColors` via `ref.watch(themeProvider)` (`background`, `surface`, `surfaceRaised`, `primaryText`, `secondaryText`, `gold`, `goldMuted`, `orange`, `border`).
- **Typography**: `ScribesTextStyles` (`displayXl`, `displayLg`, `displayMd`, `bodyLg`, `bodyMd`, `labelLg`, `labelSm`, `caption`).
- **Radiuses**: `ScribesRadius` (`card: 10.0`, `chip: 4.0`, `button: 6.0`, `sheet: 16.0`, `input: 6.0`).

---

## 6. Network & Error Handling Standards

### 6.1 Centralized Endpoints & ApiClient
- Every HTTP route must be defined as a constant in `Endpoints` (`lib/core/network/endpoints.dart`).
- All requests must route through `ApiClient` (`lib/core/network/api_client.dart`) to ensure JWT interceptors, token refresh, and retry policies are applied.

### 6.2 Error Normalization
- Catch blocks must normalize errors to `ApiException` via `DioException.error`:
  ```dart
  String getCleanErrorMessage(Object? error) {
    if (error == null) return 'An unexpected error occurred';
    if (error is DioException && error.error is ApiException) {
      return (error.error as ApiException).message;
    }
    if (error is ApiException) return error.message;
    return error.toString().replaceAll('Exception:', '').trim();
  }
  ```

---

## 7. Quality Assurance & Static Analysis

Before any code is merged or considered complete:
1. `flutter analyze` must pass with **0 errors and 0 warnings**.
2. All new components must support both **Dark (Night)** and **Light (Parchment/Silver)** themes cleanly.
3. Offline data flow must be verified: writes must persist locally in Drift SQLite before cloud sync.
