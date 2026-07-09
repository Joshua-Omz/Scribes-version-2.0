import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_avatar.dart';
import 'scribes_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ScribesAuthorHeader extends ConsumerWidget {
  final String authorName;
  final String authorHandle;
  final String? avatarUrl;
  final DateTime? publishedAt;
  final bool isCorrection;
  final VoidCallback? onTap;

  const ScribesAuthorHeader({
    super.key,
    required this.authorName,
    required this.authorHandle,
    this.avatarUrl,
    this.publishedAt,
    this.isCorrection = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          ScribesAvatar(
            imageUrl: avatarUrl,
            authorName: authorName,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        authorName,
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCorrection) ...[
                      const SizedBox(width: 8),
                      const ScribesBadge(
                        label: 'Correction',
                        isFilled: true,
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@$authorHandle',
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.secondaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (publishedAt != null) ...[
                      Text(
                        ' • ',
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                      Text(
                        _formatTimestamp(publishedAt!),
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat.yMMMd().format(time);
    }
  }
}
