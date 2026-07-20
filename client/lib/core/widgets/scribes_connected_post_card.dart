import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'scribes_post_card.dart';
import 'scribes_comment_sheet.dart';
import '../theme/theme_provider.dart';

import '../../features/posts/domain/post.dart';
import '../../features/social/application/post_social_providers.dart';
import '../../features/social/application/saved_posts_provider.dart';
import '../../features/auth/application/auth_notifier.dart';

class ScribesConnectedPostCard extends ConsumerWidget {
  final Post post;
  final bool isFeatured;

  const ScribesConnectedPostCard({
    super.key,
    required this.post,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final reactionsState = ref.watch(postReactionsProvider(post.id));
    final commentsState = ref.watch(postCommentsProvider(post.id));
    final savedPostsState = ref.watch(savedPostsProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value != null;

    final reactionsStateData = reactionsState.value;
    final reactions = reactionsStateData?.counts ?? [];
    final userReaction = (reactionsStateData?.modifiedReaction ?? false) 
        ? reactionsStateData?.userReaction 
        : null; // The backend doesn't currently return the initial user reaction on the Post model
    final comments = commentsState.value ?? [];

    final amenCount = reactions.where((r) => r.type == 'amen').fold(0, (sum, r) => sum + r.count);
    final insightCount = reactions.where((r) => r.type == 'insightful').fold(0, (sum, r) => sum + r.count);
    final thoughtProvokingCount = reactions.where((r) => r.type == 'thought_provoking').fold(0, (sum, r) => sum + r.count);
    final commentCount = comments.length;
    
    final savedPosts = savedPostsState.value ?? [];
    final isSaved = savedPosts.any((p) => p['id'] == post.id || p['post_id'] == post.id);

    return Column(
      children: [
        ScribesPostCard(
          title: post.content['title'] ?? 'Untitled',
          authorName: post.authorName,
          authorHandle: post.authorHandle,
          bodyExcerpt: post.content['excerpt'] ?? (post.content['body'] is String ? post.content['body'] : ''),
          caption: post.caption,
          sermonSource: post.sermonSource?.displayTitle,
          isCorrection: post.isCorrection,
          publishedAt: post.publishedAt,
          isFeatured: isFeatured,
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
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post unsaved')));
            } else {
              ref.read(savedPostsProvider.notifier).savePost(post.id);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post saved')));
            }
          },
          onTap: () => context.push('/posts/${post.id}'),
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
        Divider(height: 1, thickness: 1, color: colors.border),
      ],
    );
  }
}
