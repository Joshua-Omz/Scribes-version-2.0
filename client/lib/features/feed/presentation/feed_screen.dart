import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/scribes_post_card.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../../core/widgets/scribes_top_app_bar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../application/feed_notifier.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/widgets/scribes_unauth_banner.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final isAuth = authState.value != null;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(feedProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: false,
                    elevation: 0,
                    backgroundColor: colors.surface,
                    toolbarHeight: 64,
                    flexibleSpace: const ScribesTopAppBar(),
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

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        sliver: SliverList(
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
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: ScribesPostCard(
                                  title: post.content['title'] ?? 'Untitled',
                                  authorName: post.authorName,
                                  authorHandle: post.authorHandle,
                                  bodyExcerpt: post.content['body'] ?? '',
                                  caption: post.caption,
                                  sermonSource: post.sermonSource,
                                  isCorrection: post.isCorrection,
                                  publishedAt: post.publishedAt,
                                  isFeatured: index == 0,
                                  onTap: () => context.push('/posts/${post.id}'),
                                ),
                              );
                            },
                            childCount: posts.length + (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                          ),
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
