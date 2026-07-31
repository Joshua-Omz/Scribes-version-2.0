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
import '../../../core/widgets/scribes_scripture_selector.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final postsState = ref.watch(explorePostsProvider);
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
                    isSearchPill: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    onChanged: (query) {
                      ref.read(exploreSearchQueryProvider.notifier).setQuery(query.isEmpty ? null : query);
                    },
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
              // Sticky Header for Search Mode Toggle
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  height: 60.0,
                  backgroundColor: colors.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: _buildSearchModeToggle(searchMode, ref, colors),
                  ),
                ),
              ),
              if (searchMode == ExploreSearchMode.posts)
                _buildPostsFeed(postsState, colors, ref)
              else
                _buildUsersFeed(ref, colors),
            ] else ...[


              // Divider below sticky header
              SliverToBoxAdapter(
                child: Divider(
                  color: colors.border,
                  height: 1,
                  thickness: 1,
                ),
              ),

              // Posts Feed
              _buildPostsFeed(postsState, colors, ref),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPostsFeed(AsyncValue<List<Post>> postsState, dynamic colors, WidgetRef ref) {
    return postsState.when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: ScribesEmptyState(
                          icon: HugeIcons.strokeRoundedSearch01,
                          title: 'No posts found',
                          subtitle: 'Try a different search term.',
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
                          final isFeatured = index == 0;

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
    ScribesScriptureSelector.show(
      context,
      isExplore: true,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        ref.read(exploreScriptureFilterProvider.notifier).setFilter(book, chapter);
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
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Text(
          label,
          style: ScribesTextStyles.labelLg.copyWith(
            color: isSelected ? colors.background : colors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
