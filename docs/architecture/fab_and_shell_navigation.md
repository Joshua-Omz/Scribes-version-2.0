# Viewport Chrome Architecture: Shell FAB Hoisting & Geometry Coordination

## 1. Foundation Before Syntax: The Root Problem

In modern cross-platform mobile architecture, coordinating floating action controls with persistent bottom navigation chrome presents a subtle but critical viewport geometry problem. 

### Think Of It Like A Stage Theatre
Think of it like a theatre production. The persistent shell (`ScaffoldWithNavBar`) is the physical stage proscenium, orchestra pit, and lighting rig. The child screens (`FeedScreen`, `NotesListScreen`) are individual scenes that slide onto the stage behind the proscenium.
- If an individual actor in scene 1 tries to position their own floating spotlight at "stage floor minus 2 feet" (`y = screenHeight - 16 - fabHeight`), but the orchestra pit (`ScribesBottomNav`) is elevated 4 feet above the floor, the spotlight ends up buried completely inside the orchestra pit. 
- To make matters worse, because the orchestra pit sits physically in front of the actors, any touch gestures aimed at the spotlight are swallowed by the pit.

```
┌────────────────────────────────────────────────────────┐
│ Screen Root (Display Boundary)                         │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Nested Scaffold Body (FeedScreen / NotesScreen)   │  │
│  │                                                  │  │
│  │                                                  │  │
│  │                                                  │  │
│  │   [Hidden FAB] <─── Nested Scaffold: y = H - 72  │  │
│  └──────────────────────────────────────────────────┘  │
│  ════════════════════════════════════════════════════  │
│  ScribesBottomNav (Height: 85px + SafeArea ≈ 115px)    │  │
│  (Renders ON TOP of body due to extendBody: true)     │  │
└────────────────────────────────────────────────────────┘
```

### Why Flutter's Default Geometry Fails with `extendBody: true`
In Flutter, enabling `extendBody: true` on a `Scaffold` directs the framework to extend the scrollable body underneath a translucent or frosted-glass `bottomNavigationBar`. 
However, Flutter's default `FloatingActionButtonLocation.endFloat` computes the vertical offset via `ScaffoldPrelayoutGeometry.contentBottom`:
```dart
// Flutter Framework (scaffold.dart)
final double contentBottom = extendBody
    ? size.height - bottomViewPadding
    : (bottomNavigationBarTop ?? (size.height - bottomViewPadding));
```
When `extendBody` is `true`, `contentBottom` stretches to `size.height - bottomViewPadding`, ignoring the height of the `bottomNavigationBar`. Consequently:
1. If placed on an inner nested Scaffold, the inner Scaffold has no bottom navigation bar attached, so it renders the FAB at the bottom edge, directly underneath the outer shell's translucent bar.
2. Even if placed on the outer Scaffold, Flutter's default `endFloat` still fails to offset above the bar because `extendBody: true` drops `contentBottom` to the bottom of the screen.

---

## 2. Ground Truth: Documentation & Community Standards

Official Flutter documentation and community practices establish two core patterns for handling this geometry:
1. **Official Flutter Documentation (`FloatingActionButtonLocation`)**:
   Flutter’s API exposes `FloatingActionButtonLocation` specifically to allow applications to calculate custom `Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry)`. The `ScaffoldPrelayoutGeometry` provides measured dimensions for `scaffoldSize`, `floatingActionButtonSize`, `bottomNavigationBarSize`, and `minViewPadding`.
