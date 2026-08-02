import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_top_app_bar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../application/feed_notifier.dart';
import '../../posts/domain/post.dart';
import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/widgets/scribes_unauth_banner.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_post_card_skeleton.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';

import 'package:flutter/rendering.dart';
import '../../../core/widgets/scribes_drawer.dart';
import '../../compose/application/compose_provider.dart';


import '../../../core/widgets/scribes_diamond_fab.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
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
    final isAuth = authState.value != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.background,
      drawer: const ScribesDrawer(),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _isFabVisible ? 1.0 : 0.0,
          child: ScribesDiamondFab(
            icon: HugeIcons.strokeRoundedPlusSign,
            onPressed: () {
              ref.read(composeProvider.notifier).reset();
              context.push('/compose');
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  if (!_isFabVisible) {
                    setState(() => _isFabVisible = true);
                    ref.read(bottomNavVisibilityProvider.notifier).show();
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabVisible) {
                    setState(() => _isFabVisible = false);
                    ref.read(bottomNavVisibilityProvider.notifier).hide();
                  }
                }
                return false;
              },
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    floating: true,
                    pinned: false,
                    elevation: 0,
                    backgroundColor: colors.background,
                    toolbarHeight: 56,
                    titleSpacing: 0,
                    title: const ScribesTopAppBar(),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ScribesTabBarDelegate(
                      child: ScribesTabBar(
                        selectedIndex: _tabController.index,
                        onTabChanged: (index) {
                          _tabController.animateTo(index);
                        },
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFollowingTab(colors),
                    _buildSeekTab(colors),
                  ],
                ),
              ),
            ),
          ),
          if (!isAuth)
            ScribesUnauthBanner(
              onJoinTap: () => context.push('/auth'),
              onLoginTap: () => context.push('/auth'),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowingTab(ScribesColors colors) {
    final followingState = ref.watch(followingFeedProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(followingFeedProvider.notifier).refresh(),
      child: CustomScrollView(
        key: const PageStorageKey<String>('followingTab'),
        slivers: [
          followingState.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, colors),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == posts.length) {
                      if (ref.read(followingFeedProvider.notifier).hasMore) {
                        ref.read(followingFeedProvider.notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: ScribesLoadingIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return ScribesConnectedPostCard(
                      post: posts[index],
                      isFeatured: index == 0,
                    );
                  },
                  childCount: posts.length + (ref.read(followingFeedProvider.notifier).hasMore ? 1 : 0),
                ),
              );
            },
            loading: () => _buildShimmer(colors),
            error: (e, st) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekTab(ScribesColors colors) {
    final feedState = ref.watch(feedProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(feedProvider.notifier).refresh(),
      child: CustomScrollView(
        key: const PageStorageKey<String>('seekTab'),
        slivers: [
          feedState.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context, colors),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == posts.length) {
                      if (ref.read(feedProvider.notifier).hasMore) {
                        ref.read(feedProvider.notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: ScribesLoadingIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return ScribesConnectedPostCard(
                      post: posts[index],
                      isFeatured: index == 0,
                    );
                  },
                  childCount: posts.length + (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                ),
              );
            },
            loading: () => _buildShimmer(colors),
            error: (e, st) => SliverFillRemaining(
              child: ScribesErrorState(
                title: 'Could not load feed',
                subtitle: e.toString(),
                onRetry: () => ref.read(feedProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(ScribesColors colors) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const ScribesPostCardSkeleton(
              showImage: true,
            );
          },
          childCount: 3,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ScribesColors colors) {
    return const Center(
      child: ScribesEmptyState(
        icon: HugeIcons.strokeRoundedNote01,
        title: 'Your scroll is empty',
        subtitle: 'Follow other writers or explore to discover new insights.',
      ),
    );
  }
}
