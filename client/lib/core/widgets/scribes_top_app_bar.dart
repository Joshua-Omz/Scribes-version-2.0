import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/notifications/application/notification_provider.dart';
import 'scribes_brand_logo.dart';

/// Modernized, liturgical top app bar for the Scribes Feed.
/// Replaces heavy bubble-ring icon buttons with sleek, borderless,
/// perfectly-proportioned icon actions and a centered brandmark.
class ScribesTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final bool showBottomBorder;

  const ScribesTopAppBar({
    super.key,
    this.showBottomBorder = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: showBottomBorder ? 0.35 : 0.18),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
                // 1. Left side: Clean Menu Action
                Align(
                  alignment: Alignment.centerLeft,
                  child: _AppBarIconButton(
                    icon: HugeIcons.strokeRoundedMenu01,
                    color: colors.primaryText,
                    tooltip: 'Menu',
                    onPressed: () => _showMenuSheet(context, ref, colors),
                  ),
                ),

                // 2. Center: Mathematically Centered Logo & Monastic Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ScribesBrandLogo(
                      variant: BrandLogoVariant.iconOnly,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scribes',
                      style: ScribesTextStyles.displayMd.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),

                // 3. Right side: Bible Reader Shortcut & Notifications
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AppBarIconButton(
                        icon: HugeIcons.strokeRoundedBook01,
                        color: colors.primaryText,
                        tooltip: 'Bible',
                        onPressed: () => context.push('/bible'),
                      ),
                      const SizedBox(width: 2),
                      Consumer(
                        builder: (context, ref, _) {
                          final hasUnread =
                              ref.watch(hasUnreadNotificationsProvider).value ==
                                  true;
                          return Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              _AppBarIconButton(
                                icon: HugeIcons.strokeRoundedNotification01,
                                color: colors.primaryText,
                                tooltip: 'Notifications',
                                onPressed: () => context.push('/notifications'),
                              ),
                              if (hasUnread)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 7.5,
                                    height: 7.5,
                                    decoration: BoxDecoration(
                                      color: colors.gold,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.background,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _showMenuSheet(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
  ) {
    final authState = ref.read(authProvider);
    final user = authState.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: colors.glassBlur,
            sigmaY: colors.glassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colors.glassFill,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: colors.goldEdge, width: 0.8),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Menu items
                  _buildMenuItem(
                    context: ctx,
                    colors: colors,
                    icon: HugeIcons.strokeRoundedBook01,
                    title: 'Bible',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/bible');
                    },
                  ),

                  if (user != null) ...[
                    _buildMenuItem(
                      context: ctx,
                      colors: colors,
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      title: 'Study Notes',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/notes');
                      },
                    ),
                    _buildMenuItem(
                      context: ctx,
                      colors: colors,
                      icon: HugeIcons.strokeRoundedFileEdit,
                      title: 'Manuscript Drafts',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/drafts');
                      },
                    ),
                    _buildMenuItem(
                      context: ctx,
                      colors: colors,
                      icon: HugeIcons.strokeRoundedBookmark01,
                      title: 'Bookmarks',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/bookmarks');
                      },
                    ),
                  ] else ...[
                    _buildMenuItem(
                      context: ctx,
                      colors: colors,
                      icon: HugeIcons.strokeRoundedLogin01,
                      title: 'Sign In / Join',
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/auth');
                      },
                    ),
                  ],

                  Divider(
                    height: 24,
                    thickness: 0.5,
                    color: colors.border.withValues(alpha: 0.5),
                    indent: 24,
                    endIndent: 24,
                  ),

                  _buildMenuItem(
                    context: ctx,
                    colors: colors,
                    icon: HugeIcons.strokeRoundedSettings01,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/settings');
                    },
                  ),

                  if (user != null)
                    _buildMenuItem(
                      context: ctx,
                      colors: colors,
                      icon: HugeIcons.strokeRoundedLogout01,
                      title: 'Sign Out',
                      textColor: colors.orange,
                      iconColor: colors.orange,
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(authProvider.notifier).logout();
                      },
                    ),

                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'THE WORD IS MADE FLESH',
                      style: ScribesTextStyles.caption.copyWith(
                        letterSpacing: 2.0,
                        color: colors.secondaryText.withValues(alpha: 0.4),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ScribesColors colors,
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: HugeIcon(
        icon: icon,
        color: iconColor ?? colors.secondaryText,
        size: 22,
      ),
      title: Text(
        title,
        style: ScribesTextStyles.bodyMd.copyWith(
          color: textColor ?? colors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      onTap: onTap,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Borderless, lightweight icon button designed specifically for top bars.
/// Eliminates heavy circular borders while providing responsive tactile touch feedback.
class _AppBarIconButton extends StatelessWidget {
  final dynamic icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  const _AppBarIconButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: color.withValues(alpha: 0.12),
        highlightColor: color.withValues(alpha: 0.06),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: HugeIcon(
            icon: icon,
            size: 22.0,
            color: color,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }
    return button;
  }
}
