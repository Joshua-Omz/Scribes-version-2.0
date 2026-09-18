import 'package:flutter/material.dart';
import 'package:scribes/core/theme/scribes_radius.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import 'scribes_scripture_chip.dart';
import '../../features/posts/domain/scripture_ref.dart';

import 'package:go_router/go_router.dart';
import 'scribes_author_header.dart';
import 'scribes_image_resolver.dart';

class ScribesPostCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final hasEmbeddedContent =
        (caption != null && caption!.isNotEmpty) ||
        (sermonSource != null && sermonSource!.isNotEmpty);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(
          horizontal: isExploreScreen ? 16 : 10,
          vertical: isExploreScreen ? 16 : 10,
        ),
        decoration: isExploreScreen
            ? BoxDecoration(
                color: colors.surfaceRaised.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.5),
                ),
              )
            : BoxDecoration(
                color: colors.background,
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFeatured)
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
                    authorName: authorName,
                    authorHandle: authorHandle,
                    avatarUrl: authorAvatarUrl,
                    publishedAt: publishedAt,
                    isCorrection: isCorrection,
                    onTap: onAuthorTap ?? () {},
                  ),
                ),
                if (onShare != null)
                  IconButton(
                    onPressed: onShare,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedShare01,
                        color: colors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
                if (onSaveToggle != null)
                  IconButton(
                    onPressed: onSaveToggle,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSaved ? colors.glassFill : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          ScribesRadius.button,
                        ),
                        border: isSaved
                            ? Border.all(color: colors.goldEdge, width: 1.0)
                            : null,
                      ),
                      child: HugeIcon(
                        icon: isSaved
                            ? HugeIcons.strokeRoundedBookmark02
                            : HugeIcons.strokeRoundedBookmark01,
                        color: isSaved
                            ? colors.gold
                            : colors.secondaryText,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            // 1. Cover Image Media Preview (Hybrid Magazine Style with Scrim & Floating Badge)
            if (!isSearchScreen &&
                coverImageUrl != null &&
                coverImageUrl!.trim().isNotEmpty)
              Builder(builder: (context) {
                // Compute explicit dimensions once — avoids LayoutBuilder overhead per item.
                final screenWidth = MediaQuery.sizeOf(context).width;
                final horizontalPad = isExploreScreen ? 32.0 : 20.0;
                final imageWidth = screenWidth - horizontalPad;
                final imageHeight = (imageWidth * 9.0 / 16.0).clamp(0.0, 220.0);
                final cacheW = ScribesImageResolver.computeCacheWidth(
                  context,
                  imageWidth,
                  maxPixels: 720,
                );

                return Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ScribesRadius.card),
                      child: SizedBox(
                        width: imageWidth,
                        height: imageHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ScribesImageResolver.buildImage(
                                imageUrl: coverImageUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: cacheW,
                                placeholder: (context, url) => ColoredBox(
                                  color: colors.surfaceRaised,
                                ),
                                fallback: ColoredBox(
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
                          if (postType == 'passage' ||
                              postType == 'reflection' ||
                              isFeatured)
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
                                    color: colors.goldEdge,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  postType == 'passage'
                                      ? 'Passage'
                                      : postType == 'reflection'
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
                ),
              );
            }),

            // 2. Title & Body Excerpt
            const SizedBox(height: 14),
            Text(
              title,
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              bodyExcerpt,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // 3. Scripture Chips & Tags
            if (scriptureRefs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: scriptureRefs.map((ref) {
                  final refStr = ref.verseEnd != null
                      ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                      : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                  return ScribesScriptureChip(reference: refStr);
                }).toList(),
              ),
            ],

            if (tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags
                      .map(
                        (tag) => GestureDetector(
                          onTap: () => context.push('/tags/$tag'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                ScribesRadius.chip,
                              ),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.5),
                                width: 0.5,
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
                        ),
                      )
                      .toList(),
                ),
              ),

            // 4. Embedded References (Sermon Source / Caption)
            if (!isSearchScreen && hasEmbeddedContent) ...[
              const SizedBox(height: 14),
              _ExpandableReferencesSection(
                caption: caption,
                sermonSource: sermonSource,
                colors: colors,
              ),
            ],

            // 5. Compact Reaction Row (Cleaned up: unnecessary divider removed)
            if (!isExploreScreen) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Amen (Fire)
                  _buildCompactAction(
                    icon: userReactionType == 'amen'
                        ? HugeIcons.strokeRoundedSparkles
                        : HugeIcons.strokeRoundedFire,
                    label: amenCount > 0 ? '$amenCount' : '',
                    isSelected: userReactionType == 'amen',
                    selectedColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('amen'),
                  ),

                  // 2. Insight (Idea)
                  _buildCompactAction(
                    icon: HugeIcons.strokeRoundedIdea01,
                    label: insightCount > 0 ? '$insightCount' : '',
                    isSelected: userReactionType == 'insightful',
                    selectedColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('insightful'),
                  ),

                  // 3. Deep / Thought-provoking (Droplet)
                  _buildCompactAction(
                    icon: HugeIcons.strokeRoundedDroplet,
                    label: thoughtProvokingCount > 0
                        ? '$thoughtProvokingCount'
                        : '',
                    isSelected: userReactionType == 'thought_provoking',
                    selectedColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: () => onReact?.call('thought_provoking'),
                  ),

                  // 4. Comments (Bubble Chat)
                  _buildCompactAction(
                    icon: HugeIcons.strokeRoundedBubbleChat,
                    label: commentCount > 0 ? '$commentCount' : '',
                    isSelected: false,
                    selectedColor: colors.gold,
                    defaultColor: colors.secondaryText,
                    onTap: onComment,
                  ),
                ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              size: 20,
              color: color,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: ScribesTextStyles.caption.copyWith(
                  color: color,
                  fontSize: 12.5,
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

class _ExpandableReferencesSection extends StatefulWidget {
  final String? caption;
  final String? sermonSource;
  final ScribesColors colors;

  const _ExpandableReferencesSection({
    required this.caption,
    required this.sermonSource,
    required this.colors,
  });

  @override
  State<_ExpandableReferencesSection> createState() =>
      _ExpandableReferencesSectionState();
}

class _ExpandableReferencesSectionState
    extends State<_ExpandableReferencesSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    color: widget.colors.secondaryText,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isExpanded ? 'Hide references' : 'Show references',
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: widget.colors.secondaryText,
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
            colors: widget.colors,
          ),
      ],
    );
  }
}

class _EmbeddedContentBox extends StatelessWidget {
  final String? caption;
  final String? sermonSource;
  final ScribesColors colors;

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
        color: colors.background,
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
