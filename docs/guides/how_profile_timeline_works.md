# How Profile Timelines Work in Scribes

This guide outlines the Twitter/X-style profile timeline architecture, avatar resolution, and Riverpod selector performance.

---

## 1. Timeline Layout Philosophy

Both private (`PrivateProfileScreen`) and public (`PublicProfileScreen`) profile screens use a continuous linear stream:
- **Left Column**: [ScribesAvatar](file:///c:/Users/joshu/OneDrive/Documents/300level%20folder/other%20stuff/projects/Scribes/Scribes-version-2.0/client/lib/core/widgets/scribes_avatar.dart) with direct profile routing.
- **Right Column**:
  - Author Display Name, `@handle`, relative timestamp (`2h`, `3d`), and optional badge.
  - Manuscript Title & Body Excerpt with graceful multi-line flow.
  - Scripture Chips & Tags.
  - 16:9 Cover Image Media preview (downscaled in memory).
  - Compact Action Bar with real-time reaction counts (`amen`, `insightful`, `thought_provoking`), comments, bookmark toggle, and share.

---

## 2. Performance Invariants

1. **Granular Riverpod Selectors**:
   - `savedPostsProvider` is watched via `.select()` so tiles only rebuild when their individual post bookmark state toggles:
   ```dart
   final isSaved = ref.watch(
     savedPostsProvider.select((state) {
       final list = state.value;
       if (list == null) return false;
       return list.any((p) => p['id'] == post.id || p['post_id'] == post.id);
     }),
   );
   ```
2. **Zero Animation Controller Tickers**:
   - Uses lightweight native `InkWell` gestures without heavy per-card `AnimationController` instances.
3. **Avatar Image Resolution**:
   - Both profile screens pass `imageUrl: user.avatarUrl` to `ScribesAvatar`.
   - If `avatarUrl` is null or offline, `ScribesAvatar` renders a circular fallback avatar showing the author's capital initial letter.
