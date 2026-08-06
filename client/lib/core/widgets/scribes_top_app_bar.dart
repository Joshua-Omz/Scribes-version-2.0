import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: colors.background.withValues(alpha: 0.8),
          ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      final hasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: hasDrawer ? () => Scaffold.of(context).openDrawer() : null,
                          borderRadius: BorderRadius.circular(8),
                          splashColor: colors.gold.withValues(alpha: 0.1),
                          highlightColor: colors.gold.withValues(alpha: 0.05),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/logo.svg',
                                  height: 24,
                                  colorFilter: ColorFilter.mode(colors.primaryText, BlendMode.srcIn),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Scribes',
                                  style: ScribesTextStyles.displayMd.copyWith(
                                    fontSize: 22,
                                    color: colors.primaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      ScribesIconButton(
                        icon: HugeIcons.strokeRoundedMail01,
                        onPressed: () {
                          context.go('/inbox');
                        },
                        color: colors.secondaryText,
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final unreadCount = ref.watch(unreadMessagesCountProvider);
                          if (unreadCount > 0) {
                            return Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
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
                  const SizedBox(width: 8),
                  NotificationBadge(
                    child: ScribesIconButton(
                      icon: HugeIcons.strokeRoundedNotification01,
                      onPressed: () {
                        context.push('/notifications');
                      },
                      color: colors.secondaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
