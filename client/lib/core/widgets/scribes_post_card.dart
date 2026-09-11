import 'package:flutter/material.dart';
import 'package:scribes/core/theme/scribes_radius.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import 'scribes_scripture_chip.dart';
import '../../features/posts/domain/scripture_ref.dart';

import 'scribes_ornament_divider.dart';
import 'scribes_author_header.dart';
import 'scribes_image_resolver.dart';

class ScribesPostCard extends ConsumerStatefulWidget {
  final String title;
  final String bodyExcerpt;
  final String authorName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final List<ScriptureRef> scriptureRefs;
  final List<String> tags;
  final String? caption;
  final String? sermonSource;
  final bool isCorrection;
  final DateTime? publishedAt;
  final String postType;
  final String? coverImageUrl;
  final int amenCount;
  final int insightCount;
  final int thoughtProvokingCount;
  final int commentCount;
  final bool isFeatured;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onComment;
  final void Function(String)? onReact;
  final String? userReactionType;
  final bool isSaved;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onShare;

  final bool isExploreScreen;
  final bool isSearchScreen;

  const ScribesPostCard({
    super.key,
    required this.title,
    required this.bodyExcerpt,
    required this.authorName,
    required this.authorHandle,
    this.authorAvatarUrl,
    this.scriptureRefs = const [],
    this.tags = const [],
    this.caption,
    this.sermonSource,
    this.isCorrection = false,
    this.publishedAt,
    this.postType = 'standard',
    this.coverImageUrl,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    this.isFeatured = false,
    this.onTap,
    this.onAuthorTap,
    this.onComment,
    this.onReact,
    this.userReactionType,
    this.isSaved = false,
    this.onSaveToggle,
    this.onShare,
    this.isExploreScreen = false,
    this.isSearchScreen = false,
  });

  @override
  ConsumerState<ScribesPostCard> createState() => _ScribesPostCardState();
}

