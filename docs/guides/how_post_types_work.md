# How Post Types Work in Scribes

This guide explains the structural, architectural, and user-experience differences between the three distinct post types in Scribes: **Standard**, **Reflection**, and **Passage**.

---

## 1. Foundation: The Need for Distinct Post Types

In early iterations of content platforms, all content is often forced into a single generic "Post" entity with arbitrary text and media attachments. However, Christian theological reflection, deep study, and quick contemplation represent fundamentally different devotional expressions:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SCRIBES POST TYPES                                │
├─────────────────────────┬─────────────────────────┬─────────────────────────┤
│        STANDARD         │       REFLECTION        │         PASSAGE         │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ • Long-form teaching    │ • Quick contemplation   │ • Multi-panel deck      │
│ • Rich-text editor      │ • ≤ 500 characters      │ • 2 to 12 panels        │
│ • 16:9 Cover image      │ • Quoted verse tag      │ • Ambient sound track   │
│ • 2–3 Scripture tags    │ • Inline photo attach   │ • Immersive reader      │
│ • Version revision tree │ • Strict immutability   │ • Strict immutability   │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

### Real-World Analogy
> **Think of Standard posts as published treatises or theological essays, Reflections as handwritten marginalia in the margins of your Bible, and Passages as illuminated liturgical prayer books.** Each serves a unique spiritual and intellectual purpose, and forcing them into the same shape degrades the reading and writing experience of all three.

---

## 2. Technical Comparison Matrix

| Property | Standard Post | Reflection Post | Passage Post |
|---|---|---|---|
| **Database `post_type`** | `'standard'` | `'reflection'` | `'passage'` |
| **Length Limit** | Unlimited (Rich Text) | $\le 500$ plain characters | 2 to 12 distinct panels |
| **Scripture Tags** | Exactly 2 to 3 tags required | 0 to 1 optional quoted verse | Encapsulated in scripture panels |
| **Cover Media** | 16:9 `cover_image_url` | Single `reflection_image_url` | Panel background images |
| **Audio Support** | None | None | Ambient track via `sound_id` FK |
| **Revision Support** | Full `post_versions` tree | None (HTTP 405 Immutable) | None (HTTP 405 Immutable) |
| **Composer Screen** | `DraftEditorScreen` | `ReflectionComposerScreen` | `PassageComposerScreen` |
| **Viewer Screen** | `PostDetailScreen` | `PostDetailScreen` (Flat) | `PassageViewerScreen` (Deck) |

---

## 3. Database Schema & Constraints

In PostgreSQL, the `posts` table is enforced with mutually exclusive check constraints to prevent invalid cross-type metadata states:

```sql
-- 1. Post type enum
CREATE TYPE post_type AS ENUM ('standard', 'passage', 'reflection');

-- 2. Cover image standard-only check
ALTER TABLE posts
    ADD CONSTRAINT cover_image_standard_only
    CHECK (
        cover_image_url IS NULL
        OR post_type = 'standard'
    );

-- 3. Reflection image reflection-only check
ALTER TABLE posts
    ADD CONSTRAINT reflection_image_only_on_reflection
    CHECK (
        reflection_image_url IS NULL
        OR post_type = 'reflection'
    );
```

---

## 4. UI Entry Point: `ComposeTypeSheet`

When the user taps the global compose action (the center FAB or bottom nav compose icon), rather than jumping blindly into a blank text editor, the application presents the glassmorphic **`ComposeTypeSheet`**:

```dart
// client/lib/features/compose/presentation/compose_type_sheet.dart

class ComposeTypeSheet extends StatelessWidget {
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ComposeTypeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Renders the 3 options with iconography and concise subtitles
    );
  }
}
```

---

## 5. Drawbacks & Trade-offs

| Decision | Benefits | Drawbacks / Trade-offs |
|---|---|---|
| **Distinct Composer Screens** | Highly optimized UX tailored specifically for each writing style; zero cluttered or conditional UI fields. | Slightly more presentation code to maintain compared to a single monolithic composer. |
| **Database Check Constraints** | Guarantees database integrity at the SQL level regardless of client version. | Adding a 4th post type in the future requires updating enum values and table constraints via migrations. |
| **Immutability on Reflections/Passages** | Keeps discussions and community reactions synchronized with the exact original composition. | Users who make a typo must delete and repost. |

---

## 6. Official References

- **Scribes Design Brief**: [Design Tokens & Principles](file:///docs/ui/scribes_design_brief.md)
- **Media Migration SOT**: [Media Expansion Rules](file:///docs/source-of-truth/scribes_media_migration.md)
- **Backend SOT**: [43-Endpoint Backend Source of Truth](file:///docs/source-of-truth/backend_source_of_truth.md)
