# Scribes — Feature Implementation Lifecycle & Architectural Principles
**Version 1.0 · Standard Operating Procedure for Feature Development**

---

## 1. Architectural Principles

Every feature in Scribes follows a deterministic, bottom-up lifecycle. We strictly prohibit "UI-first scaffolding" where frontend screens are built with mocked arrays and forgotten backend integrations.

```
       1. CONTRACT VERIFICATION (Backend & REST API)
                       │
                       ▼
       2. DATA & PERSISTENCE (Endpoints, Dio, Drift SQLite)
                       │
                       ▼
       3. DOMAIN MODELING (Freezed Entities & Value Objects)
                       │
                       ▼
       4. APPLICATION STATE (Riverpod AsyncNotifier & Notifier)
                       │
                       ▼
       5. PRESENTATION LAYER (Screens & Design System Tokens)
                       │
                       ▼
       6. END-TO-END VERIFICATION (Analysis, Offline Flow, Real DB)
```

---

## 2. Step-by-Step Implementation Workflow

### Step 1: API Contract Verification
Before writing client code, verify the active Go backend route and payload shape:
1. Locate the endpoint in `backend/internal/<feature>/handler.go` or `docs/source-of-truth/backend_source_of_truth.md`.
2. Confirm parameter casing (e.g. `mime_type` vs `content_type`, `cover_image_url`, `post_type`).
3. Add the exact path constant to `lib/core/network/endpoints.dart`.

### Step 2: Data & Persistence Layer (`features/<feature>/data/`)
1. **API Client (`<feature>_api.dart`)**:
   - Create raw HTTP methods using `ApiClient`.
   - Never expose raw `Dio` responses outside the data layer.
2. **Local Persistence (`lib/core/storage/drift_database.dart`)**:
   - If the entity is syncable or cached (Notes, Drafts, Posts), define or update the Drift table.
   - Ensure `is_synced` and server sequence tracking are supported.
3. **Repository (`<feature>_repository.dart`)**:
   - Coordinate between the remote API and the local Drift SQLite cache.
   - Expose domain models to the application layer.

### Step 3: Domain Modeling (`features/<feature>/domain/`)
1. Define immutable data structures using `@freezed` or standard immutable classes:
   ```dart
   @freezed
   abstract class Post with _$Post {
     const factory Post({
       required String id,
       @JsonKey(name: 'cover_image_url') String? coverImageUrl,
       @JsonKey(name: 'post_type') @Default('standard') String postType,
       required Map<String, dynamic> content,
     }) = _Post;

     factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
   }
   ```
2. Keep domain models **100% pure**: zero imports of Flutter UI packages (`material.dart`, `widgets.dart`).

### Step 4: Application Layer (`features/<feature>/application/`)
1. Create a dedicated Riverpod notifier:
   ```dart
   @riverpod
   class PostDetailNotifier extends _$PostDetailNotifier {
     @override
     Future<Post> build(String postId) async {
       return ref.read(postRepositoryProvider).getById(postId);
     }

     Future<void> react(String reactionType) async {
       await ref.read(postRepositoryProvider).react(postId, reactionType);
       ref.invalidateSelf();
     }
   }
   ```
2. Handle loading, data, and error states gracefully through `AsyncValue`.

### Step 5: Presentation Layer (`features/<feature>/presentation/`)
1. **Design Token Conformance**:
   - Use `ref.watch(themeProvider)` for colors (`colors.background`, `colors.gold`, `colors.border`).
   - Use `ScribesTextStyles` for typography (`displayLg`, `bodyMd`, `caption`).
   - Use `ScribesRadius` for border radiuses (`card`, `chip`, `button`).
2. **Leaf Widget Isolation**:
   - Break complex screens into small, reusable widgets.
   - Use `.select()` on collection providers to prevent full screen rebuilds.
3. **Accessibility & Ergonomics**:
   - Wrap interactive elements in `Semantics` and provide proper tap target sizing.
   - Include auto-unfocus tap handling on form screens (`GestureDetector + FocusScope.unfocus`).

### Step 6: End-to-End Verification
Before closing any feature task:
1. **Static Analysis**: Run `flutter analyze` and resolve all warnings.
2. **Data Flow Tracing**: Verify that data created in the client physically reaches PostgreSQL and re-hydrates properly upon fresh launch.
3. **Offline Resilience**: Verify that creating/editing offline persists to local SQLite and syncs when reconnected.

---

## 3. Strict Verification & Auditing Invariants

- **Zero Tolerance for Placeholders**: Hardcoded arrays (`['Mock Title 1', 'Mock Title 2']`), stubbed return statements (`return Future.value([])`), or dummy JSON files are prohibited in production branches.
- **Contract Parity**: Frontend field names must match backend Go struct JSON tags exactly.
- **Theme Parity**: Every screen must look pristine in both **Night** (dark) and **Parchment/Silver** (light) modes.
