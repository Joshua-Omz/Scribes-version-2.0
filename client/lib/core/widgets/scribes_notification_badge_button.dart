import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/notifications/application/notification_provider.dart';
import '../theme/theme_provider.dart';

/// Isolated notification bell button with unread indicator badge.
/// Encapsulated with a [RepaintBoundary] so notification state changes
/// only repaint this leaf widget, completely isolating [ScribesTopAppBar].
class ScribesNotificationBadgeButton extends ConsumerWidget {
  const ScribesNotificationBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final hasUnread = ref.watch(
      hasUnreadNotificationsProvider.select((val) => val.value == true),
    );

    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/notifications'),
              customBorder: const CircleBorder(),
              splashColor: colors.primaryText.withValues(alpha: 0.12),
              highlightColor: colors.primaryText.withValues(alpha: 0.06),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Tooltip(
                  message: 'Notifications',
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    size: 22.0,
                    color: colors.primaryText,
                  ),
                ),
              ),
            ),
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
      ),
    );
  }
}
