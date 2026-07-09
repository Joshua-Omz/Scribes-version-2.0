import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import 'scribes_scripture_chip.dart';
import 'package:intl/intl.dart';
import 'scribes_reaction_bar.dart';
import 'scribes_ornament_divider.dart';
import 'scribes_author_header.dart';

class ScribesPostCard extends ConsumerWidget {
  final String title;
  final String bodyExcerpt;
  final String authorName;
  final String authorHandle;
  final String? scriptureRef;
  final String? caption;
  final String? sermonSource;
  final bool isCorrection;
  final DateTime? publishedAt;
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
    this.caption,
    this.sermonSource,
    this.isCorrection = false,
    this.publishedAt,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtCount = 0,
    this.isFeatured = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        
       
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colors.border,
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
                  child: Icon(Icons.star_border, color: colors.gold, size: 24),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ScribesAuthorHeader(
                    authorName: authorName,
                    authorHandle: authorHandle,
                    publishedAt: publishedAt,
                    isCorrection: isCorrection,
                    onTap: () {},
                  ),
                ),
                if (scriptureRef != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ScribesScriptureChip(
                      reference: scriptureRef!,
                      onTap: () {},
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
            ),
            if (caption != null && caption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                caption!,
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.secondaryText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              bodyExcerpt,
              style: ScribesTextStyles.bodyLg.copyWith(
                color: colors.primaryText,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            if (sermonSource != null && sermonSource!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.church_outlined, size: 14, color: colors.gold),
                  const SizedBox(width: 4),
                  Text(
                    sermonSource!,
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.goldMuted,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const ScribesOrnamentDivider(),
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
