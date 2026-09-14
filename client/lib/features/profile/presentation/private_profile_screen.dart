import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';

import '../../auth/application/auth_notifier.dart';
import 'package:scribes/features/social/application/saved_posts_provider.dart';
import 'dart:ui';
import '../../../core/widgets/scribes_post_tile.dart';
import '../../posts/domain/post.dart';
import '../../posts/application/my_posts_provider.dart';

import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_post_card_skeleton.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';

class PrivateProfileScreen extends ConsumerStatefulWidget {
  const PrivateProfileScreen({super.key});

  @override
  ConsumerState<PrivateProfileScreen> createState() =>
      _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends ConsumerState<PrivateProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 4),
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
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        color: colors.primaryText,
                      ),
                      onPressed: () => context.pop(),
                    )
                  : null,
              title: Text(
                'Profile',
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                ),
              ),
              actions: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedLogout01,
                    color: colors.primaryText,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: colors.surface,
                        title: Text(
                          'Logout?',
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.primaryText,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: colors.primaryText),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(authProvider.notifier).logout();
                              context.go('/');
                            },
                            child: Text(
                              'Yes, Logout',
                              style: TextStyle(color: Colors.red.shade400),
                            ),
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
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            imageUrl: user.avatarUrl,
                            radius: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Consumer(
                            builder: (context, ref, child) {
                              final postsState = ref.watch(myPostsProvider);
                              final postsCount = postsState.value?.length ?? 0;
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem(
                                    'Posts',
                                    postsCount.toString(),
                                    colors,
                                  ),
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        user.displayName,
                        style: ScribesTextStyles.displayMd.copyWith(
                          color: colors.primaryText,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '@${user.handle}',
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ),
                    if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.bio!,
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.primaryText,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primaryText,
                          side: BorderSide(color: colors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 11,
                          ),
                        ),
                        onPressed: () {
                          context.push('/profile/edit');
                        },
                        child: Text(
                          'Edit Profile',
                          style: ScribesTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: colors.primaryText,
                  indicatorWeight: 2,
                  labelColor: colors.primaryText,
                  unselectedLabelColor: colors.secondaryText,
                  labelStyle: ScribesTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: ScribesTextStyles.labelLg.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Saved'),
                  ],
                ),
                colors.background,
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
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          final post = posts[index];
                          return ScribesPostTile(
                            post: post,
                            onTap: () async {
                              if (!post.isDeleted) {
                                await context.push('/posts/${post.id}');
                                if (context.mounted) {
                                  ref
                                      .read(myPostsProvider.notifier)
                                      .refresh();
                                }
                              }
                            },
                          );
                        }, childCount: posts.length),
                      );
                    },
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const ScribesPostCardSkeleton(
                            showAvatar: false,
                          );
                        }, childCount: 3),
                      ),
                    ),
                    error: (err, stack) => SliverFillRemaining(
                      child: ScribesErrorState(
                        title: 'Could not load posts',
                        subtitle: err.toString(),
                        onRetry: () =>
                            ref.read(myPostsProvider.notifier).refresh(),
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
                      return SliverList(
                        delegate: SliverChildBuilderDelegate((
                          context,
                          index,
                        ) {
                          final savedPost = savedPosts[index];
                          final post = _mapSavedPostToPost(savedPost);
                          return ScribesPostTile(post: post);
                        }, childCount: savedPosts.length),
                      );
                    },
                    loading: () => SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return const ScribesPostCardSkeleton(
                            showAvatar: false,
                          );
                        }, childCount: 3),
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
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          count,
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: ScribesTextStyles.labelSm.copyWith(
            color: colors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: child,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: child,
    );
  }

  Post _mapSavedPostToPost(Map<String, dynamic> raw) {
    final postId = (raw['post_id'] ?? raw['id'] ?? '').toString();
    final authorId = (raw['author_id'] ?? '').toString();

    Map<String, dynamic> contentMap = {};
    if (raw['content'] is Map<String, dynamic>) {
      contentMap = raw['content'] as Map<String, dynamic>;
    } else if (raw['content'] is String) {
      try {
        final decoded = jsonDecode(raw['content'] as String);
        if (decoded is Map<String, dynamic>) {
          contentMap = decoded;
        }
      } catch (_) {}
    }

    final captionField = raw['caption'];
    String? caption;
    if (captionField is String) {
      caption = captionField;
    } else if (captionField is Map && captionField['Valid'] == true) {
      caption = captionField['String'] as String?;
    }

    final authorName = (raw['author_name'] ?? raw['author_handle'] ?? 'Author').toString();
    final authorHandle = (raw['author_handle'] ?? 'user').toString();
    final authorAvatarUrl = raw['author_avatar_url'] as String?;
    final coverImageUrl = raw['cover_image_url'] as String?;
    final postType = (raw['post_type'] ?? 'standard').toString();

    final publishedAt = raw['published_at'] != null
        ? DateTime.tryParse(raw['published_at'].toString()) ?? DateTime.now()
        : (raw['created_at'] != null
            ? DateTime.tryParse(raw['created_at'].toString()) ?? DateTime.now()
            : DateTime.now());

    return Post(
      id: postId,
      authorId: authorId,
      content: contentMap,
      caption: caption,
      visibility: 'public',
      currentVersion: 1,
      isCorrection: false,
      isDeleted: false,
      coverImageUrl: coverImageUrl,
      postType: postType,
      publishedAt: publishedAt,
      authorHandle: authorHandle,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      amenCount: (raw['amen_count'] as num?)?.toInt() ?? 0,
      commentCount: (raw['comment_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
