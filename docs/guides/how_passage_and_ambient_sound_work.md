# How Passage Devotionals & Ambient Audio Work

This document provides a foundational and architectural deep dive into the **Passage** feature and its **Ambient Sound Engine** in Scribes.

---

## 1. Foundation: Why Passages & Ambient Sound Exist

### The Problem with Infinite-Scroll Articles for Contemplation
Traditional digital reading interfaces (like blog feeds or standard article scrolls) encourage fast skimming and vertical flinging. However, sacred theological study and devotional prayer demand **deliberate pacing, sensory focus, and segmented meditation**. When a reader is presented with a wall of text, their cognitive load increases, and the reflective posture is broken.

### Real-World Analogy
> **Think of a Passage like walking through an ancient illuminated manuscript in a quiet monastery cloister.** Instead of rolling out a single 20-foot parchment scroll all at once, the scribe presents you with individual illuminated panels one by one. As you turn each panel, soft choral chants or quiet rain fill the background, centering your attention entirely on the single verse, thought, or image before you.

---

## 2. System Architecture & End-to-End Lifecycle

```
[PASSAGE COMPOSER]
  ├── User drafts 2–12 panels (Text, Scripture, Reflection, Image)
  ├── User auditions & selects ambient track (SoundPickerSheet)
  └── User commits publish ──► POST /posts (post_type = 'passage')
                                      │
                                      ▼
[POSTGRESQL STORAGE]
  ├── posts (post_type: 'passage', sound_id: UUID)
  ├── sound_pool (id, title, category, audio_url, duration_sec)
  └── passage_panels (post_id, panel_order, panel_type, content, scripture_ref)
                                      │
                                      ▼
[FEED / EXPLORE VIEW]
  └── ScribesConnectedPostCard identifies post_type == 'passage'
        └── Tap routes to /passage/:id
                                      │
                                      ▼
[PASSAGE VIEWER DECK]
  ├── ScribesAudioPlayer initiates continuous background loop
  ├── Horizontal PageView.builder (Panels 0..N-1 + Completion Card)
  ├── Segmented top gold progress dashes
  └── Liturgical reaction bar (Amen, Insight, Deep)
```

---

## 3. Database Schema & Migration Invariants

### 1. The Post Type & Sound Pool (`000023_passage_and_sound_pool.up.sql`)
```sql
CREATE TYPE passage_panel_type AS ENUM (
    'text',
    'scripture',
    'reflection',
    'image'
);

CREATE TABLE sound_pool (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title        TEXT NOT NULL,
    category     TEXT NOT NULL, -- 'chant', 'nature', 'strings', 'acoustic', 'ambient'
    audio_url    TEXT NOT NULL,
    duration_sec INT NOT NULL DEFAULT 0,
    is_active    BOOLEAN NOT NULL DEFAULT true,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE posts
    ADD COLUMN sound_id UUID REFERENCES sound_pool(id);

CREATE TABLE passage_panels (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id              UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    panel_order          INT NOT NULL CHECK (panel_order >= 0 AND panel_order < 12),
    panel_type           passage_panel_type NOT NULL,
    content              JSONB NOT NULL DEFAULT '{}'::jsonb,
    background_image_url TEXT,
    scripture_ref        JSONB,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (post_id, panel_order)
);
```

### 2. Strict Immutability Rule
Unlike Standard Posts which support versioned revisions via `post_versions`, **Passages and Reflections are strictly immutable sacred compositions**. Once published, any call to `PUT /posts/:id` returns:
```http
HTTP/1.1 405 Method Not Allowed
Content-Type: application/json

{"error": "reflections and passages cannot be modified after publishing"}
```

---

## 4. Ambient Audio Sub-System (`ScribesAudioPlayer`)

The ambient audio system provides background acoustic contemplation without blocking the UI thread or leaking memory.

### Implementation Core (`client/lib/core/audio/scribes_audio_player.dart`)
```dart
class ScribesAudioPlayer {
  static final ScribesAudioPlayer instance = ScribesAudioPlayer._internal();
  final AudioPlayer _player = AudioPlayer();
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  Future<void> playLoop(String url) async {
    await _player.stop();
    await _player.setUrl(url);
    await _player.setLoopMode(LoopMode.one);
    await _player.setVolume(isMutedNotifier.value ? 0.0 : 1.0);
    await _player.play();
  }

  void toggleMute() {
    isMutedNotifier.value = !isMutedNotifier.value;
    _player.setVolume(isMutedNotifier.value ? 0.0 : 1.0);
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
```

### Key Audio Invariants:
1. **Single Source of Truth**: Ambient tracks are queried from the curated `sound_pool` table via `GET /sounds`.
2. **Lifecycle Safety**: When `PassageViewerScreen.dispose()` fires, `_audioPlayer.stop()` is called immediately to prevent ghost audio in the background.
3. **Isolated Mute Notification**: Mute toggles use `ValueNotifier<bool>` and `ValueListenableBuilder` to re-render only the audio pill icon without causing widget tree rebuilds.

---

## 5. Panel Composition & Viewer UX

### Panel Types:
1. **Text Panel**: Theological commentary or prose rendered in Cormorant Garamond typography.
2. **Scripture Panel**: Scripture excerpt with gold borders and visible translation attribution (*"Berean Standard Bible, public domain"*).
3. **Reflection Panel**: Prominent contemplative meditation prompt with gold drop caps.
4. **Image Panel**: Full-bleed sacred imagery with dark gradient scrim and high-contrast caption.

### Gestures & Progress Navigation:
- **Top Segmented Dashes**: Segmented gold indicators show active card index in the deck.
- **Horizontal Tap Zones**: Tapping the left 22% moves back one panel; tapping the right 22% advances.
- **Completion Card**: Summarizes the author profile and presents the 3-tier liturgical reaction bar (**Amen**, **Insight**, **Deep**).

---

## 6. Drawbacks & Trade-offs

| Design Decision | Benefit | Trade-off / Limitation |
|---|---|---|
| **Curated `sound_pool` table** | High acoustic quality, guaranteed valid audio links, zero piracy/copyright risk. | Users cannot upload arbitrary MP3 files from their device. |
| **Strict Immutability (HTTP 405)** | Preserves the integrity of devotional compositions and liturgical consistency. | Authors cannot fix minor typos after publishing; they must delete and recreate. |
| **Direct JSONB Panel Storage** | Fast single-query hydration with zero N+1 database joins. | Panel structure changes require JSONB migration scripts if new panel types are introduced. |
| **`just_audio` Streaming** | Instant playback start without downloading entire file before first sound. | Requires steady network connection on the very first play if not pre-cached by OS. |

---

## 7. Official Documentation & References

- **Audio Engine**: [`just_audio` Flutter Package](https://pub.dev/packages/just_audio)
- **PostgreSQL JSONB**: [PostgreSQL Documentation on JSON Types](https://www.postgresql.org/docs/current/datatype-json.html)
- **Riverpod State Management**: [Riverpod Official Guide](https://riverpod.dev)
- **Scribes Design System**: [Scribes Design Brief](file:///docs/ui/scribes_design_brief.md)