class _ScribesPostCardState extends ConsumerState<ScribesPostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final hasEmbeddedContent =
        (widget.caption != null && widget.caption!.isNotEmpty) ||
        (widget.sermonSource != null && widget.sermonSource!.isNotEmpty);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isExploreScreen ? 16 : 10,
          vertical: widget.isExploreScreen ? 16 : 10,
        ),
          decoration: widget.isExploreScreen
              ? BoxDecoration(
                  color: colors.surfaceRaised.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.5),
                  ),
                )
              : BoxDecoration(
                  color: colors
                      .background, // Match screen background for flat look
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isFeatured)
                Align(
                  alignment: Alignment.topLeft,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedSparkles,
                    color: colors.gold.withValues(alpha: 0.16),
                    size: 24,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ScribesAuthorHeader(
                      authorName: widget.authorName,
                      authorHandle: widget.authorHandle,
                      avatarUrl: widget.authorAvatarUrl,
                      publishedAt: widget.publishedAt,
                      isCorrection: widget.isCorrection,
                      onTap: widget.onAuthorTap ?? () {},
                    ),
                  ),
                  if (widget.onShare != null)
                    IconButton(
                      onPressed: widget.onShare,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedShare01,
                          color: colors.secondaryText,
                          size: 20,
                        ),
                      ),
                    ),
                  if (widget.onSaveToggle != null)
                    IconButton(
                      onPressed: widget.onSaveToggle,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.isSaved
                              ? colors.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            ScribesRadius.button,
                          ),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedBookmark01,
                          color: widget.isSaved
                              ? colors.surface
                              : colors.secondaryText,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
              // 1. Cover Image Media Preview (Hybrid Magazine Style with Scrim & Floating Badge)
              if (!widget.isSearchScreen &&
                  widget.coverImageUrl != null &&
                  widget.coverImageUrl!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScribesRadius.card),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        // Background Cached Network Image
                        Positioned.fill(
                          child: ScribesImageResolver.buildImage(
                            imageUrl: widget.coverImageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 720,
                            placeholder: (context, url) => Container(
                              color: colors.surfaceRaised,
                            ),
                            fallback: Container(
                              color: colors.surfaceRaised,
                            ),
                          ),
                        ),

                        // Bottom gradient scrim for visual depth and badge readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                                stops: const [0.55, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Floating Badge in Bottom-Left (Passage, Reflection, or Featured indicator)
                        if (widget.postType == 'passage' ||
                            widget.postType == 'reflection' ||
                            widget.isFeatured)
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.background.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.chip,
                                ),
                                border: Border.all(
                                  color: colors.gold.withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                widget.postType == 'passage'
                                    ? 'Passage'
                                    : widget.postType == 'reflection'
                                        ? 'Reflection'
                                        : 'Featured',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // 2. Title & Body Excerpt
              const SizedBox(height: 14),
              if (widget.postType == 'reflection') ...[
                Text(
                  widget.bodyExcerpt.isNotEmpty
                      ? widget.bodyExcerpt
                      : widget.title,
                  style: ScribesTextStyles.bodyLg.copyWith(
                    color: colors.primaryText,
                    fontSize: 17,
                    height: 1.55,
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                if (widget.title.isNotEmpty && widget.title != 'Untitled')
                  Text(
                    widget.title,
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontSize: widget.isSearchScreen ? 20 : 24,
                      height: widget.isSearchScreen ? 1.1 : 1.2,
                    ),
                    maxLines: widget.isSearchScreen ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!widget.isSearchScreen && widget.bodyExcerpt.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.bodyExcerpt,
                    style: ScribesTextStyles.bodyLg.copyWith(
                      color: colors.secondaryText,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],

              // 3. Scripture Chips & Tags
              if (widget.scriptureRefs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.scriptureRefs.map((ref) {
                      final refStr = ref.verseEnd != null
                          ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                          : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                      return ScribesScriptureChip(reference: refStr);
                    }).toList(),
                  ),
                ),
              if (widget.tags.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    top: widget.scriptureRefs.isNotEmpty ? 8.0 : 12.0,
                  ),
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: widget.tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                ScribesRadius.chip,
                              ),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: ScribesTextStyles.labelSm.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

              // 4. Embedded References (Sermon Source / Caption)
              if (!widget.isSearchScreen && hasEmbeddedContent) ...[
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 2.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: _isExpanded
                                ? HugeIcons.strokeRoundedArrowUp01
                                : HugeIcons.strokeRoundedArrowDown01,
                            color: colors.secondaryText,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isExpanded ? 'Hide references' : 'Show references',
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isExpanded)
                  _EmbeddedContentBox(
                    caption: widget.caption,
                    sermonSource: widget.sermonSource,
                    colors: colors,
                  ),
              ],

              // 5. Sacred Ornament Divider & Compact 6-Action Row
              if (!widget.isExploreScreen) ...[
                const SizedBox(height: 16),
                const ScribesOrnamentDivider(),
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Amen (Fire)
                      _buildCompactAction(
                        icon: widget.userReactionType == 'amen'
                            ? HugeIcons.strokeRoundedSparkles
                            : HugeIcons.strokeRoundedFire,
                        label: widget.amenCount > 0 ? '${widget.amenCount}' : '',
                        isSelected: widget.userReactionType == 'amen',
                        selectedColor: colors.gold,
                        defaultColor: colors.secondaryText,
                        onTap: () => widget.onReact?.call('amen'),
                      ),

                      // 2. Insight (Idea)
                      _buildCompactAction(
                        icon: HugeIcons.strokeRoundedIdea01,
                        label: widget.insightCount > 0
                            ? '${widget.insightCount}'
                            : '',
                        isSelected: widget.userReactionType == 'insightful',
                        selectedColor: colors.gold,
                        defaultColor: colors.secondaryText,
                        onTap: () => widget.onReact?.call('insightful'),
                      ),

                      // 3. Deep / Thought-provoking (Diamond)
                      _buildCompactAction(
                        icon: HugeIcons.strokeRoundedDiamond01,
                        label: widget.thoughtProvokingCount > 0
                            ? '${widget.thoughtProvokingCount}'
                            : '',
                        isSelected: widget.userReactionType == 'thought_provoking',
                        selectedColor: colors.gold,
                        defaultColor: colors.secondaryText,
                        onTap: () => widget.onReact?.call('thought_provoking'),
                      ),

                      // 4. Comments (Bubble Chat)
                      _buildCompactAction(
                        icon: HugeIcons.strokeRoundedBubbleChat,
                        label: widget.commentCount > 0
                            ? '${widget.commentCount}'
                            : '',
                        isSelected: false,
                        selectedColor: colors.gold,
                        defaultColor: colors.secondaryText,
                        onTap: widget.onComment,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }

  Widget _buildCompactAction({
    required dynamic icon,
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required Color defaultColor,
    required VoidCallback? onTap,
  }) {
    final color = isSelected ? selectedColor : defaultColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              size: 16,
              color: color,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: ScribesTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
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

  const _EmbeddedContentBox({
    this.caption,
    this.sermonSource,
    required this.colors,
  });

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
        border: Border(left: BorderSide(color: colors.border, width: 3)),
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
          if (caption != null &&
              caption!.isNotEmpty &&
              sermonSource != null &&
              sermonSource!.isNotEmpty)
            const SizedBox(height: 12),
          if (sermonSource != null && sermonSource!.isNotEmpty)
            Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedChurch,
                  size: 14,
                  color: colors.primaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  sermonSource!,
                  style: ScribesTextStyles.caption.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
