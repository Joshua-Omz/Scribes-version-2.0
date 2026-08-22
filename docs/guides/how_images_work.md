# Scribes — How Images Work (Architecture & Client Specification)
**Version 1.0 · Media Pipeline, Extraction & UI Rendering Architecture**

---

## 1. Overview & Core Philosophy

In Scribes, imagery serves an illuminated, sacred aesthetic while operating under strict performance, offline-first, and memory constraints. Images can appear as post cover art, inline manuscript illustrations, passage panel backgrounds, or user avatars.

To maintain a 60/120 FPS jank-free reading experience on mobile devices, image handling follows four architectural pillars:

1. **Deterministic Resolution**: Image URLs are resolved hierarchically from domain fields, nested Quill Deltas, or passage panels.
2. **Local-First Disk Caching**: All remote assets are piped through `ScribesCacheManager` to ensure instant re-renders when offline.
3. **Decoded Memory Downscaling**: Images decoded into RAM must specify `memCacheWidth` (typically `800px`) to prevent high-resolution textures from overwhelming the GPU/RAM.
4. **Resilient Stack Layering**: Scrollable cards render background images via `ClipRRect` and `Stack` with error fallbacks and contrast overlays, never fragile `BoxDecoration.image` properties.

---

## 2. Backend Data Model & Media Pipeline

### Database Schema

Media in Scribes is managed through Cloudflare R2 / S3-compatible object storage and registered in PostgreSQL:

* **`media_uploads`**: Audit ledger recording uploader ID, URL, MIME type, dimensions, and size (up to 5MB).
* **`posts.cover_image_url`**: Nullable string on standard posts.
* **`posts.post_type`**: Enum (`'standard'` | `'passage'`). Passage posts use panel media rather than a single cover image.
* **`passage_panels`**: Multi-panel media records with `media_url` / `background_image_url`.

```sql
-- Migration 010: Media Uploads & Cover Images
CREATE TABLE media_uploads (
    id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    uploader_id  UUID        NOT NULL REFERENCES users(id),
    url          TEXT        NOT NULL UNIQUE,
    mime_type    TEXT        NOT NULL,
    size_bytes   BIGINT      NOT NULL,
    width_px     INT,
    height_px    INT,
    post_id      UUID        REFERENCES posts(id),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT valid_mime_type CHECK (mime_type IN ('image/jpeg', 'image/png', 'image/webp')),
    CONSTRAINT max_size CHECK (size_bytes <= 5242880)
);

ALTER TABLE posts
    ADD COLUMN post_type post_type NOT NULL DEFAULT 'standard',
    ADD COLUMN cover_image_url TEXT;
```

---

## 3. Client Domain Model & Content Formats

In Dart (`features/posts/domain/post.dart`), a post's visual content can be represented in multiple forms:

```dart
@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'post_type') @Default('standard') String postType,
    @JsonKey(fromJson: _contentFromJson) required Map<String, dynamic> content,
    // ...
  }) = _Post;
}
```

### Media Storage Locations Inside `Post`

1. **`post.coverImageUrl`**: Dedicated top-level cover image (primary source for standard posts).
2. **`post.content['cover_image_url']` / `post.content['imageUrl']`**: Top-level keys within the rich-text JSON payload.
3. **Quill Delta `ops`**: Rich-text delta operations containing inline images:
   ```json
   {
     "ops": [
       { "insert": { "image": "https://media.scribes.app/uploads/illuminated-bible.webp" } },
       { "insert": "\n" }
     ]
   }
   ```
4. **Passage Panels**: Array of panels with background images for immersive scripture presentations.

---

## 4. Hierarchical Image Extraction

To guarantee that cards and previews reliably discover images regardless of whether the post was created via rich-text drafting, quick capture, or passage composition, the UI employs a fallback extractor:

