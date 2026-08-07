import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';
import '../../features/notifications/application/notification_provider.dart';
import '../../features/messages/application/inbox_providers.dart';
import 'scribes_message_banner.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // Compose is an action, not a tab
      context.push('/compose');
      return;
    }

    // Map UI indices to branch indices
    int branchIndex = 0;
    if (index == 0) { branchIndex = 0; }
    else if (index == 1) { branchIndex = 1; }
    else if (index == 3) { branchIndex = 2; }
    else if (index == 4) { branchIndex = 3; }

    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      branchIndex,
      // A common pattern when tapping an active tab is to pop to the initial location.
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to global notifications
    ref.listen(notificationStreamProvider, (prev, next) {
      final notif = (next as dynamic).value;
      if (notif != null && notif.type == 'direct_message') {
        ScribesMessageBanner.show(
          context,
          title: 'New Message',
          message: notif.body,
          onTap: () {
            // Navigate to inbox or directly to conversation
            // For now, just go to inbox (tab 3, branch 2)
            _onTap(context, 3);
          },
        );
        // Invalidate inbox
        ref.read(conversationsProvider.notifier).refresh();
      }
    });

    // Map branch index back to UI index
    int uiIndex = 0;
    if (navigationShell.currentIndex == 0) { uiIndex = 0; }
    else if (navigationShell.currentIndex == 1) { uiIndex = 1; }
    else if (navigationShell.currentIndex == 2) { uiIndex = 3; }
    else if (navigationShell.currentIndex == 3) { uiIndex = 4; }

    return Scaffold(
      body: navigationShell,
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

final bottomNavVisibilityProvider = NotifierProvider<BottomNavVisibilityNotifier, bool>(() {
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

    // AnimatedContainer collapses height to 0 when hidden so that no
    // ghost layer is left behind in the Scaffold's layout space.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: isVisible ? 85 : 0,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.8),
            boxShadow: [
              BoxShadow(
                color: colors.primaryText.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: 85,
          child: SafeArea(
            bottom: true,
            top: false,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(context, colors, HugeIcons.strokeRoundedNote01, 'Scroll', 0),
              _buildNavItem(context, colors, HugeIcons.strokeRoundedSearch01, 'Search', 1),
              _buildNavItem(
                context, 
                colors, 
                HugeIcons.strokeRoundedChatAdd, 
                'Messages', 
                3,
                showDot: ref.watch(unreadMessagesCountProvider) > 0,
              ),
              _buildNavItem(context, colors, HugeIcons.strokeRoundedFileEdit, 'Notes', 4),
            ],
          ),
        ),
      ),
      ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, colors, dynamic icon, String label, int index, {bool showDot = false}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? colors.gold : colors.secondaryText;

    return Expanded(
      child: ScribesBounceButton(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: isSelected ? 8 : 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.gold.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  HugeIcon(icon: icon, color: color, size: 24),
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
                    color: color, 
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
