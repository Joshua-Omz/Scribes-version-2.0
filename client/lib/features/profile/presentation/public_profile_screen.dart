
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_profile_post_card.dart';
import '../../social/application/user_lookup_provider.dart';
import '../../social/application/is_following_user_provider.dart';
import '../../posts/application/user_posts_provider.dart';
import '../../social/application/saved_posts_provider.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    final userState = ref.watch(commentAuthorProvider(userId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
      ),
      body: userState.when(
        loading: () => const Center(child: ScribesLoadingIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
        data: (user) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: colors.surfaceRaised,
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                      ),
                      Text(
                        '@${user.handle}',
                        style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                      ),
                      const SizedBox(height: 16),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem('Followers', user.followersCount.toString(), colors),
                          const SizedBox(width: 40),
                          _buildStatItem('Following', user.followingCount.toString(), colors),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildFollowButton(ref, colors),
                    ],
                  ),
                ),
              ),
              _buildUserPostsList(ref, colors),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String count, dynamic colors) {
    return Column(
      children: [
        Text(
          count,
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        Text(
          label,
          style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
        ),
      ],
    );
  }

  Widget _buildFollowButton(WidgetRef ref, dynamic colors) {
    final followState = ref.watch(isFollowingUserProvider(userId));
    return followState.when(
      loading: () => const SizedBox(
        width: 120,
        height: 40,
        child: Center(child: ScribesLoadingIndicator()),
      ),
      error: (_, __) => const SizedBox(width: 120, height: 40),
      data: (isFollowing) {
        if (isFollowing) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primaryText,
              side: BorderSide(color: colors.border),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              ref.read(isFollowingUserProvider(userId).notifier).toggleFollow();
            },
            child: Text('Unfollow', style: ScribesTextStyles.labelLg),
          );
        } else {
          return FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.primaryText,
              foregroundColor: colors.background,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              ref.read(isFollowingUserProvider(userId).notifier).toggleFollow();
            },
            child: Text('Follow', style: ScribesTextStyles.labelLg),
          );
        }
      },
    );
  }

  Widget _buildUserPostsList(WidgetRef ref, dynamic colors) {
    final postsState = ref.watch(userPostsProvider(userId));
    return postsState.when(
      loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
      error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
      data: (posts) {
        if (posts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.feed_outlined, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No posts yet.', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                ],
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              final savedPosts = ref.watch(savedPostsProvider).value ?? [];
              final isSaved = savedPosts.any((p) => p['id'] == post.id || p['post_id'] == post.id);

              String excerpt = '';
              if (post.content['ops'] != null) {
                for (var op in post.content['ops']) {
                  if (op['insert'] is String) {
                    excerpt += op['insert'];
                    if (excerpt.length > 100) {
                      excerpt = '${excerpt.substring(0, 100)}...';
                      break;
                    }
                  }
                }
              }
              return ScribesProfilePostCard(
                title: post.content['title'] ?? '',
                excerpt: excerpt,
                publishedAt: post.publishedAt,
                isSaved: isSaved,
                onSaveToggle: () {
                  if (isSaved) {
                    ref.read(savedPostsProvider.notifier).unsavePost(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post unsaved')));
                  } else {
                    ref.read(savedPostsProvider.notifier).savePost(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post saved')));
                  }
                },
                onTap: () => context.push('/posts/${post.id}'),
              );
            },
            childCount: posts.length,
          ),
        );
      },
    );
  }
}
