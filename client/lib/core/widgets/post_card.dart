import 'package:flutter/material.dart';
import 'scripture_tag.dart';
import 'reaction_chip.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String bodyExcerpt;
  final String authorName;
  final String authorHandle;
  final String? scriptureRef;
  final int amenCount;
  final int insightCount;
  final int thoughtCount;
  final bool isFeatured;

  const PostCard({
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.1),
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
                ScriptureTag(
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
          Row(
            children: [
              ReactionChip(
                icon: Icons.local_fire_department_outlined,
                count: amenCount.toString(),
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ReactionChip(
                icon: Icons.lightbulb_outline,
                count: insightCount.toString(),
                onTap: () {},
              ),
              const SizedBox(width: 12),
              ReactionChip(
                icon: Icons.edit_note_outlined,
                count: thoughtCount.toString(),
                onTap: () {},
              ),
            ],
          )
        ],
      ),
    );
  }
}
