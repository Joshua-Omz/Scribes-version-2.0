# Elevate Scribes UI/UX to Premium Standards

This plan outlines the specific code changes required to implement the recommendations from our UI/UX audit, elevating the app to feel dynamic, alive, and thoroughly modern.

> [!NOTE]  
> **Status: ✅ Complete.** All items below have been implemented.

## Implemented Changes

---

### 1. Micro-Animations & Haptics (The "Feel") ✅

We added a subtle scale-down effect (squash-and-stretch) and light haptic feedback to interactive elements.

#### [DONE] `core/widgets/scribes_bounce_button.dart`
- Reusable wrapper widget using `AnimationController` and `ScaleTransition`.
- On tap down, scales the child widget down to `0.92`.
- On tap up, springs back to `1.0`.
- Integrates `HapticFeedback.lightImpact()` for a light physical tap sensation.

#### [DONE] `core/widgets/scribes_diamond_fab.dart`
- FAB wrapped in `ScribesBounceButton`.

#### [DONE] `core/widgets/scribes_bottom_nav.dart`
- Each navigation item wrapped in `ScribesBounceButton` so tabs feel responsive when switched.

#### [DONE] `core/widgets/scribes_reaction_bar.dart`
- Like/Save/Comment buttons wrapped in `ScribesBounceButton` with `scaleFactor: 0.95`.

---

### 2. Glassmorphism & Depth (The "Look") ✅

We replaced solid background colors on floating/layered elements with a frosted-glass blur effect.

#### [DONE] `core/widgets/scribes_top_app_bar.dart`
- `ClipRect` and `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`.
- Background color translucent: `colors.background.withValues(alpha: 0.8)`.

#### [DONE] `core/widgets/scribes_bottom_nav.dart`
- Same `BackdropFilter` treatment applied.
- Hard top border replaced with a subtle glowing `BoxShadow`.

#### [DONE] `core/widgets/scribes_comment_sheet.dart`
- Bottom sheet has glassmorphic background with `BackdropFilter`.

---

### 3. Custom Toasts (The "Polish") ✅

The default Flutter `SnackBar` has been fully replaced with a custom, floating animated toast system.

#### [DONE] `core/widgets/scribes_toast.dart`
- Global utility `ScribesToast.show(context, message, colors)`.
- Pill-shaped, floating container with gold icon + themed shadow.
- Supports `isError: true` for error styling (orange treatment).

#### [DONE] Full SnackBar → ScribesToast migration
All raw `ScaffoldMessenger.of(context).showSnackBar(...)` calls across the entire codebase have been replaced:

| File | Count | Context |
|---|---|---|
| `core/widgets/scribes_connected_post_card.dart` | 2 | Save/unsave post |
| `core/widgets/scribes_drawer.dart` | 2 | Bookmarks/Settings coming soon |
| `core/widgets/scribes_comment_sheet.dart` | 1 | DM coming soon |
| `features/profile/presentation/public_profile_screen.dart` | 2 | Save/unsave post |
| `features/profile/presentation/private_profile_screen.dart` | 2 | Save/unsave post |
| `features/compose/presentation/publish_metadata_screen.dart` | 6 | Validation + publish feedback |
| `features/compose/presentation/draft_editor_screen.dart` | 2 | Scripture tag feedback |
| `features/auth/presentation/auth_gate_screen.dart` | 2 | Google sign-in + auth errors |
| `features/profile/presentation/edit_profile_screen.dart` | 1 | Profile updated (already migrated) |
| `features/notes/presentation/note_editor_screen.dart` | 2 | Copy to drafts (already migrated) |
| `features/draft/presentation/drafts_list_screen.dart` | 1 | Draft deleted (already migrated) |

**Total: 0 raw SnackBar calls remain in the codebase** (only `scribes_toast.dart` itself uses `showSnackBar` internally).
