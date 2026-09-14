import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/notifications/presentation/notification_badge.dart';
import 'scribes_icon_button.dart';
import 'scribes_brand_logo.dart';

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
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Stack(
              alignment: Alignment.center,
              children: [
                // Left side: Menu Sheet trigger (replaces hamburger drawer)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ScribesIconButton(
                    icon: HugeIcons.strokeRoundedMenu01,
                    onPressed: () => _showMenuSheet(context, ref, colors),
                    color: colors.primaryText,
                  ),
                ),

                // Center: Logo and Title (bigger)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ScribesBrandLogo(
                      variant: BrandLogoVariant.iconOnly,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scribes',
                      style: ScribesTextStyles.displayMd.copyWith(
                        fontSize: 26,
                        letterSpacing: 0.4,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),

                // Right side: Bible Quick-Open & Notifications
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bible Drawer / Reader shortcut
                      ScribesIconButton(
                        icon: HugeIcons.strokeRoundedBook01,
                        onPressed: () {
                          context.push('/bible');
                        },
                        color: colors.primaryText,
                      ),
                      const SizedBox(width: 4),
                      NotificationBadge(
                        child: ScribesIconButton(
                          icon: HugeIcons.strokeRoundedNotification01,
                          onPressed: () {
                            context.push('/notifications');
                          },
                          color: colors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  void _showMenuSheet(BuildContext context, WidgetRef ref, ScribesColors colors) {
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      icon: HugeIcons.strokeRoundedFolder01,
                      title: 'Workspace',
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
