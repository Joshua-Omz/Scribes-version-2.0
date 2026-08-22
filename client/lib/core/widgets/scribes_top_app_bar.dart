import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/presentation/notification_badge.dart';
import '../../features/messages/application/inbox_providers.dart';

import 'scribes_icon_button.dart';

class ScribesTopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ScribesTopAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.border.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
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
                  children: [
                    Text(
                      'Scribes',
                      style: ScribesTextStyles.displayMd.copyWith(
                        fontSize: 21,
                        letterSpacing: 0.3,
                        color: colors.primaryText,
                      ),
                    ),
                  ],
                ),

                // Right side: Bible Quick-Open, Inbox & Notifications
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bible Drawer / Reader shortcut
                      ScribesIconButton(
                        icon: HugeIcons.strokeRoundedBook02,
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
                      const SizedBox(width: 2),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final unreadCount = ref.watch(
                                unreadMessagesCountProvider,
                              );
                              if (unreadCount > 0) {
                                return Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.orange,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: colors.background,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      unreadCount > 9
                                          ? '9+'
                                          : unreadCount.toString(),
                                      style: TextStyle(
                                        color: colors.background,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
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
