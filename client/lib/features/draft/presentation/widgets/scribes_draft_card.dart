import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/scribes_colors.dart';
import '../../domain/draft.dart';

class ScribesDraftCard extends ConsumerWidget {
  final Draft draft;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ScribesDraftCard({
    super.key,
    required this.draft,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    
    // Extract title from content if available, otherwise "Untitled Draft"
    String title = 'Untitled Draft';
    String excerpt = 'No content';

    if (draft.content.containsKey('title') && draft.content['title'].toString().trim().isNotEmpty) {
      title = draft.content['title'];
    }
    if (draft.content.containsKey('excerpt') && draft.content['excerpt'].toString().trim().isNotEmpty) {
      excerpt = draft.content['excerpt'];
    }

    final formattedDate = DateFormat('MMM d, y').format(draft.updatedAt);

    return InkWell(
      onTap: onTap,
       // Matching ScribesRadius.card
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colors.secondaryText, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              excerpt,
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.edit_document, size: 14, color: colors.gold),
                const SizedBox(width: 6),
                Text(
                  'Saved $formattedDate',
                  style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
                ),
                const Spacer(),
                if (draft.sermonSource != null && draft.sermonSource!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(4), // ScribesRadius.chip
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      draft.sermonSource!.displayTitle,
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
