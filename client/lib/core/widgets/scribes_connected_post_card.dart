import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'scribes_post_card.dart';
import 'scribes_comment_sheet.dart';
import 'scribes_share_sheet.dart';
import 'scribes_toast.dart';
import 'scribes_image_resolver.dart';
import '../theme/theme_provider.dart';

import '../../features/posts/domain/post.dart';
import '../../features/social/application/post_social_providers.dart';
import '../../features/social/application/saved_posts_provider.dart';
import '../../features/auth/application/auth_notifier.dart';

class ScribesConnectedPostCard extends ConsumerWidget {
  final Post post;
  final bool isFeatured;
  final bool isExploreScreen;
  final bool isSearchScreen;

  const ScribesConnectedPostCard({
    super.key,
    required this.post,
    this.isFeatured = false,
    this.isExploreScreen = false,
    this.isSearchScreen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final reactionsState = ref.watch(postReactionsProvider(post.id));
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

    final reactionsStateData = reactionsState.value;
    final userReaction = (reactionsStateData?.modifiedReaction ?? false)
        ? reactionsStateData?.userReaction
        : null;

    int amenCount = post.amenCount;
    int insightCount = post.insightCount;
    int thoughtProvokingCount = post.thoughtProvokingCount;

    if (reactionsStateData != null && reactionsStateData.modifiedReaction) {
      final amens = reactionsStateData.counts.where((r) => r.type == 'amen');
      if (amens.isNotEmpty) {
        amenCount = amens.fold(0, (sum, r) => sum + r.count);
      }
      final insights = reactionsStateData.counts.where(
        (r) => r.type == 'insightful',
      );
      if (insights.isNotEmpty) {
        insightCount = insights.fold(0, (sum, r) => sum + r.count);
      }
      final thoughts = reactionsStateData.counts.where(
        (r) => r.type == 'thought_provoking',
      );
      if (thoughts.isNotEmpty) {
        thoughtProvokingCount = thoughts.fold(0, (sum, r) => sum + r.count);
      }
    }
    final commentCount = post.commentCount;

    return RepaintBoundary(
      child: Column(
        children: [
          if (post.isDeleted)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDelete02,
                        color: colors.secondaryText,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'This post has been deleted',
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ScribesPostCard(
              title: post.content['title'] ?? 'Untitled',
              authorName: post.authorName,
              authorHandle: post.authorHandle,
              authorAvatarUrl: post.authorAvatarUrl,
              bodyExcerpt:
                  post.content['excerpt'] ??
                  (post.content['body'] is String ? post.content['body'] : ''),
              caption: post.caption,
              sermonSource: post.sermonSource?.displayTitle,
              isCorrection: post.isCorrection,
              publishedAt: post.publishedAt,
              postType: post.postType,
              coverImageUrl: ScribesImageResolver.extractFirstImageUrl(post),
              scriptureRefs: post.scriptureRefs,
              tags: post.tags,
              isFeatured: isFeatured,
              isExploreScreen: isExploreScreen,
              isSearchScreen: isSearchScreen,
              amenCount: amenCount,
              insightCount: insightCount,
              thoughtProvokingCount: thoughtProvokingCount,
              commentCount: commentCount,
              userReactionType: userReaction,
              isSaved: isSaved,
              onSaveToggle: () {
                if (!isAuthenticated) {
                  context.push('/auth');
                  return;
                }
                if (isSaved) {
                  ref.read(savedPostsProvider.notifier).unsavePost(post.id);
                  ScribesToast.show(
                    context,
                    'Post unsaved',
                    colors,
                    icon: HugeIcons.strokeRoundedRemove01,
                  );
                } else {
                  ref.read(savedPostsProvider.notifier).savePost(post.id);
                  ScribesToast.show(
                    context,
                    'Post saved',
                    colors,
                    icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                  );
                }
              },
              onShare: () => ScribesShareSheet.show(context, post.id, post: post),
              onTap: () => context.push('/posts/${post.id}'),
              onAuthorTap: () => context.push('/users/${post.authorId}'),
              onComment: () {
                if (!isAuthenticated) {
                  context.push('/auth');
                  return;
                }
                ScribesCommentSheet.show(
                  context,
                  postId: post.id,
                  postAuthorId: post.authorId,
                );
              },
              onReact: (type) {
                if (!isAuthenticated) {
                  context.push('/auth');
                  return;
                }
                ref
                    .read(postReactionsProvider(post.id).notifier)
                    .react(
                      type,
                      initialAmenCount: post.amenCount,
                      initialInsightCount: post.insightCount,
                      initialThoughtProvokingCount: post.thoughtProvokingCount,
                      knownUserReaction: null,
                    );
              },
            ),
          if (!isExploreScreen)
            Divider(height: 1, thickness: 1, color: colors.border),
        ],
      ),
    );
  }
}
