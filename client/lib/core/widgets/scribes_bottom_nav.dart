import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';
import '../../features/compose/presentation/compose_type_sheet.dart';

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

  const ScribesBottomNav({
    super.key,
    this.backgroundColor = Colors.transparent,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // Compose is an action, not a tab — show the compose type selection sheet
      ComposeTypeSheet.show(context);
      return;
    }

    // Navigate to the corresponding route
    final routes = {0: '/', 1: '/explore', 3: '/notes', 4: '/profile'};
    final target = routes[index];
    if (target != null) {
      context.go(target);
    }
  }

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
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: colors.glassBlur,
              sigmaY: colors.glassBlur,
            ),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                color: colors.glassFill,
                border: Border(
                  top: BorderSide(
                    color: colors.goldEdge,
                    width: 0.8,
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
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    ScribesColors colors,
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
        onTap: () => _onTap(context, index),
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
        onTap: () => _onTap(context, 2),
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
                  color: colors.glassFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.goldEdge,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.gold.withValues(alpha: 0.15),
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
