import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';

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
      // Compose is an action, not a tab
      context.push('/compose');
      return;
    }

    int branchIndex = 0;
    if (index == 0) {
      branchIndex = 0;
    } else if (index == 1) {
      branchIndex = 1;
    } else if (index == 3) {
      branchIndex = 2;
    } else if (index == 4) {
      branchIndex = 3;
    } else if (index == 5) {
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

  @override
  Widget build(BuildContext context) {
    // Listen to global notifications
    /* ref.listen(notificationStreamProvider, (prev, next) {
      final notif = (next as dynamic).value;
      if (notif != null && notif.type == 'direct_message') {
        ScribesMessageBanner.show(
          context,
          title: 'New Message',
          message: notif.body,
          onTap: () {
            _onTap(context, 3);
          },
        );
        ref.read(conversationsProvider.notifier).refresh();
      }
    }); */

    int uiIndex = 0;
    if (widget.navigationShell.currentIndex == 0) {
      uiIndex = 0;
    } else if (widget.navigationShell.currentIndex == 1) {
      uiIndex = 1;
    } else if (widget.navigationShell.currentIndex == 2) {
      uiIndex = 3;
    } else if (widget.navigationShell.currentIndex == 3) {
      uiIndex = 4;
    } else if (widget.navigationShell.currentIndex == 4) {
      uiIndex = 5;
    }

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: widget.children
            .map((c) => _KeepAliveBranch(child: c))
            .toList(),
      ),
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

    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      offset: isVisible ? Offset.zero : const Offset(0, 1.0),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: colors.glassBlur,
            sigmaY: colors.glassBlur,
          ),
          child: Container(
            height: 85,
            decoration: BoxDecoration(
              color: colors.glassFill,
              border: Border(top: BorderSide(color: colors.border, width: 1.0)),
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
                    /* _buildNavItem(
                      context,
                      colors,
                      HugeIcons.strokeRoundedChatAdd,
                      'Messages',
                      3,
                      showDot: ref.watch(unreadMessagesCountProvider) > 0,
                    ), */
                    _buildNavItem(
                      context,
                      colors,
                      HugeIcons.strokeRoundedFileEdit,
                      'Notes',
                      4,
                    ),
                    _buildNavItem(
                      context,
                      colors,
                      HugeIcons.strokeRoundedProfile,
                      'Profile',
                      5,
                    ),
                  ],
                ),
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
