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

class ScribesConnectedPostCard extends ConsumerStatefulWidget {
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
  ConsumerState<ScribesConnectedPostCard> createState() =>
      _ScribesConnectedPostCardState();
}

class _ScribesConnectedPostCardState
    extends ConsumerState<ScribesConnectedPostCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colors = ref.watch(themeProvider);
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.value != null),
    );
    final isSaved = ref.watch(
      savedPostIdsProvider.select((ids) => ids.contains(widget.post.id)),
    );

    // In passive lists, read pre-aggregated counts directly from Post DTO.
    // Only subscribe to family provider rebuilds if the user performed an optimistic reaction on this card.
    final modifiedReactionsState = ref.watch(
      postReactionsProvider(widget.post.id).select((state) {
        final data = state.value;
        if (data != null && data.modifiedReaction) {
          return data;
        }
        return null;
      }),
    );

    final userReaction = modifiedReactionsState?.userReaction;

    int amenCount = widget.post.amenCount;
    int insightCount = widget.post.insightCount;
    int thoughtProvokingCount = widget.post.thoughtProvokingCount;

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
    final commentCount = widget.post.commentCount;

    void onSaveToggle() {
      if (!isAuthenticated) {
        context.push('/auth');
        return;
      }
      if (isSaved) {
        ref.read(savedPostsProvider.notifier).unsavePost(widget.post.id);
        ScribesToast.show(
          context,
          'Post unsaved',
          colors,
          icon: HugeIcons.strokeRoundedRemove01,
        );
      } else {
        ref.read(savedPostsProvider.notifier).savePost(widget.post.id);
        ScribesToast.show(
          context,
          'Post saved',
          colors,
          icon: HugeIcons.strokeRoundedCheckmarkBadge01,
        );
      }
    }

    void onShare() => ScribesShareSheet.show(context, widget.post.id, post: widget.post);

    void onTap() {
      if (widget.post.postType == 'passage') {
        context.push('/passage/${widget.post.id}');
      } else {
        context.push('/posts/${widget.post.id}');
      }
    }

    void onAuthorTap() => context.push('/users/${widget.post.authorId}');

    void onComment() {
      if (!isAuthenticated) {
        context.push('/auth');
        return;
      }
      ScribesCommentSheet.show(
        context,
        postId: widget.post.id,
        postAuthorId: widget.post.authorId,
      );
    }

    void onReact(String type) {
      if (!isAuthenticated) {
        context.push('/auth');
        return;
      }
      ref
          .read(postReactionsProvider(widget.post.id).notifier)
          .react(
            type,
            initialAmenCount: widget.post.amenCount,
            initialInsightCount: widget.post.insightCount,
            initialThoughtProvokingCount: widget.post.thoughtProvokingCount,
            knownUserReaction: null,
          );
    }

    return RepaintBoundary(
      child: Column(
        children: [
          if (widget.post.isDeleted)
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
          else if (widget.post.postType == 'reflection')
            ScribesReflectionCard(
              bodyText: widget.post.plainTextBody,
              authorName: widget.post.authorName,
              authorHandle: widget.post.authorHandle,
              authorAvatarUrl: widget.post.authorAvatarUrl,
              publishedAt: widget.post.publishedAt,
              imageUrl: widget.post.reflectionImageUrl ??
                  ScribesImageResolver.extractFirstImageUrl(widget.post),
              scriptureRefs: widget.post.scriptureRefs,
              tags: widget.post.tags,
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
              isExploreScreen: widget.isExploreScreen,
            )
          else if (widget.post.postType == 'passage')
            ScribesPassageCard(
              post: widget.post,
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
              title: widget.post.content['title'] ?? 'Untitled',
              authorName: widget.post.authorName,
              authorHandle: widget.post.authorHandle,
              authorAvatarUrl: widget.post.authorAvatarUrl,
              bodyExcerpt: widget.post.plainTextBody,
              caption: widget.post.caption,
              sermonSource: widget.post.sermonSource?.displayTitle,
              isCorrection: widget.post.isCorrection,
              publishedAt: widget.post.publishedAt,
              postType: widget.post.postType,
              coverImageUrl: widget.post.coverImageUrl ??
                  ScribesImageResolver.extractFirstImageUrl(widget.post),
              scriptureRefs: widget.post.scriptureRefs,
              tags: widget.post.tags,
              isFeatured: widget.isFeatured,
              isExploreScreen: widget.isExploreScreen,
              isSearchScreen: widget.isSearchScreen,
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
          if (!widget.isExploreScreen)
            Divider(height: 1, thickness: 1, color: colors.border),
        ],
      ),
    );
  }
}
