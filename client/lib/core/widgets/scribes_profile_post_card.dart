import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';

class ScribesProfilePostCard extends ConsumerWidget {
  final String title;
  final String excerpt;
  final DateTime? publishedAt;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

  const ScribesProfilePostCard({
    super.key,
    required this.title,
    required this.excerpt,
    this.publishedAt,
    required this.onTap,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScribesRadius.card),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (publishedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}',
                      style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (onSaveToggle != null)
                  IconButton(
                    onPressed: onSaveToggle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? colors.gold : colors.secondaryText,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title.isEmpty ? 'Untitled' : title,
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
                fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              excerpt,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
