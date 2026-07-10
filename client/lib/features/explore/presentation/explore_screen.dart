import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../application/explore_notifier.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final postsState = ref.watch(explorePostsProvider);
    final selectedCategory = ref.watch(exploreSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(explorePostsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              floating: true,
              snap: true,
              elevation: 0,
              centerTitle: false,
              title: Text(
                'Explore',
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                ),
              ),
              actions: [
                ScribesIconButton(
                  icon: Icons.search_outlined,
                  color: colors.secondaryText,
                  onPressed: () {
                    // Search not implemented in v1 MVP
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            // Categories Sticky Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryHeaderDelegate(
                height: 56.0,
                backgroundColor: colors.background,
                child: categoriesState.when(
                  data: (categories) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          // "All" chip
                          return _buildCategoryChip(
                            context: context,
                            label: 'All',
                            isSelected: selectedCategory == null,
                            colors: colors,
                            onSelected: () => ref.read(exploreSelectedCategoryProvider.notifier).select(null),
                          );
                        }
                        final cat = categories[index - 1];
                        return _buildCategoryChip(
                          context: context,
                          label: cat.name,
                          isSelected: selectedCategory == cat.id,
                          colors: colors,
                          onSelected: () => ref.read(exploreSelectedCategoryProvider.notifier).select(cat.id),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error', style: TextStyle(color: colors.primaryText))),
                ),
              ),
            ),

            // Divider below sticky header
            SliverToBoxAdapter(
              child: Divider(
                color: colors.border,
                height: 1,
                thickness: 1,
              ),
            ),

            // Posts Feed
            postsState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No posts found.',
                        style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == posts.length) {
                          ref.read(explorePostsProvider.notifier).loadMore();
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final post = posts[index];
                        final isFeatured = index == 0 && selectedCategory == null;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ScribesConnectedPostCard(
                            post: post,
                            isFeatured: isFeatured,
                          ),
                        );
                      },
                      childCount: posts.length + (ref.read(explorePostsProvider.notifier).hasMore ? 1 : 0),
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => SliverFillRemaining(
                child: Center(
                  child: Text('Error: \$e', style: TextStyle(color: colors.primaryText)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 1),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required dynamic colors,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onSelected,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryText : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colors.primaryText : colors.border,
            ),
          ),
          child: Text(
            label,
            style: ScribesTextStyles.labelLg.copyWith(
              color: isSelected ? colors.surface : colors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final Color backgroundColor;

  _CategoryHeaderDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.height != height ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
