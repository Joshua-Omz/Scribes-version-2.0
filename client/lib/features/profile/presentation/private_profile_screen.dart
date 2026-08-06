import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../auth/application/auth_notifier.dart';
import '../../messages/application/inbox_providers.dart';
import 'package:scribes/features/social/application/saved_posts_provider.dart';
import 'dart:ui';
import '../../../core/widgets/scribes_grid_card.dart';
import '../../posts/application/my_posts_provider.dart';
import '../../posts/domain/post.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_post_card_skeleton.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';

class PrivateProfileScreen extends ConsumerStatefulWidget {
  const PrivateProfileScreen({super.key});

  @override
  ConsumerState<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends ConsumerState<PrivateProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    if (user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: ScribesLoadingIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.gold,
        backgroundColor: colors.surfaceRaised,
        onRefresh: () async {
          if (_selectedTabIndex == 0) {
            await ref.read(myPostsProvider.notifier).refresh();
          } else {
            ref.invalidate(savedPostsProvider);
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            leading: context.canPop()
                ? IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
                    onPressed: () => context.pop(),
                  )
                : null,
            title: Text('Profile', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedMail01, color: colors.primaryText),
                    onPressed: () {
                      context.go('/inbox');
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(unreadMessagesCountProvider);
                      if (unreadCount > 0) {
                        return Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedLogout01, color: colors.primaryText),
                onPressed: () {
                  showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: colors.surface,
                          title: Text('Logout?', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                          content: Text('Are you sure you want to logout?', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Cancel', style: TextStyle(color: colors.primaryText)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(authProvider.notifier).logout();
                                context.go('/');
                              },
                              child: Text('Yes, Logout', style: TextStyle(color: Colors.red.shade400)),
                            ),
                          ],
                        ),
                      );

                  
                  context.go('/');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                    child: ScribesAvatar(
                      authorName: user.displayName,
                      radius: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.handle}',
                    style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  ),
                  const SizedBox(height: 12),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        user.bio!,
                        textAlign: TextAlign.center,
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.primaryText,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('Followers', user.followersCount.toString(), colors, onTap: () {
                        context.push('/users/${user.id}/connections?tab=0');
                      }),
                      const SizedBox(width: 40),
                      _buildStatItem('Following', user.followingCount.toString(), colors, onTap: () {
                        context.push('/users/${user.id}/connections?tab=1');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      context.push('/profile/edit');
                    },
                    child: Text('Edit Profile', style: ScribesTextStyles.labelLg),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: ScribesTabBarDelegate(
              child: ScribesTabBar(
                selectedIndex: _selectedTabIndex,
                tabs: const ['Posts', 'Saved'],
                onTabChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ), 
            ),
          ),
          if (_selectedTabIndex == 0)
            Consumer(
              builder: (context, ref, child) {
                final postsState = ref.watch(myPostsProvider);
                return postsState.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: ScribesEmptyState(
                            icon: HugeIcons.strokeRoundedNews,
                            title: 'No posts yet',
                            subtitle: 'You haven\'t published anything.',
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
                            return ScribesGridCard(
                              title: post.content['title'] ?? '',
                              excerpt: excerpt,
                              date: post.publishedAt,
                              isSaved: isSaved,
                              isDeleted: post.isDeleted,
                              onSaveToggle: () {
                                if (isSaved) {
                                  ref.read(savedPostsProvider.notifier).unsavePost(post.id);
                                  ScribesToast.show(context, 'Post unsaved', colors, icon: HugeIcons.strokeRoundedRemove01);
                                } else {
                                  ref.read(savedPostsProvider.notifier).savePost(post.id);
                                  ScribesToast.show(context, 'Post saved', colors, icon: HugeIcons.strokeRoundedCheckmarkBadge01);
                                }
                              },
                              onTap: () async {
                                if (!post.isDeleted) {
                                  await context.push('/posts/${post.id}');
                                  if (context.mounted) {
                                    ref.read(myPostsProvider.notifier).refresh();
                                  }
                                }
                              },
                            );
                          },
                          childCount: posts.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const ScribesPostCardSkeleton(showAvatar: false);
                        },
                        childCount: 3,
                      ),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: ScribesErrorState(
                      title: 'Could not load posts',
                      subtitle: err.toString(),
                      onRetry: () => ref.read(myPostsProvider.notifier).refresh(),
                    ),
                  ),
                );
              },
            ),
          if (_selectedTabIndex == 1)
            Consumer(
              builder: (context, ref, child) {
                final savedPostsState = ref.watch(savedPostsProvider);
                return savedPostsState.when(
                  data: (savedPosts) {
                    if (savedPosts.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: ScribesEmptyState(
                            icon: HugeIcons.strokeRoundedBookmark01,
                            title: 'No saved posts',
                            subtitle: 'Posts you save will appear here.',
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
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final savedPost = savedPosts[index];
                            // Simple excerpt extractor
                            String excerpt = '';
                            final content = savedPost['content'];
                            if (content != null && content['ops'] != null) {
                              for (var op in content['ops']) {
                                if (op['insert'] is String) {
                                  excerpt += op['insert'];
                                  if (excerpt.length > 100) {
                                    excerpt = '${excerpt.substring(0, 100)}...';
                                    break;
                                  }
                                }
                              }
                            }
                            String title = 'Saved Post';
                            final captionField = savedPost['caption'];
                            if (captionField is String && captionField.isNotEmpty) {
                              title = captionField;
                            } else if (captionField is Map && captionField['Valid'] == true) {
                              title = captionField['String'] ?? 'Saved Post';
                            } else if (content != null && content['title'] is String) {
                              title = content['title'];
                            }

                            return ScribesGridCard(
                              title: title,
                              excerpt: excerpt,
                              date: DateTime.parse(savedPost['created_at']),
                              isSaved: true,
                              onSaveToggle: () {
                                ref.read(savedPostsProvider.notifier).unsavePost(savedPost['post_id']);
                                ScribesToast.show(context, 'Post unsaved', colors, icon: HugeIcons.strokeRoundedRemove01);
                              },
                              onTap: () => context.push('/posts/${savedPost['post_id']}'),
                            );
                          },
                          childCount: savedPosts.length,
                        ),
                      ),
                    );
                  },
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const ScribesPostCardSkeleton(showAvatar: false);
                        },
                        childCount: 3,
                      ),
                    ),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: ScribesErrorState(
                      title: 'Could not load saved posts',
                      subtitle: err.toString(),
                      onRetry: () => ref.invalidate(savedPostsProvider),
                    ),
                  ),
                );
              },
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String count, dynamic colors, {VoidCallback? onTap}) {
    final child = Column(
      children: [
        Text(
          count,
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        Text(
          label,
          style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
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
}
