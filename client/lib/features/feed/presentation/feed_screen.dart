import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/scribes_radius.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_post_card_skeleton.dart';
import '../../../core/widgets/scribes_top_app_bar.dart';
import '../../auth/application/auth_notifier.dart';
import '../application/feed_notifier.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final isAuth = authState.value != null;
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(feedProvider.notifier).refresh(),
        child: CustomScrollView(
          key: const PageStorageKey<String>('unifiedFeed'),
          scrollCacheExtent: const ScrollCacheExtent.pixels(1500),
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              floating: true,
              pinned: false,
              snap: true,
              elevation: 0,
              backgroundColor: colors.background,
              toolbarHeight: 56,
              titleSpacing: 0,
              title: const ScribesTopAppBar(showBottomBorder: false),
            ),
            feedState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: isAuth
                        ? _buildEmptyState(context, colors)
                        : _buildGuestEmptyState(context, colors),
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
                        key: ValueKey(posts[index].id),
                        post: posts[index],
                        isFeatured: index == 0,
                      );
                    },
                    childCount: posts.length +
                        (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                    findChildIndexCallback: (Key key) {
                      if (key is ValueKey<String>) {
                        final index =
                            posts.indexWhere((p) => p.id == key.value);
                        return index != -1 ? index : null;
                      }
                      return null;
                    },
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                  ),
                );
              },
              loading: () => _buildShimmer(colors),
              error: (e, st) => SliverFillRemaining(
                child: ScribesErrorState(
                  title: 'Could not load sanctuary feed',
                  subtitle: e.toString(),
                  onRetry: () => ref.read(feedProvider.notifier).refresh(),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 0),
    );
  }

  Widget _buildShimmer(ScribesColors colors) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return const ScribesPostCardSkeleton(showImage: true);
        }, childCount: 3),
      ),
    );
  }

  Widget _buildGuestEmptyState(BuildContext context, ScribesColors colors) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ScribesEmptyState(
              icon: HugeIcons.strokeRoundedUserGroup,
              title: 'Join the Sanctuary',
              subtitle:
                  'Log in to curate your personal scroll and follow faithful scribes & churches.',
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primaryText,
                side: BorderSide(color: colors.goldEdge, width: 1.2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScribesRadius.button),
                ),
              ),
              onPressed: () => context.push('/auth'),
              child: Text(
                'Log In or Sign Up',
                style: ScribesTextStyles.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ScribesColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.gold.withValues(alpha: 0.1),
                border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedBook02,
                color: colors.gold,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Scroll is Quiet',
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Follow faithful scribes, theologians, and churches to populate your personal scroll.',
              textAlign: TextAlign.center,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScribesRadius.button,
                        ),
                      ),
                    ),
                    onPressed: () => context.go('/explore'),
                    icon: const Icon(Icons.explore, size: 16),
                    label: const Text('Explore', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.goldEdge, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScribesRadius.button,
                        ),
                      ),
                    ),
                    onPressed: () => context.push('/bible'),
                    icon: Icon(Icons.menu_book, size: 16, color: colors.gold),
                    label: Text(
                      'Read Bible',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
