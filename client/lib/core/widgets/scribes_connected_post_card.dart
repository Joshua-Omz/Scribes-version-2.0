import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'scribes_post_card.dart';
import 'scribes_comment_sheet.dart';
import 'scribes_share_sheet.dart';
import 'scribes_toast.dart';
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
    final savedPostsState = ref.watch(savedPostsProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value != null;

    final amenCount = post.amenCount;
    final insightCount = 0; // Not returned by backend yet
    final thoughtProvokingCount = 0; // Not returned by backend yet
    final commentCount = post.commentCount;
    
    final savedPosts = savedPostsState.value ?? [];
    final isSaved = savedPosts.any((p) => p['id'] == post.id || p['post_id'] == post.id);

    return Column(
      children: [
        if (post.isDeleted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                    HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: colors.secondaryText, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'This post has been deleted',
                      style: TextStyle(color: colors.secondaryText, fontSize: 16),
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
            bodyExcerpt: post.content['excerpt'] ?? (post.content['body'] is String ? post.content['body'] : ''),
            caption: post.caption,
            sermonSource: post.sermonSource?.displayTitle,
            isCorrection: post.isCorrection,
            publishedAt: post.publishedAt,
            postType: post.postType,
            coverImageUrl: post.coverImageUrl,
            scriptureRefs: post.scriptureRefs,
            tags: post.tags,
            isFeatured: isFeatured,
            isExploreScreen: isExploreScreen,
            isSearchScreen: isSearchScreen,
            amenCount: amenCount,
            insightCount: insightCount,
            thoughtProvokingCount: thoughtProvokingCount,
            commentCount: commentCount,
            userReactionType: null,
            isSaved: isSaved,
            onSaveToggle: () {
              if (!isAuthenticated) {
                context.push('/auth');
                return;
              }
              if (isSaved) {
                ref.read(savedPostsProvider.notifier).unsavePost(post.id);
                ScribesToast.show(context, 'Post unsaved', colors, icon: HugeIcons.strokeRoundedRemove01);
              } else {
                ref.read(savedPostsProvider.notifier).savePost(post.id);
                ScribesToast.show(context, 'Post saved', colors, icon: HugeIcons.strokeRoundedCheckmarkBadge01);
              }
            },
            onShare: () => ScribesShareSheet.show(context, post.id),
            onTap: () => context.push('/posts/${post.id}'),
            onAuthorTap: () => context.push('/users/${post.authorId}'),
            onComment: () {
              if (!isAuthenticated) {
                context.push('/auth');
                return;
              }
              ScribesCommentSheet.show(context, postId: post.id, postAuthorId: post.authorId);
            },
            onReact: (type) {
              if (!isAuthenticated) {
                context.push('/auth');
                return;
              }
              ref.read(postReactionsProvider(post.id).notifier).react(type, knownUserReaction: null);
            },
          ),
        if (!isExploreScreen)
          Divider(height: 1, thickness: 1, color: colors.border),
      ],
    );
  }
}
