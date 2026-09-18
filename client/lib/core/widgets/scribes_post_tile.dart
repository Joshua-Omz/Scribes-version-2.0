import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/scribes_text_styles.dart';
import '../theme/theme_provider.dart';
import '../../features/posts/domain/post.dart';
import '../../features/social/application/post_social_providers.dart';
import '../../features/social/application/saved_posts_provider.dart';
import '../../features/auth/application/auth_notifier.dart';
import 'scribes_avatar.dart'; 
import 'scribes_image_resolver.dart';
import 'scribes_comment_sheet.dart';
import 'scribes_share_sheet.dart';
import 'scribes_toast.dart';

/// A Twitter/X style linear stream post tile for profile screens and timelines.
class ScribesPostTile extends ConsumerWidget {
  final Post post;
  final VoidCallback? onTap;

  const ScribesPostTile({
    super.key,
    required this.post,
    this.onTap,
  });

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _extractTitle(Map<String, dynamic> content) {
    if (content['title'] != null &&
        content['title'].toString().trim().isNotEmpty) {
      return content['title'].toString().trim();
    }
    return '';
  }

  String _extractExcerpt(Map<String, dynamic> content) {
    if (content['excerpt'] != null &&
        content['excerpt'].toString().trim().isNotEmpty) {
      return content['excerpt'].toString().trim();
    }

    final ops = content['ops'] ?? content['body'];
    if (ops is List) {
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map && op['insert'] is String) {
          buffer.write(op['insert']);
          if (buffer.length > 200) break;
        }
      }
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        return text.length > 180 ? '${text.substring(0, 180)}...' : text;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.value != null),
    );
    final isSaved = ref.watch(
      savedPostsProvider.select((state) {
        final list = state.value;
        if (list == null) return false;
        return list.any((p) => p['id'] == post.id || p['post_id'] == post.id);
      }),
    );
    final reactionsState = ref.watch(postReactionsProvider(post.id));
    final reactionsStateData = reactionsState.value;

    int amenCount = post.amenCount;
    int insightCount = post.insightCount;
    int thoughtProvokingCount = post.thoughtProvokingCount;

    if (reactionsStateData != null && reactionsStateData.modifiedReaction) {
      final amens = reactionsStateData.counts.where((r) => r.type == 'amen');
      if (amens.isNotEmpty) {
        amenCount = amens.fold(0, (sum, r) => sum + r.count);
      }
      final insights =
          reactionsStateData.counts.where((r) => r.type == 'insightful');
      if (insights.isNotEmpty) {
        insightCount = insights.fold(0, (sum, r) => sum + r.count);
      }
      final deeps =
          reactionsStateData.counts.where((r) => r.type == 'thought_provoking');
      if (deeps.isNotEmpty) {
        thoughtProvokingCount = deeps.fold(0, (sum, r) => sum + r.count);
      }
    }
    final userReaction = reactionsStateData?.userReaction;
    final commentCount = post.commentCount;

    final title = _extractTitle(post.content);
    final excerpt = _extractExcerpt(post.content);
    final displayImageUrl = ScribesImageResolver.extractFirstImageUrl(post);
    final hasImage = displayImageUrl != null && displayImageUrl.isNotEmpty;

    return InkWell(
      onTap: onTap ?? () => context.push('/posts/${post.id}'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Author Avatar (Left Column)
                GestureDetector(
                  onTap: () => context.push('/profile/${post.authorId}'),
                  child: ScribesAvatar(
                    authorName: post.authorName,
                    imageUrl: post.authorAvatarUrl,
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Post Details & Content (Right Column)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Author Name, Handle, Timestamp, Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName
                                  : '@${post.authorHandle}',
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: colors.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '@${post.authorHandle}',
                              style: ScribesTextStyles.bodyMd.copyWith(
                                color: colors.secondaryText,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ' · ',
                            style: TextStyle(
                              color: colors.secondaryText,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _formatTimeAgo(post.publishedAt),
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          if (post.postType == 'passage') ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Passage',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Title (if present)
                      if (title.isNotEmpty) ...[
                        Text(
                          title,
                          style: ScribesTextStyles.displayMd.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryText,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Body Excerpt
                      if (excerpt.isNotEmpty) ...[
                        Text(
                          excerpt,
                          style: ScribesTextStyles.bodyMd.copyWith(
                            fontSize: 14,
                            height: 1.45,
                            color: colors.primaryText.withValues(alpha: 0.88),
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],

                      // Scripture References & Tags (Compact Chips)
                      if (post.scriptureRefs.isNotEmpty ||
                          post.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            for (final refData in post.scriptureRefs.take(2))
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.gold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.goldMuted.withValues(alpha: 0.3),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  refData.verseEnd != null
                                      ? '${refData.book} ${refData.chapter}:${refData.verseStart}-${refData.verseEnd}'
                                      : '${refData.book} ${refData.chapter}:${refData.verseStart}',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: colors.gold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            for (final tag in post.tags.take(3))
                              Text(
                                '#$tag',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Cover Image (Twitter-style embedded media box)
                      if (hasImage) ...[
                        Builder(builder: (context) {
                          const displayH = 180.0;
                          final displayW = MediaQuery.sizeOf(context).width - 32; // approximate padding
                          final cacheW = ScribesImageResolver.computeCacheWidth(context, displayW);

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: displayH,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised,
                                border: Border.all(
                                  color: colors.border.withValues(alpha: 0.5),
                                  width: 0.5,
                                ),
                              ),
                              child: ScribesImageResolver.buildImage(
                                imageUrl: displayImageUrl,
                                memCacheWidth: cacheW,
                                fit: BoxFit.cover,
                                placeholder: (ctx, url) => Container(
                                  color: colors.surfaceRaised,
                                ),
                                fallback: Container(color: colors.surfaceRaised),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],

                      // Interaction Action Bar (Amen, Insight, Deep, Comments, Save, Share)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Amen button
                          _buildActionButton(
                            icon: userReaction == 'amen'
                                ? HugeIcons.strokeRoundedSparkles
                                : HugeIcons.strokeRoundedFire,
                            label: amenCount > 0 ? '$amenCount' : '',
                            color: userReaction == 'amen'
                                ? colors.gold
                                : colors.secondaryText,
                            onTap: () {
                              if (!isAuthenticated) {
                                ScribesToast.show(
                                  context,
                                  'Sign in to react to posts',
                                  colors,
                                );
                                return;
                              }
                              ref
                                  .read(postReactionsProvider(post.id).notifier)
                                  .react('amen');
                            },
                          ),

                          // 2. Insight button
                          _buildActionButton(
                            icon: HugeIcons.strokeRoundedIdea01,
                            label: insightCount > 0 ? '$insightCount' : '',
                            color: userReaction == 'insightful'
                                ? colors.gold
                                : colors.secondaryText,
                            onTap: () {
                              if (!isAuthenticated) {
                                ScribesToast.show(
                                  context,
                                  'Sign in to react to posts',
                                  colors,
                                );
                                return;
                              }
                              ref
                                  .read(postReactionsProvider(post.id).notifier)
                                  .react('insightful');
                            },
                          ),

                          // 3. Deep / Thought-provoking button
                          _buildActionButton(
                            icon: HugeIcons.strokeRoundedDroplet,
                            label: thoughtProvokingCount > 0
                                ? '$thoughtProvokingCount'
                                : '',
                            color: userReaction == 'thought_provoking'
                                ? colors.gold
                                : colors.secondaryText,
                            onTap: () {
                              if (!isAuthenticated) {
                                ScribesToast.show(
                                  context,
                                  'Sign in to react to posts',
                                  colors,
                                );
                                return;
                              }
                              ref
                                  .read(postReactionsProvider(post.id).notifier)
                                  .react('thought_provoking');
                            },
                          ),

                          // 4. Comment button
                          _buildActionButton(
                            icon: HugeIcons.strokeRoundedBubbleChat,
                            label: commentCount > 0 ? '$commentCount' : '',
                            color: colors.secondaryText,
                            onTap: () => ScribesCommentSheet.show(
                              context,
                              postId: post.id,
                              postAuthorId: post.authorId,
                            ),
                          ),

                          // 5. Save / Bookmark button
                          _buildActionButton(
                            icon: isSaved
                                ? HugeIcons.strokeRoundedBookmark02
                                : HugeIcons.strokeRoundedBookmark01,
                            label: '',
                            color: isSaved ? colors.gold : colors.secondaryText,
                            onTap: () {
                              if (!isAuthenticated) {
                                ScribesToast.show(
                                  context,
                                  'Sign in to save posts',
                                  colors,
                                );
                                return;
                              }
                              if (isSaved) {
                                ref
                                    .read(savedPostsProvider.notifier)
                                    .unsavePost(post.id);
                                ScribesToast.show(
                                  context,
                                  'Post unsaved',
                                  colors,
                                  icon: HugeIcons.strokeRoundedRemove01,
                                );
                              } else {
                                ref
                                    .read(savedPostsProvider.notifier)
                                    .savePost(post.id);
                                ScribesToast.show(
                                  context,
                                  'Post saved to manuscript collection',
                                  colors,
                                  icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                                );
                              }
                            },
                          ),

                          // 6. Share button
                          _buildActionButton(
                            icon: HugeIcons.strokeRoundedShare01,
                            label: '',
                            color: colors.secondaryText,
                            onTap: () => ScribesShareSheet.show(
                              context,
                              post.id,
                              post: post,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, color: colors.border),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required dynamic icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
