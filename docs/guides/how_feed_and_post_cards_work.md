# How Feed & Post Cards Work in Scribes

This guide documents the architecture, data flow, and visual rendering hierarchy of post cards across the main Feed, Discover, and Profile timelines.

---

## 1. Architectural Philosophy: The Hybrid Magazine Card

In Scribes, feed cards balance **visual engagement** (immersive 16:9 cover media) with **manuscript depth** (Cormorant Garamond editorial typography, inline scripture tags, and liturgical dividers).

### Vertical Hierarchy
```
┌───────────────────────────────────────────────────────────────┐
│ [Avatar] Author Name  @handle · 2h                 [Follow]   │  <- Author Header
├───────────────────────────────────────────────────────────────┤
│ ┌───────────────────────────────────────────────────────────┐ │
│ │                                                           │ │
│ │               16:9 Cover Image Media                      │ │  <- Cover Image (16:9)
│ │                                                           │ │
│ │ [Passage / Featured] (floating badge over bottom scrim)   │ │  <- Gradient Scrim & Badge
│ └───────────────────────────────────────────────────────────┘ │
│                                                               │
│ Title of Sacred Manuscript                                    │  <- Serif Display Title
│                                                               │
│ Elegant manuscript excerpt text flowing with high             │  <- Body Excerpt
│ readability across the card...                                │
│                                                               │
│ [John 3:16]  [Romans 8:28]  #grace  #salvation                │  <- Scripture & Tags
│                                                               │
│ ─────────────── ✦ (ScribesOrnamentDivider) ───────────────   │  <- Sacred Divider
│                                                               │
│    🔥 14      💡 8      💎 3      💬 12       🔖         ↗    │  <- Compact 6-Action Row
└───────────────────────────────────────────────────────────────┘
```

---

## 2. Image Extraction & Resolution Strategy

Post cards extract images hierarchically via `ScribesImageResolver.extractFirstImageUrl(post)`:

1. **Top-Level Property**: `post.coverImageUrl`
2. **JSONB Content Keys**: `post.content['cover_image_url']`, `post.content['imageUrl']`, `post.content['banner_url']`
3. **Quill Delta Scan**: Inspects `insert: {image: '...'}` inside `post.content['body']['ops']`
4. **Passage Panels**: Inspects `post.content['panels'][*]['media_url']`
5. **URL Normalization**: Prepends base API endpoint for relative uploads and downsamples with `memCacheWidth: 800` via `CachedNetworkImage`

### Adaptive Text-Only Fallback
If no image exists across any layer, the card seamlessly omits the image slot, allowing the author header to flow directly into the title and excerpt for high reading density.

---

## 3. Multi-Reaction Telemetry Row

Reactions in Scribes are **semantic recommendation seeds** that power Discover tab carousels and PostgreSQL materialized views:
- **🔥 Amen**: Conviction & affirmation $\to$ Powers **Most Affirmed**
- **💡 Insight**: Theological depth $\to$ Powers **Most Insightful**
- **💎 Prophetic / Deep**: Weighty reflection $\to$ Powers **Prophetic Discoveries**

### Invariant: Never Collapse Reactions
Reactions must never be collapsed into a single generic "like" counter. The 6-action bar provides individual touch targets for:
1. `🔥 Amen`
2. `💡 Insight`
3. `💎 Deep`
4. `💬 Comment`
5. `🔖 Bookmark / Save`
6. `↗ Share`

---

## 4. Key Files Reference

| Component | Path | Responsibility |
|---|---|---|
| `ScribesPostCard` | `client/lib/core/widgets/scribes_post_card.dart` | Hybrid Magazine feed card presentation |
| `ScribesConnectedPostCard` | `client/lib/core/widgets/scribes_connected_post_card.dart` | Riverpod-connected feed wrapper |
| `ScribesExploreCard` | `client/lib/core/widgets/scribes_explore_card.dart` | Fixed 280x400 Discover carousel card |
| `ScribesPostTile` | `client/lib/core/widgets/scribes_post_tile.dart` | Linear Twitter/X stream profile tile |
| `ScribesImageResolver` | `client/lib/core/widgets/scribes_image_resolver.dart` | Hierarchical URL resolution & image builder |
