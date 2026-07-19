import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/scribes_text_styles.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.gold.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: colors.gold.withOpacity(0.1),
          highlightColor: colors.gold.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DRAFT',
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.orange,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (onDelete != null)
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.close, color: colors.secondaryText, size: 20),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText, height: 1.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  excerpt,
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Divider(height: 1, color: colors.border.withOpacity(0.5)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: colors.secondaryText),
                    const SizedBox(width: 6),
                    Text(
                      'Last saved $formattedDate',
                      style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
                    ),
                    const Spacer(),
                    if (draft.sermonSource != null && draft.sermonSource!.isNotEmpty)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.church_outlined, size: 14, color: colors.gold),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                draft.sermonSource!.displayTitle,
                                style: ScribesTextStyles.labelSm.copyWith(color: colors.gold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
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
}
