import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import 'dart:ui';
import '../../../core/widgets/scribes_post_card_skeleton.dart';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../../core/widgets/scribes_error_state.dart';
import '../../social/application/user_lookup_provider.dart';
import '../../social/application/is_following_user_provider.dart';
import '../../posts/application/user_posts_provider.dart';
import '../../social/application/saved_posts_provider.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../messages/presentation/widgets/dm_request_modal.dart';
import '../../auth/application/auth_notifier.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    final userState = ref.watch(commentAuthorProvider(userId));

    return Scaffold(
      backgroundColor: colors.background,
      body: userState.when(
        loading: () => const Center(child: ScribesLoadingIndicator()),
        error: (err, stack) => ScribesErrorState(
          title: 'Error loading profile',
          subtitle: err.toString(),
        ),
        data: (user) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: colors.background.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    color: colors.primaryText,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.5,
                      colors: [
                        colors.goldMuted.withValues(alpha: 0.05),
                        colors.background,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: colors.surfaceRaised,
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: ScribesTextStyles.displayMd.copyWith(
                              color: colors.primaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.displayName,
                        style: ScribesTextStyles.displayMd.copyWith(
                          color: colors.primaryText,
                        ),
                      ),
                      Text(
                        '@${user.handle}',
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Text(
                          user.bio!,
                          textAlign: TextAlign.center,
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.primaryText,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem(
                            'Followers',
                            user.followersCount.toString(),
                            colors,
                            onTap: () {
                              context.push(
                                '/users/${user.id}/connections?tab=0',
                              );
                            },
                          ),
                          const SizedBox(width: 40),
                          _buildStatItem(
                            'Following',
                            user.followingCount.toString(),
                            colors,
                            onTap: () {
                              context.push(
                                '/users/${user.id}/connections?tab=1',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildActionButtons(context, ref, colors),
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

  Widget _buildStatItem(
    String label,
    String count,
    dynamic colors, {
    VoidCallback? onTap,
  }) {
    final child = Column(
      children: [
        Text(
          count,
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
          ),
        ),
        Text(
          label,
          style: ScribesTextStyles.labelSm.copyWith(
            color: colors.secondaryText,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: child,
        ),
      );
    }
    return child;
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, dynamic colors) {
    final followState = ref.watch(isFollowingUserProvider(userId));
    final currentUser = ref.watch(authProvider).value;
    
    return followState.when(
      loading: () => const SizedBox(
        width: 120,
        height: 40,
        child: Center(child: ScribesLoadingIndicator()),
      ),
      error: (error, stack) => const SizedBox(width: 120, height: 40),
      data: (isFollowing) {
        Widget followBtn;
        if (isFollowing) {
          followBtn = OutlinedButton(
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
          followBtn = FilledButton(
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
        
        if (currentUser?.id == userId) {
          return followBtn;
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            followBtn,
            const SizedBox(width: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.surfaceRaised,
                foregroundColor: colors.primaryText,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colors.border),
                ),
              ),
              onPressed: () {
                DmRequestModal.show(context, userId);
              },
              icon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 18, color: colors.primaryText),
              label: Text('Message', style: ScribesTextStyles.labelLg),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserPostsList(WidgetRef ref, dynamic colors) {
    final postsState = ref.watch(userPostsProvider(userId));
    return postsState.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return const ScribesPostCardSkeleton(showAvatar: false);
          }, childCount: 3),
        ),
      ),
      error: (err, stack) => SliverFillRemaining(
        child: ScribesErrorState(
          title: 'Could not load posts',
          subtitle: err.toString(),
          onRetry: () => ref.invalidate(userPostsProvider(userId)),
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedNews,
                title: 'No posts yet',
                subtitle: 'This user hasn\'t published anything.',
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = posts[index];
              final savedPosts = ref.watch(savedPostsProvider).value ?? [];
              final isSaved = savedPosts.any(
                (p) => p['id'] == post.id || p['post_id'] == post.id,
              );

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
              return ScribesGridCard(
                title: post.content['title'] ?? '',
                excerpt: excerpt,
                date: post.publishedAt,
                isSaved: isSaved,
                onSaveToggle: () {
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
                onTap: () => context.push('/posts/${post.id}'),
              );
            }, childCount: posts.length),
          ),
        );
      },
    );
  }
}
