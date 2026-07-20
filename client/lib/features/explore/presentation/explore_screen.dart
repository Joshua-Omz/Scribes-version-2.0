import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../application/explore_notifier.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';

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
              centerTitle: true,
              title: Text(
                'Explore',
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                ),
              ),
              leadingWidth: 160,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                    prefixIcon: Icon(Icons.search, size: 18, color: colors.secondaryText),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colors.surfaceRaised,
                  ),
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                  onSubmitted: (query) {
                    ref.read(exploreSearchQueryProvider.notifier).setQuery(query.isEmpty ? null : query);
                  },
                ),
              ),
              actions: [
                ScribesIconButton(
                  icon: Icons.menu_book_outlined,
                  color: colors.secondaryText,
                  onPressed: () => _showScriptureFilterSheet(context, ref, colors),
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
                  loading: () => const Center(child: ScribesLoadingIndicator()),
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
                            child: Center(child: ScribesLoadingIndicator()),
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
                child: Center(child: ScribesLoadingIndicator()),
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
    );
  }

  void _showScriptureFilterSheet(BuildContext context, WidgetRef ref, dynamic colors) {
    final bookController = TextEditingController(text: ref.read(exploreScriptureFilterProvider)?.book ?? '');
    final chapterController = TextEditingController(text: ref.read(exploreScriptureFilterProvider)?.chapter?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by Scripture', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
              const SizedBox(height: 16),
              TextField(
                controller: bookController,
                decoration: InputDecoration(
                  labelText: 'Book (e.g. John)',
                  labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chapterController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Chapter (Optional)',
                  labelStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  filled: true,
                  fillColor: colors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(exploreScriptureFilterProvider.notifier).clear();
                      Navigator.pop(context);
                    },
                    child: Text('Clear', style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.gold,
                      foregroundColor: colors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (bookController.text.isNotEmpty) {
                        int? chapter = int.tryParse(chapterController.text);
                        ref.read(exploreScriptureFilterProvider.notifier).setFilter(bookController.text, chapter);
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Apply', style: ScribesTextStyles.labelLg),
                  ),
                ],
              )
            ],
          ),
        );
      },
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
