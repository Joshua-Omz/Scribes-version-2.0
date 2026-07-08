import 'package:flutter/material.dart';
import 'scribes_scripture_chip.dart';
import 'scribes_reaction_bar.dart';

class ScribesPostCard extends StatelessWidget {
  final String title;
  final String bodyExcerpt;
  final String authorName;
  final String authorHandle;
  final String? scriptureRef;
  final int amenCount;
  final int insightCount;
  final int thoughtCount;
  final bool isFeatured;
  final VoidCallback? onTap;

  const ScribesPostCard({
    super.key,
    required this.title,
    required this.bodyExcerpt,
    required this.authorName,
    required this.authorHandle,
    this.scriptureRef,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtCount = 0,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFeatured)
              Align(
                alignment: Alignment.topLeft,
                child: Opacity(
                  opacity: 0.16,
                  child: Icon(Icons.star_border, color: theme.colorScheme.primary, size: 24),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  authorName,
                  style: theme.textTheme.labelSmall,
                ),
                if (scriptureRef != null)
                  ScribesScriptureChip(
                    reference: scriptureRef!,
                    onTap: () {},
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              bodyExcerpt,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            ScribesReactionBar(
              amenCount: amenCount,
              insightCount: insightCount,
              thoughtCount: thoughtCount,
              onReact: (type) {},
              onComment: () {},
            )
          ],
        ),
      ),
    );
  }
}