2. **Community Best Practice (Single Viewport Shell)**:
   In applications with persistent tab navigation (using `go_router`'s `StatefulShellRoute`), the prevailing community pattern is **Shell Hoisting**: child screens must not own persistent navigation chrome or root action buttons. The shell coordinates the layout chrome, while leaf screens publish state or contextual actions via reactive providers.

---

## 3. The Implementation: Shell FAB Hoisting

Our solution coordinates navigation chrome and floating actions at the root shell level through three cohesive mechanisms:

### A. The Geometry Coordination (`FloatingActionButtonLocation.endFloat`)
Flutter's `Scaffold` manages bottom-anchored material chrome inside `_ScaffoldLayout`. Specifically, it measures the layout height of `bottomNavigationBar` (`bottomWidgetsHeight = 85.0 + safeArea`) and sets:
```dart
contentBottom = math.max(0.0, bottom - math.max(minInsets.bottom, bottomWidgetsHeight));
```
When `floatingActionButton` is placed on `ScaffoldWithNavBar`, Flutter's native `FloatingActionButtonLocation.endFloat` computes:
```dart
fabY = contentBottom - fabHeight - kFloatingActionButtonMargin;
```
Because `ScaffoldWithNavBar` owns both the `floatingActionButton` and the `bottomNavigationBar: ScribesBottomNav`, Flutter's layout solver natively ensures the FAB docks exactly 16dp above the top border of `ScribesBottomNav`.
Conversely, when child screens (`FeedScreen`, `NotesListScreen`) declare their own internal Scaffolds without a `bottomNavigationBar`, their local `contentBottom` stretches to the bottom of the screen (`screenHeight - safeArea`), placing the FAB 16dp from the floor of the screen. Because the outer shell renders `ScribesBottomNav` on top of the child screen, the 115px navigation bar completely submerges the inner FAB. Hoisting the FAB to the outer shell completely eliminates this failure mode.

### B. Reactive Shell Overrides (`shellFabOverrideProvider`)
The shell defines the default FAB based on the active tab, but exposes a reactive `ShellFabOverrideNotifier` so child screens can dynamically take over the slot (e.g. multi-selection mode in `NotesListScreen`):

```dart
/// Client: lib/core/widgets/scribes_bottom_nav.dart
class ShellFabOverrideNotifier extends Notifier<Widget?> {
  @override
  Widget? build() => null;

  void set(Widget? widget) => state = widget;
  void clear() => state = null;
}

final shellFabOverrideProvider =
    NotifierProvider<ShellFabOverrideNotifier, Widget?>(() {
      return ShellFabOverrideNotifier();
    });
```

In `ScaffoldWithNavBar`:
```dart
Widget? _buildShellFab(
  BuildContext context,
  int branchIndex,
  Widget? overrideFab,
  ScribesColors colors,
) {
  // Contextual override from child screen (e.g. Notes selection mode)
  if (overrideFab != null && branchIndex == 3) {
    return overrideFab;
  }

  // Branch 0: Feed Screen
  if (branchIndex == 0) {
    return const ScribesExpandableFab();
  }

  // Branch 3: Notes List Screen
  if (branchIndex == 3) {
    return ScribesGlassFab(
      onTap: () {
        ref.read(noteEditorProvider.notifier).reset();
        context.push('/notes/edit');
      },
    );
  }

  return null;
}
```

### C. Zero-Jank Scroll & State Synchronization
In compliance with our architectural performance invariant (*Zero Page Rebuilds on Scroll*):
- Scrolling in `FeedScreen` notifies `bottomNavVisibilityProvider.notifier.show()` / `hide()`.
- `FeedScreen` does **not** call `setState()`, nor does it rebuild.
- `ScaffoldWithNavBar` watches `bottomNavVisibilityProvider` and translates both the bottom nav bar and the FAB down via synchronized `AnimatedSlide(offset: isNavVisible ? Offset.zero : const Offset(0, 2.5))`.

### D. High-Contrast Sacred Styling (`ScribesGlassFab` & `ScribesExpandableFab`)
To guarantee visibility across all three themes (Night, Parchment, Silver):
- Replaced faint translucent fills with `colors.surfaceRaised.withValues(alpha: 0.88)`.
- Bound a crisp, radiant gold border: `Border.all(color: colors.gold.withValues(alpha: 0.75), width: 1.5)`.
- Added a dual drop-shadow system: 16px ambient black shadow for depth separation plus a 12px warm gold aura for divine illumination.

---

## 4. Drawbacks & Trade-offs

| Aspect | Shell Hoisting Approach | Trade-off / Limitation |
|---|---|---|
| **Separation of Concerns** | Viewport chrome geometry is unified in the shell; inner screens focus purely on content. | Child screens cannot simply declare `Scaffold(floatingActionButton: ...)` and must publish overrides to `shellFabOverrideProvider`. |
| **Animation Synchronization** | FAB and bottom nav slide in/out in perfect lockstep during flings. | Requires passing action callbacks via Riverpod or closures rather than purely local widget state. |
| **Lifecycle & Cleanup** | `shellFabOverrideProvider` cleanly decouples view hierarchy. | Child screens must ensure `dispose()` resets `shellFabOverrideProvider.notifier.state = null` so stale action bars do not leak across routes. |

---

## 5. Usage Guide: Adding or Overriding FABs

### To register a default FAB for a new shell tab:
1. Open `lib/core/widgets/scribes_bottom_nav.dart`.
2. Locate `_buildShellFab(BuildContext context, int branchIndex, ...)`.
3. Add a branch for your tab's `branchIndex`:
   ```dart
   if (branchIndex == 1) {
     return ScribesGlassFab(
       icon: HugeIcons.strokeRoundedFilterHorizontal,
       onTap: () => _openExploreFilter(),
     );
   }
   ```

### To dynamically override the FAB from a leaf screen:
1. In your screen's selection/action handler:
   ```dart
   ref.read(shellFabOverrideProvider.notifier).state = MyContextualActionBar();
   ```
2. When the user exits the mode or in your State's `dispose()`:
   ```dart
   @override
   void dispose() {
     ref.read(shellFabOverrideProvider.notifier).state = null;
     super.dispose();
   }
   ```
