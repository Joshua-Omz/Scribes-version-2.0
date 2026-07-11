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

  const ScribesProfilePostCard({
    super.key,
    required this.title,
    required this.excerpt,
    this.publishedAt,
    required this.onTap,
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
            if (publishedAt != null)
              Text(
                '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}',
                style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
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
