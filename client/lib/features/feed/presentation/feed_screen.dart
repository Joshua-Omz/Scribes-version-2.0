import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../../core/widgets/scribes_top_app_bar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../application/feed_notifier.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/widgets/scribes_unauth_banner.dart';

import 'package:flutter/rendering.dart';
import '../../../core/widgets/scribes_drawer.dart';
import '../../compose/application/compose_provider.dart';


import '../../../core/widgets/scribes_diamond_fab.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _selectedTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFabVisible = true;

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
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
            icon: Icons.add,
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
                  if (!_isFabVisible) setState(() => _isFabVisible = true);
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (_isFabVisible) setState(() => _isFabVisible = false);
                }
                return false;
              },
              child: RefreshIndicator(
                onRefresh: () => ref.read(feedProvider.notifier).refresh(),
                child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    elevation: 0,
                    backgroundColor: colors.surface,
                    toolbarHeight: 56,
                    titleSpacing: 0,
                    title: const ScribesTopAppBar(),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ScribesTabBarDelegate(
                      child: ScribesTabBar(
                        selectedIndex: _selectedTabIndex,
                        onTabChanged: (index) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
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
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                return const SizedBox.shrink();
                              }

                              final post = posts[index];
                              return ScribesConnectedPostCard(
                                post: post,
                                isFeatured: index == 0,
                              );
                            },
                            childCount: posts.length + (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                          ),
                        );
                    },
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, st) => SliverFillRemaining(
                      child: Center(child: Text('Error: $e')),
                    ),
                  ),
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
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEmptyState(BuildContext context, colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Your scroll is empty',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 24,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow other writers or explore to discover new insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
