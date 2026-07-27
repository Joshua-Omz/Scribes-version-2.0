import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../domain/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationRow extends StatelessWidget {
  final NotificationItem notification;

  const NotificationRow({
    super.key,
    required this.notification,
  });

  void _handleTap(BuildContext context) {
    // Navigate based on type + ref_id
    switch (notification.type) {
      case NotifType.mention:
      case NotifType.reaction:
      case NotifType.comment:
        context.push('/posts/${notification.refId}');
        break;
      case NotifType.follow:
        context.push('/users/${notification.refId}');
        break;
      case NotifType.adminAlert:
        // Admin detail (out of scope for standard users in v1)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    
    return InkWell(
      onTap: () => _handleTap(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            bottom: BorderSide(color: colors.border, width: 0.5),
            left: notification.showRealtimeAccent 
                ? BorderSide(color: colors.goldMuted, width: 2.0)
                : BorderSide.none,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 14, right: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 16), // space replacement for unread dot
              
            // Avatar
            ScribesAvatar(
              imageUrl: notification.actorAvatar,
              radius: 18,
              authorName: notification.actorHandle ?? 'S',
            ),
            const SizedBox(width: 12),
            
            // Body text + timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.body,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: notification.isRead ? colors.secondaryText : colors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.createdAt),
                    style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
