import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/scribes_colors.dart';
import '../application/notification_provider.dart';

class NotificationBadge extends ConsumerWidget {
  final Widget child;

  const NotificationBadge({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);
    
    return Stack(
      children: [
        child,
        if (hasUnread.value == true)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).extension<ScribesColors>()?.gold ?? Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