```dart
String? extractFirstImageUrl(Post post) {
  // 1. Direct top-level domain field
  if (post.coverImageUrl != null && post.coverImageUrl!.trim().isNotEmpty) {
    return post.coverImageUrl!.trim();
  }

  final content = post.content;

  // 2. Direct keys in JSONB content
  for (final key in ['cover_image_url', 'coverImageUrl', 'image_url', 'imageUrl', 'image', 'banner_url']) {
    if (content.containsKey(key) && content[key] != null) {
      final url = content[key].toString().trim();
      if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('/'))) {
        return url;
      }
    }
  }

  // 3. Helper to scan Quill Delta operations
  String? scanOps(List<dynamic> ops) {
    for (final op in ops) {
      if (op is Map) {
        final insert = op['insert'];
        if (insert is Map && insert.containsKey('image')) {
          final img = insert['image']?.toString().trim();
          if (img != null && img.isNotEmpty) return img;
        }
        final attributes = op['attributes'];
        if (attributes is Map && attributes.containsKey('image')) {
          final img = attributes['image']?.toString().trim();
          if (img != null && img.isNotEmpty) return img;
        }
      }
    }
    return null;
  }

  // 4. Inspect content body (List, Map, or JSON String)
  final body = content['body'];
  if (body is List) {
    final img = scanOps(body);
    if (img != null) return img;
  } else if (body is Map && body['ops'] is List) {
    final img = scanOps(body['ops'] as List);
    if (img != null) return img;
  } else if (body is String && body.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        final img = scanOps(decoded);
        if (img != null) return img;
      } else if (decoded is Map && decoded['ops'] is List) {
        final img = scanOps(decoded['ops'] as List);
        if (img != null) return img;
      }
    } catch (_) {}
  }

  // 5. Inspect root ops
  final ops = content['ops'];
  if (ops is List) {
    final img = scanOps(ops);
    if (img != null) return img;
  }

  // 6. Inspect passage panels
  final panels = content['panels'];
  if (panels is List) {
    for (final panel in panels) {
      if (panel is Map) {
        final mediaUrl = panel['media_url'] ?? panel['background_image_url'] ?? panel['image_url'];
        if (mediaUrl != null && mediaUrl.toString().trim().isNotEmpty) {
          return mediaUrl.toString().trim();
        }
      }
    }
  }

  return null;
}
```

---

## 5. UI Rendering & Performance Invariants

### Invariant 1: Mandatory `CachedNetworkImage` with Memory Downsampling
Never use raw `Image.network` or `NetworkImage` inside list items or explore cards. Always use `CachedNetworkImage` paired with `ScribesCacheManager.instance`:

* **Disk Caching**: Images are cached locally in SQLite/files on the device for instant offline availability.
* **`memCacheWidth: 800`**: Downsamples high-res camera uploads to 800px width before uploading to GPU textures. This prevents out-of-memory crashes on mid-range Android devices.

### Invariant 2: Stack Layering over `BoxDecoration.image`
`BoxDecoration.image: DecorationImage(image: NetworkImage(...))` causes unhandled paint exceptions or blank boxes if network requests drop or URLs 404. 

Instead, cards wrap their layout in a `ClipRRect` and `Stack`:

```dart
Container(
  width: 280,
  height: 400,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: colors.border.withValues(alpha: 0.5)),
    color: colors.surfaceRaised,
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Stack(
      children: [
        // 1. Background image layer with fallback
        if (hasImage)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: displayImageUrl,
              cacheManager: ScribesCacheManager.instance,
              memCacheWidth: 800,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: colors.surfaceRaised),
              errorWidget: (context, url, error) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.surfaceRaised, colors.background],
                  ),
                ),
              ),
            ),
          )
        else
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.surfaceRaised, colors.background],
                ),
              ),
            ),
          ),

        // 2. High-contrast readability overlay
        if (hasImage)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.black87],
                ),
              ),
            ),
          ),

        // 3. Foreground text & interactive leaf widgets
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            // ...
          ),
        ),
      ],
    ),
  ),
);
```

### Invariant 3: Ticker Isolation on Card Cards
Never wrap full post cards or explore cards in `ScribesBounceButton` or custom `AnimationController` widgets that instantiate `TickerProviderStateMixin` per item. Wrap cards with native `GestureDetector` or `InkWell` to maintain smooth 60fps horizontal flings.

---

## 6. Component Reference Map

| Component | File Path | Media Responsibility |
|---|---|---|
| `ScribesExploreCard` | `lib/core/widgets/scribes_explore_card.dart` | Discover tab cards: full-bleed background images with dark scrims |
| `ScribesPostCard` | `lib/core/widgets/scribes_post_card.dart` | Feed post cards: 16:9 aspect-ratio cover image previews |
| `ScribesAvatar` | `lib/core/widgets/scribes_avatar.dart` | User profile avatars with monograms and caching |
| `ScribesCacheManager` | `lib/core/storage/scribes_cache_manager.dart` | Centralized `BaseCacheManager` configuration for offline SQLite asset store |
| `PublishMetadataScreen` | `lib/features/compose/presentation/publish_metadata_screen.dart` | Cover image selector, cropper, and presigned R2 upload caller |
