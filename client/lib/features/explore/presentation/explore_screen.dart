import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../posts/domain/post.dart';
import '../application/explore_notifier.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final categoriesState = ref.watch(categoriesProvider);
    final postsState = ref.watch(explorePostsProvider);
    final selectedCategory = ref.watch(exploreSelectedCategoryProvider);
    final searchMode = ref.watch(exploreSearchModeProvider);
    final isSearchActive = ref.watch(exploreSearchActiveProvider);

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
              centerTitle: !isSearchActive,
              leading: isSearchActive 
                ? IconButton(
                    icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
                    onPressed: () => ref.read(exploreSearchActiveProvider.notifier).toggle(),
                  )
                : null,
              title: isSearchActive
                ? ScribesTextField(
                    hintText: 'Search...',
                    autofocus: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    onSubmitted: (query) {
                      ref.read(exploreSearchQueryProvider.notifier).setQuery(query.isEmpty ? null : query);
                    },
                  )
                : Text(
                    'Explore',
                    style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                  ),
              actions: [
                if (!isSearchActive) ...[
                  ScribesIconButton(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: colors.secondaryText,
                    onPressed: () => ref.read(exploreSearchActiveProvider.notifier).toggle(),
                  ),
                  const SizedBox(width: 8),
                  ScribesIconButton(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    color: colors.secondaryText,
                    onPressed: () => _showScriptureFilterSheet(context, ref, colors),
                  ),
                  const SizedBox(width: 8),
                ]
              ],
            ),
            
            if (isSearchActive) ...[
              SliverToBoxAdapter(
                child: _buildSearchModeToggle(searchMode, ref, colors),
              ),
              if (searchMode == ExploreSearchMode.posts)
                _buildPostsFeed(postsState, selectedCategory, colors, ref)
              else
                _buildUsersFeed(ref, colors),
            ] else ...[
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
                    error: (e, st) => const Center(child: HugeIcon(icon: HugeIcons.strokeRoundedAlert01, color: Colors.orange, size: 24)),
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
              _buildPostsFeed(postsState, selectedCategory, colors, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostsFeed(AsyncValue<List<Post>> postsState, String? selectedCategory, dynamic colors, WidgetRef ref) {
    return postsState.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: ScribesEmptyState(
                          icon: HugeIcons.strokeRoundedSearch01,
                          title: 'No posts found',
                          subtitle: 'Try a different category or search term.',
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
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: ScribesShimmer(
                            child: Container(
                              height: 180,
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: 4,
                    ),
                  ),
                ),
      error: (e, st) => SliverFillRemaining(
        child: ScribesErrorState(
          title: 'Could not load posts',
          subtitle: e.toString(),
          onRetry: () => ref.read(explorePostsProvider.notifier).refresh(),
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
              ScribesTextField(
                controller: bookController,
                labelText: 'Book (e.g. John)',
              ),
              const SizedBox(height: 12),
              ScribesTextField(
                controller: chapterController,
                keyboardType: TextInputType.number,
                labelText: 'Chapter (Optional)',
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

  Widget _buildUsersFeed(WidgetRef ref, dynamic colors) {
    final userSearchState = ref.watch(exploreUserSearchProvider);
    final query = ref.watch(exploreSearchQueryProvider);

    if (query == null || query.trim().isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: ScribesEmptyState(
            icon: HugeIcons.strokeRoundedUserMultiple,
            title: 'Find People',
            subtitle: 'Search for other scribes by name or handle.',
          ),
        ),
      );
    }

    return userSearchState.when(
      data: (users) {
        if (users.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedUserRemove01,
                title: 'No users found',
                subtitle: 'We couldn\'t find anyone matching your search.',
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors.surfaceRaised,
                    child: Text(
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                      style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
                    ),
                  ),
                  title: Text(user.displayName, style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
                  subtitle: Text('@${user.handle}', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
                  onTap: () => context.push('/users/${user.id}'),
                );
              },
              childCount: users.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
      error: (err, st) => SliverFillRemaining(
        child: ScribesErrorState(
          title: 'Could not load users',
          subtitle: err.toString(),
        ),
      ),
    );
  }

  Widget _buildSearchModeToggle(ExploreSearchMode mode, WidgetRef ref, dynamic colors) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleItem('Posts', ExploreSearchMode.posts, mode, ref, colors)),
          Expanded(child: _buildToggleItem('People', ExploreSearchMode.users, mode, ref, colors)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, ExploreSearchMode value, ExploreSearchMode current, WidgetRef ref, dynamic colors) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => ref.read(exploreSearchModeProvider.notifier).toggleMode(value),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: ScribesTextStyles.labelLg.copyWith(
            color: isSelected ? colors.background : colors.secondaryText,
          ),
        ),
      ),
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
