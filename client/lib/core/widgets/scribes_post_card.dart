import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import 'scribes_scripture_chip.dart';

import 'scribes_reaction_bar.dart';
import 'scribes_ornament_divider.dart';
import 'scribes_author_header.dart';

class ScribesPostCard extends ConsumerStatefulWidget {
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
  final int thoughtProvokingCount;
  final int commentCount;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onComment;
  final void Function(String)? onReact;
  final String? userReactionType;
  final bool isSaved;
  final VoidCallback? onSaveToggle;

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
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.onTap,
    this.onComment,
    this.onReact,
    this.userReactionType,
    this.isSaved = false,
    this.onSaveToggle,
  });

  @override
  ConsumerState<ScribesPostCard> createState() => _ScribesPostCardState();
}

class _ScribesPostCardState extends ConsumerState<ScribesPostCard> {
  bool _isExpanded = true; // Default to open as requested

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final hasEmbeddedContent = (widget.caption != null && widget.caption!.isNotEmpty) || 
                               (widget.sermonSource != null && widget.sermonSource!.isNotEmpty);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: colors.background, // Match screen background for flat look
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isFeatured)
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
                    authorName: widget.authorName,
                    authorHandle: widget.authorHandle,
                    publishedAt: widget.publishedAt,
                    isCorrection: widget.isCorrection,
                    onTap: () {},
                  ),
                ),
                if (widget.scriptureRef != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ScribesScriptureChip(
                      reference: widget.scriptureRef!,
                      onTap: () {},
                    ),
                  ),
                if (widget.onSaveToggle != null)
                  IconButton(
                    onPressed: widget.onSaveToggle,
                    icon: Icon(
                      widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: widget.isSaved ? colors.gold : colors.secondaryText,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.bodyExcerpt,
              style: ScribesTextStyles.bodyLg.copyWith(
                color: colors.primaryText,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (hasEmbeddedContent) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: colors.secondaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded ? 'Hide references' : 'Show references',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: _EmbeddedContentBox(
                  caption: widget.caption,
                  sermonSource: widget.sermonSource,
                  colors: colors,
                ),
                crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
            
            const SizedBox(height: 20),
            const ScribesOrnamentDivider(),
            const SizedBox(height: 20),
            ScribesReactionBar(
              amenCount: widget.amenCount,
              insightCount: widget.insightCount,
              thoughtProvokingCount: widget.thoughtProvokingCount,
              commentCount: widget.commentCount,
              onReact: widget.onReact ?? (type) {},
              onComment: widget.onComment ?? () {},
              userReactions: widget.userReactionType != null ? [widget.userReactionType!] : [],
            )
          ],
        ),
      ),
    );
  }
}

class _EmbeddedContentBox extends StatelessWidget {
  final String? caption;
  final String? sermonSource;
  final dynamic colors;

  const _EmbeddedContentBox({this.caption, this.sermonSource, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16),
      decoration: BoxDecoration(
        color: colors.background, // Offset from surface
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: colors.goldMuted, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (caption != null && caption!.isNotEmpty)
            Text(
              caption!,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (caption != null && caption!.isNotEmpty && sermonSource != null && sermonSource!.isNotEmpty)
            const SizedBox(height: 12),
          if (sermonSource != null && sermonSource!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.church_outlined, size: 14, color: colors.gold),
                const SizedBox(width: 6),
                Text(
                  sermonSource!,
                  style: ScribesTextStyles.caption.copyWith(
                    color: colors.goldMuted,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
