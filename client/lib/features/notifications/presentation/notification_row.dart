import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../domain/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/notification_provider.dart';

class NotificationRow extends ConsumerWidget {
  final NotificationItem notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const NotificationRow({
    super.key,
    required this.notification,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onLongPress,
    this.onTap,
  });

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (isSelectionMode) {
      if (onTap != null) onTap!();
      return;
    }
    
    // Auto-mark as read
    if (!notification.safeIsRead) {
      ref.read(notificationProvider.notifier).markSelectedRead(notification.safeIds);
    }
    
    // Navigate based on type + ref_id
    switch (notification.safeType) {
      case NotifType.mention:
      case NotifType.reaction:
      case NotifType.comment:
        context.push('/posts/${notification.safeRefId}');
        break;
      case NotifType.follow:
        context.push('/users/${notification.safeRefId}');
        break;
      case NotifType.adminAlert:
        // Admin detail (out of scope for standard users in v1)
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    
    return InkWell(
      onTap: () => _handleTap(context, ref),
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.surface,
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
            // Selection Checkbox
            if (isSelectionMode)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 12),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? colors.gold : colors.secondaryText,
                  size: 20,
                ),
              )
            else ...[
              // Unread dot
              if (!notification.safeIsRead)
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
            ],
              
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
                    notification.safeBody,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: notification.safeIsRead ? colors.secondaryText : colors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.safeCreatedAt),
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
