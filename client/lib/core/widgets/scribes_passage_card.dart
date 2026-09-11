import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/scribes_radius.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import 'scribes_author_header.dart';
import 'scribes_image_resolver.dart';
import 'scribes_scripture_chip.dart';
import 'scribes_ornament_divider.dart';
import '../../features/posts/domain/post.dart';

/// Presentation card specifically tailored for multi-panel Passage Decks.
/// Adheres to AGENTS.md performance invariants: zero per-card tickers,
/// cached image resizing (memCacheWidth: 800), and distinct reaction seeds.
class ScribesPassageCard extends ConsumerWidget {
  final Post post;
  final int amenCount;
  final int insightCount;
  final int thoughtProvokingCount;
  final int commentCount;
  final String? userReactionType;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onComment;
  final void Function(String)? onReact;
  final VoidCallback? onSaveToggle;
  final VoidCallback? onShare;

  const ScribesPassageCard({
    super.key,
    required this.post,
    this.amenCount = 0,
    this.insightCount = 0,
    this.thoughtProvokingCount = 0,
    this.commentCount = 0,
    this.userReactionType,
    this.isSaved = false,
    this.onTap,
    this.onAuthorTap,
    this.onComment,
    this.onReact,
    this.onSaveToggle,
    this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    final title = post.content['title']?.toString().trim().isNotEmpty == true
        ? post.content['title'].toString().trim()
        : 'Devotional Passage';

    final excerpt = post.plainTextBody.isNotEmpty
        ? post.plainTextBody
        : (post.content['excerpt']?.toString().trim() ?? '');

    final previewImageUrl = ScribesImageResolver.extractFirstImageUrl(post);
    final hasAudio = post.soundId != null || post.sound != null;
    final panelCount = post.panels.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.gold.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Author Header
                ScribesAuthorHeader(
                  authorName: post.authorName,
                  authorHandle: post.authorHandle,
                  avatarUrl: post.authorAvatarUrl,
                  publishedAt: post.publishedAt,
                  onTap: onAuthorTap,
                ),

                const SizedBox(height: 12),

                // 2. Deck Badges Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(ScribesRadius.chip),
                        border: Border.all(
                          color: colors.gold.withValues(alpha: 0.35),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedLayers01,
                            color: colors.gold,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            panelCount > 0
                                ? 'Passage Deck · $panelCount Panels'
                                : 'Passage Deck',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.gold,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasAudio) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceRaised,
                          borderRadius:
                              BorderRadius.circular(ScribesRadius.chip),
                          border: Border.all(
                            color: colors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedVolumeHigh,
                              color: colors.secondaryText,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ambient Audio',
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // 3. Optional Cover / Lead Background Image
                if (previewImageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(ScribesRadius.card),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ScribesImageResolver.buildImage(
                            imageUrl: previewImageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 800,
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius:
                                  BorderRadius.circular(ScribesRadius.chip),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookOpen01,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Tap to read deck',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 4. Passage Title
                Text(
                  title,
                  style: ScribesTextStyles.displayMd.copyWith(
                    color: colors.primaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (excerpt.isNotEmpty && excerpt != title) ...[
                  const SizedBox(height: 8),
                  Text(
                    excerpt,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.secondaryText,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // 5. Scripture Tags (if any)
                if (post.scriptureRefs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: post.scriptureRefs.map((ref) {
                      final refStr = ref.verseEnd != null
                          ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                          : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                      return ScribesScriptureChip(reference: refStr);
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),
                const ScribesOrnamentDivider(),
                const SizedBox(height: 8),

                // 6. Multi-Reaction Row (Preserving distinct telemetry)
                Row(
                  children: [
                    _buildReactionButton(
                      context,
                      colors,
                      label: 'Amen',
                      type: 'amen',
                      icon: HugeIcons.strokeRoundedFire,
                      count: amenCount,
                      isSelected: userReactionType == 'amen',
                    ),
                    const SizedBox(width: 8),
                    _buildReactionButton(
                      context,
                      colors,
                      label: 'Insightful',
                      type: 'insightful',
                      icon: HugeIcons.strokeRoundedIdea01,
                      count: insightCount,
                      isSelected: userReactionType == 'insightful',
                    ),
                    const SizedBox(width: 8),
                    _buildReactionButton(
                      context,
                      colors,
                      label: 'Ponder',
                      type: 'thought_provoking',
                      icon: HugeIcons.strokeRoundedDiamond01,
                      count: thoughtProvokingCount,
                      isSelected: userReactionType == 'thought_provoking',
                    ),
                    const Spacer(),
                    // Comments
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedComment01,
                        color: colors.secondaryText,
                        size: 18,
                      ),
                      onPressed: onComment,
                      tooltip: 'Comments ($commentCount)',
                    ),
                    // Save
                    IconButton(
                      icon: HugeIcon(
                        icon: isSaved
                            ? HugeIcons.strokeRoundedBookmark02
                            : HugeIcons.strokeRoundedBookmark01,
                        color: isSaved ? colors.gold : colors.secondaryText,
                        size: 18,
                      ),
                      onPressed: onSaveToggle,
                      tooltip: isSaved ? 'Saved' : 'Save',
                    ),
                    // Share
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedShare01,
                        color: colors.secondaryText,
                        size: 18,
                      ),
                      onPressed: onShare,
                      tooltip: 'Share',
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

  Widget _buildReactionButton(
    BuildContext context,
    dynamic colors, {
    required String label,
    required String type,
    required dynamic icon,
    required int count,
    required bool isSelected,
  }) {
    final activeColor = colors.gold;
    final color = isSelected ? activeColor : colors.secondaryText;

    return InkWell(
      onTap: onReact != null ? () => onReact!(type) : null,
      borderRadius: BorderRadius.circular(ScribesRadius.chip),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: ScribesTextStyles.caption.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
