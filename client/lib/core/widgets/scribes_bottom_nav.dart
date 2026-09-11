import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';
import '../../features/compose/presentation/compose_type_sheet.dart';

/// Notifier and provider allowing child screens (e.g. NotesList in multi-select mode) to dynamically
/// publish action overrides to the persistent shell-level Floating Action Button slot.
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

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    required this.children,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  late PageController _pageController;
  bool _isProgrammaticChange = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant ScaffoldWithNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _pageController.page?.round()) {
      _isProgrammaticChange = true;
      _pageController.jumpToPage(widget.navigationShell.currentIndex);
      _isProgrammaticChange = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // Compose is an action, not a tab — show the compose type selection sheet
      ComposeTypeSheet.show(context);
      return;
    }

    int branchIndex = 0;
    if (index == 0) {
      branchIndex = 0;
    } else if (index == 1) {
      branchIndex = 1;
    } else if (index == 3) {
      branchIndex = 3;
    } else if (index == 4) {
      branchIndex = 4;
    }

    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  void _onPageChanged(int branchIndex) {
    if (_isProgrammaticChange) return;
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

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

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final overrideFab = ref.watch(shellFabOverrideProvider);
    int uiIndex = 0;
    if (widget.navigationShell.currentIndex == 0) {
      uiIndex = 0;
    } else if (widget.navigationShell.currentIndex == 1) {
      uiIndex = 1;
    } else if (widget.navigationShell.currentIndex == 3) {
      uiIndex = 3;
    } else if (widget.navigationShell.currentIndex == 4) {
      uiIndex = 4;
    }

    final activeFab = _buildShellFab(
      context,
      widget.navigationShell.currentIndex,
      overrideFab,
      colors,
    );

    Widget? fabWidget;
    if (activeFab != null) {
      fabWidget = Consumer(
        builder: (context, ref, child) {
          final isNavVisible = ref.watch(bottomNavVisibilityProvider);
          return IgnorePointer(
            ignoring: !isNavVisible,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              offset: isNavVisible ? Offset.zero : const Offset(0, 2.5),
              child: child!,
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: KeyedSubtree(
            key: ValueKey<String>(
              'shell_fab_${widget.navigationShell.currentIndex}_${overrideFab != null}',
            ),
            child: activeFab,
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: widget.children
            .map((c) => _KeepAliveBranch(child: c))
            .toList(),
      ),
      floatingActionButton: fabWidget,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ScribesBottomNav(
        currentIndex: uiIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}


class BottomNavVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void show() => state = true;
  void hide() => state = false;
}

final bottomNavVisibilityProvider =
    NotifierProvider<BottomNavVisibilityNotifier, bool>(() {
      return BottomNavVisibilityNotifier();
    });

class ScribesBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Color backgroundColor;
  final Function(int) onTap;

  const ScribesBottomNav({
    super.key,
    this.backgroundColor = Colors.transparent,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final isVisible = ref.watch(bottomNavVisibilityProvider);

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0, 1.0),
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            color: colors.surfaceRaised.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: colors.border.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
            child: SafeArea(
              bottom: true,
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(
                    context,
                    colors,
                    HugeIcons.strokeRoundedScrollHorizontal,
                    'Scroll',
                    0,
                  ),
                  _buildNavItem(
                    context,
                    colors,
                    HugeIcons.strokeRoundedSearch01,
                    'Search',
                    1,
                  ),
                  _buildComposeButton(
                    context,
                    colors,
                  ),
                  _buildNavItem(
                    context,
                    colors,
                    HugeIcons.strokeRoundedFileEdit,
                    'Notes',
                    3,
                  ),
                  _buildNavItem(
                    context,
                    colors,
                    HugeIcons.strokeRoundedProfile,
                    'Profile',
                    4,
                  ),
                ],
                ),
              ),
            ),
          ),
        );
      }

  Widget _buildNavItem(
    BuildContext context,
    colors,
    dynamic icon,
    String label,
    int index, {
    bool showDot = false,
  }) {
    final isSelected = currentIndex == index;

    final innerContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            isSelected
                ? HugeIcon(icon: icon, color: colors.primaryText, size: 22)
                : HugeIcon(icon: icon, color: colors.secondaryText, size: 22),
            if (showDot)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4520A), // orange
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        if (isSelected) ...[
          const SizedBox(height: 2),
          Text(
            label,
            style: ScribesTextStyles.labelSm.copyWith(
              color: colors.primaryText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );

    return Expanded(
      child: ScribesBounceButton(
        onTap: () => onTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: innerContent,
        ),
      ),
    );
  }

  Widget _buildComposeButton(
    BuildContext context,
    ScribesColors colors,
  ) {
    return Expanded(
      child: ScribesBounceButton(
        onTap: () => onTap(2),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.22),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedQuillWrite02,
                    color: colors.gold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeepAliveBranch extends StatefulWidget {
  final Widget child;
  const _KeepAliveBranch({required this.child});

  @override
  State<_KeepAliveBranch> createState() => _KeepAliveBranchState();
}

class _KeepAliveBranchState extends State<_KeepAliveBranch>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
