import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_radius.dart';

class ScribesProfileDraftCard extends ConsumerWidget {
  final String title;
  final String excerpt;
  final DateTime updatedAt;
  final VoidCallback onTap;

  const ScribesProfileDraftCard({
    super.key,
    required this.title,
    required this.excerpt,
    required this.updatedAt,
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
          color: colors.background, // differentiate by using background color instead of surfaceRaised
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          border: Border.all(color: colors.border.withValues(alpha: 0.5), style: BorderStyle.solid),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, size: 16, color: colors.orange),
                const SizedBox(width: 8),
                Text(
                  'DRAFT • Last updated ${updatedAt.day}/${updatedAt.month}/${updatedAt.year}',
                  style: ScribesTextStyles.caption.copyWith(color: colors.orange),
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
            if (excerpt.isNotEmpty) ...[
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
            ]
          ],
        ),
      ),
    );
  }
}
