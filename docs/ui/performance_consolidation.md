# Scribes UI Performance Consolidation Plan

## Architecture Philosophy: Discovery vs. Immersion
To eliminate Flutter scroll stuttering (jank), we are fundamentally separating concerns between screens:
* **The Feed Screen (Discovery):** Optimized strictly for high-speed scrolling and visual scanning. Interactivity is stripped to the bare minimum.
* **The Post Detail Screen (Immersion):** Optimized for deep reading, reflection, and granular interaction. 

---

## 1. The Feed Screen: `ScribesLightPostTile`
The feed card is stripped of heavy state and local computations to guarantee a 16ms render pipeline.

### Architectural Rules
* **Strict ID-Based State:** The card must accept only a `postId`. It must use Riverpod's `.select()` to fetch its own normalized data from the store, ensuring `O(1)` rebuilds when reactions or data change. The parent list must never pass down full `Post` objects.
* **No Inline Expansions:** Scripture tags on the feed card are strictly visual. Tapping the card (or the tags on it) routes the user directly to the Post Detail screen.
* **Constraint-Based Sizing:** Remove all instances of `MediaQuery.sizeOf(context)` inside the card. Use `AspectRatio` to allow the Flutter C++ layout engine to size the cover image based on available width, decoupling the card from global screen changes (like keyboard pop-ups).
* **Main-Thread Image Protection:** Always pass a fixed `memCacheWidth` (e.g., `800`) to the image network decoder to force background downscaling and prevent memory spikes during fast scroll flings.

---

## 2. The Post Detail Screen: Information Hierarchy
The detail screen receives all the micro-interactivity removed from the feed, but structurally separates the "anchor" thesis from the "inline" evidence.

### Anchor vs. Inline Separation
* **The Anchor Scripture (The Thesis):** The primary scripture passage the post is based on is extracted from the metadata and rendered at the very top of the layout using a dedicated `ScribesAnchorScriptureBlock`. It is visually styled as a prominent foundational text (e.g., parchment background, gold accents) explicitly different from a standard tag.
* **The Note (The Evidence):** The author's rich-text reflection sits beneath the Anchor. It contains standard inline `ScribesScriptureChip`s.

### Scripture Interaction (Dialogue over Inline)
* Overriding the previous inline-expansion invariant, tapping an inline `ScribesScriptureChip` inside the Post Detail screen will trigger the existing **Scripture Ref Dialogue (Modal)** pop-up.
* This relies entirely on the local SQLite edge-distributed translation artifacts (zero API calls) and must display the translation attribution.

### Quill Read-Only Safety (Node Pointer Deactivation)
When rendering the rich text note via the Flutter Quill editor (or equivalent JSONB renderer), you must strictly enforce read-only isolation to prevent scroll lag and layout thrashing.
* `showCursor: false`
* `enableSelectionToolbar: false`
* `readOnlyMouseCursor: SystemMouseCursors.basic`
* **Node Pointer Deactivation:** Explicitly deactivate focus nodes (e.g., passing a dummy `FocusNode()` or setting `canRequestFocus: false`) to ensure that accidental taps on the text do not summon the keyboard, attach gesture recognizers, or trigger selection handles.

### Cache-First Hydration
The detail screen must never show a loading spinner on entry. It must resolve the `Post` object synchronously from the local Drift SQLite database to render the UI instantly, while network synchronization happens silently in the background.

---

## 3. The Implementation Migration Path
1. Implement `ScribesLightPostTile` and swap it into the Feed and Explore screens.
2. Build the `ScribesAnchorScriptureBlock` component.
3. Restructure `PostDetailScreen` to elevate the Anchor block above the rich-text body.
4. **Remove the reaction chip bar** from the legacy design.
5. **Redesign the comment textbox** to have a modern appearance with no active/focused outline.
6. Implement a **smooth scroll-down transition** that navigates the user directly to the comment section on click.
7. Wire the inline chips in the detail screen to trigger the existing Scripture Ref Dialogue.
8. Verify Quill focus nodes are strictly disabled in the rich text viewer.
