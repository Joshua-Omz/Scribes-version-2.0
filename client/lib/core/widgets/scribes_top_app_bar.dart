import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:go_router/go_router.dart';
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
                // Left side: Hamburger Menu
                Align(
                  alignment: Alignment.centerLeft,
                  child: Builder(
                    builder: (context) {
                      final hasDrawer =
                          Scaffold.maybeOf(context)?.hasDrawer ?? false;
                      return hasDrawer
                          ? ScribesIconButton(
                              icon: HugeIcons.strokeRoundedMenu01,
                              onPressed: () =>
                                  Scaffold.of(context).openDrawer(),
                              color: colors.primaryText,
                            )
                          : const SizedBox(width: 40);
                    },
                  ),
                ),

                // Center: Logo and Title
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const ScribesBrandLogo(
                      variant: BrandLogoVariant.iconOnly,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scribes',
                      style: ScribesTextStyles.displayMd.copyWith(
                        fontSize: 22,
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
                          // Navigate to Bible reader or open end drawer
                          final scaffold = Scaffold.maybeOf(context);
                          if (scaffold != null && scaffold.hasEndDrawer) {
                            scaffold.openEndDrawer();
                          } else {
                            context.push('/bible');
                          }
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
