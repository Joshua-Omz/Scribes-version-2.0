import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'scribes_post_card.dart';
import 'scribes_reflection_card.dart';
import 'scribes_passage_card.dart';
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
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.value != null),
    );
    final isSaved = ref.watch(
      savedPostIdsProvider.select((ids) => ids.contains(post.id)),
    );

    // In passive lists, read pre-aggregated counts directly from Post DTO.
    // Only subscribe to family provider rebuilds if the user performed an optimistic reaction on this card.
    final modifiedReactionsState = ref.watch(
      postReactionsProvider(post.id).select((state) {
        final data = state.value;
        if (data != null && data.modifiedReaction) {
          return data;
        }
        return null;
      }),
    );

    final userReaction = modifiedReactionsState?.userReaction;

    int amenCount = post.amenCount;
    int insightCount = post.insightCount;
    int thoughtProvokingCount = post.thoughtProvokingCount;

    if (modifiedReactionsState != null && modifiedReactionsState.modifiedReaction) {
      final amens = modifiedReactionsState.counts.where((r) => r.type == 'amen');
      if (amens.isNotEmpty) {
        amenCount = amens.fold(0, (sum, r) => sum + r.count);
      }
      final insights = modifiedReactionsState.counts.where(
        (r) => r.type == 'insightful',
      );
      if (insights.isNotEmpty) {
        insightCount = insights.fold(0, (sum, r) => sum + r.count);
      }
      final thoughts = modifiedReactionsState.counts.where(
        (r) => r.type == 'thought_provoking',
      );
      if (thoughts.isNotEmpty) {
        thoughtProvokingCount = thoughts.fold(0, (sum, r) => sum + r.count);
      }
    }
    final commentCount = post.commentCount;

    void onSaveToggle() {
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
    }

    void onShare() => ScribesShareSheet.show(context, post.id, post: post);

    void onTap() {
      if (post.postType == 'passage') {
        context.push('/passage/${post.id}');
      } else {
        context.push('/posts/${post.id}');
      }
    }

    void onAuthorTap() => context.push('/users/${post.authorId}');

    void onComment() {
      if (!isAuthenticated) {
        context.push('/auth');
        return;
      }
      ScribesCommentSheet.show(
        context,
        postId: post.id,
        postAuthorId: post.authorId,
      );
    }

    void onReact(String type) {
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
    }

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
          else if (post.postType == 'reflection')
            ScribesReflectionCard(
              bodyText: post.plainTextBody,
              authorName: post.authorName,
              authorHandle: post.authorHandle,
              authorAvatarUrl: post.authorAvatarUrl,
              publishedAt: post.publishedAt,
              imageUrl: post.reflectionImageUrl ??
                  ScribesImageResolver.extractFirstImageUrl(post),
              scriptureRefs: post.scriptureRefs,
              tags: post.tags,
              amenCount: amenCount,
              insightCount: insightCount,
              thoughtProvokingCount: thoughtProvokingCount,
              commentCount: commentCount,
              userReactionType: userReaction,
              isSaved: isSaved,
              onSaveToggle: onSaveToggle,
              onShare: onShare,
              onTap: onTap,
              onAuthorTap: onAuthorTap,
              onComment: onComment,
              onReact: onReact,
              isExploreScreen: isExploreScreen,
            )
          else if (post.postType == 'passage')
            ScribesPassageCard(
              post: post,
              amenCount: amenCount,
              insightCount: insightCount,
              thoughtProvokingCount: thoughtProvokingCount,
              commentCount: commentCount,
              userReactionType: userReaction,
              isSaved: isSaved,
              onSaveToggle: onSaveToggle,
              onShare: onShare,
              onTap: onTap,
              onAuthorTap: onAuthorTap,
              onComment: onComment,
              onReact: onReact,
            )
          else
            ScribesPostCard(
              title: post.content['title'] ?? 'Untitled',
              authorName: post.authorName,
              authorHandle: post.authorHandle,
              authorAvatarUrl: post.authorAvatarUrl,
              bodyExcerpt: post.plainTextBody,
              caption: post.caption,
              sermonSource: post.sermonSource?.displayTitle,
              isCorrection: post.isCorrection,
              publishedAt: post.publishedAt,
              postType: post.postType,
              coverImageUrl: post.coverImageUrl ??
                  ScribesImageResolver.extractFirstImageUrl(post),
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
              onSaveToggle: onSaveToggle,
              onShare: onShare,
              onTap: onTap,
              onAuthorTap: onAuthorTap,
              onComment: onComment,
              onReact: onReact,
            ),
          if (!isExploreScreen)
            Divider(height: 1, thickness: 1, color: colors.border),
        ],
      ),
    );
  }
}
