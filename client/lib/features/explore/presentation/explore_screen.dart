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
import '../../../core/widgets/scribes_user_card.dart';
import '../../onboarding/application/onboarding_notifier.dart';
import 'topic_selection_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final searchMode = ref.watch(exploreSearchModeProvider);
    final isSearchActive = ref.watch(exploreSearchActiveProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              floating: true,
              pinned: !isSearchActive,
              elevation: 0,
              centerTitle: !isSearchActive,
              leading: isSearchActive
                  ? IconButton(
                      icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowLeft01,
                          color: colors.primaryText),
                      onPressed: () => ref
                          .read(exploreSearchActiveProvider.notifier)
                          .toggle(),
                    )
                  : null,
              title: isSearchActive
                  ? ScribesTextField(
                      hintText: 'Search...',
                      autofocus: true,
                      isSearchPill: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      onChanged: (query) {
                        ref
                            .read(exploreSearchQueryProvider.notifier)
                            .setQuery(query.isEmpty ? null : query);
                      },
                      onSubmitted: (query) {
                        ref
                            .read(exploreSearchQueryProvider.notifier)
                            .setQuery(query.isEmpty ? null : query);
                      },
                    )
                  : Text(
                      'Explore',
                      style: ScribesTextStyles.displayMd
                          .copyWith(color: colors.primaryText),
                    ),
              actions: [
                if (!isSearchActive) ...[
                  ScribesIconButton(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: colors.secondaryText,
                    onPressed: () => ref
                        .read(exploreSearchActiveProvider.notifier)
                        .toggle(),
                  ),
                  const SizedBox(width: 8),
                  ScribesIconButton(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    color: colors.secondaryText,
                    onPressed: () =>
                        _showScriptureFilterSheet(context, ref, colors),
                  ),
                  const SizedBox(width: 8),
                ]
              ],
              bottom: isSearchActive
                  ? null
                  : TabBar(
                      controller: _tabController,
                      indicatorColor: colors.primaryText,
                      indicatorWeight: 2,
                      labelColor: colors.primaryText,
                      unselectedLabelColor: colors.secondaryText,
                      labelStyle: ScribesTextStyles.labelLg
                          .copyWith(fontWeight: FontWeight.w600),
                      unselectedLabelStyle: ScribesTextStyles.labelLg
                          .copyWith(fontWeight: FontWeight.w400),
                      tabs: const [
                        Tab(text: 'For You'),
                        Tab(text: 'Season'),
                        Tab(text: 'Churches'),
                      ],
                    ),
            ),
            if (isSearchActive)
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoryHeaderDelegate(
                  height: 60.0,
                  backgroundColor: colors.background,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildSearchModeToggle(searchMode, ref, colors),
                  ),
                ),
              ),
          ];
        },
        body: isSearchActive
            ? (searchMode == ExploreSearchMode.posts
                ? _buildSearchPostsFeed(ref, colors)
                : _buildUsersFeed(ref, colors))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildForYouTab(ref, colors),
                  _buildSeasonTab(ref, colors),
                  _buildChurchesTab(ref, colors),
                ],
              ),
      ),
    );
  }

  Widget _buildForYouTab(WidgetRef ref, dynamic colors) {
    final forYouState = ref.watch(exploreForYouProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(exploreForYouProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // Block A: Tags
          SliverToBoxAdapter(
            child: _buildTagsSection(ref, colors),
          ),
          
          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: colors.border),
            ),
          ),

          // Block B: Who to Follow
          SliverToBoxAdapter(
            child: _buildSuggestedUsersSection(ref, colors),
          ),

          // Divider
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(color: colors.border),
            ),
          ),

          // Block C: Posts
          _buildPostsFeedSliver(
            forYouState,
            colors,
            onLoadMore: () => ref.read(exploreForYouProvider.notifier).loadMore(),
            hasMore: ref.read(exploreForYouProvider.notifier).hasMore,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(WidgetRef ref, dynamic colors) {
    final onboardingState = ref.watch(onboardingProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Interests',
                style: ScribesTextStyles.labelLg
                    .copyWith(color: colors.secondaryText, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01, size: 20, color: colors.secondaryText),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => Container(
                      height: MediaQuery.of(ctx).size.height * 0.85,
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: TopicSelectionScreen(
                        isModal: true,
                        onContinue: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (onboardingState.selectedTopics.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'No interests selected yet.',
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.primaryText,
                        foregroundColor: colors.background,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => Container(
                            height: MediaQuery.of(ctx).size.height * 0.85,
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: TopicSelectionScreen(
                              isModal: true,
                              onContinue: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        );
                      },
                      child: const Text('Configure Tags'),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: onboardingState.selectedTopics.map((tag) {
                return Chip(
                  label: Text(tag),
                  labelStyle: ScribesTextStyles.labelSm.copyWith(color: colors.primaryText),
                  backgroundColor: colors.surfaceRaised,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUsersSection(WidgetRef ref, dynamic colors) {
    final suggestedUsersState = ref.watch(exploreSuggestedUsersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
          child: Text(
            'Who to Follow',
            style: ScribesTextStyles.labelLg
                .copyWith(color: colors.secondaryText, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 190,
          child: suggestedUsersState.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    'No suggestions right now.',
                    style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ScribesUserCard(user: users[index]);
                },
              );
            },
            loading: () => const Center(child: ScribesLoadingIndicator()),
            error: (e, st) => Center(
              child: Text(
                'Could not load suggestions.',
                style: ScribesTextStyles.labelSm.copyWith(color: colors.orange),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSeasonTab(WidgetRef ref, dynamic colors) {
    final seasonState = ref.watch(explorePostsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(explorePostsProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          _buildPostsFeedSliver(
            seasonState,
            colors,
            onLoadMore: () => ref.read(explorePostsProvider.notifier).loadMore(),
            hasMore: ref.read(explorePostsProvider.notifier).hasMore,
          ),
        ],
      ),
    );
  }

  Widget _buildChurchesTab(WidgetRef ref, dynamic colors) {
    final churchesState = ref.watch(exploreChurchesProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(exploreChurchesProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          _buildPostsFeedSliver(
            churchesState,
            colors,
            onLoadMore: () => ref.read(exploreChurchesProvider.notifier).loadMore(),
            hasMore: ref.read(exploreChurchesProvider.notifier).hasMore,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPostsFeed(WidgetRef ref, dynamic colors) {
    final postsState = ref.watch(explorePostsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(explorePostsProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          _buildPostsFeedSliver(
            postsState,
            colors,
            onLoadMore: () => ref.read(explorePostsProvider.notifier).loadMore(),
            hasMore: ref.read(explorePostsProvider.notifier).hasMore,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsFeedSliver(
    AsyncValue<List<Post>> postsState,
    dynamic colors, {
    required VoidCallback onLoadMore,
    required bool hasMore,
  }) {
    return postsState.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedSearch01,
                title: 'No posts found',
                subtitle: 'Try exploring different topics.',
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
                  onLoadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: ScribesLoadingIndicator()),
                  );
                }

                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ScribesConnectedPostCard(
                    post: post,
                    isFeatured: false,
                  ),
                );
              },
              childCount: posts.length + (hasMore ? 1 : 0),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
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
        ),
      ),
    );
  }

  void _showScriptureFilterSheet(
      BuildContext context, WidgetRef ref, dynamic colors) {
    ScribesScriptureSelector.show(
      context,
      isExplore: true,
      colors: colors,
      onSelected: (book, chapter, verseStart, verseEnd) {
        ref
            .read(exploreScriptureFilterProvider.notifier)
            .setFilter(book, chapter);
      },
    );
  }

  Widget _buildUsersFeed(WidgetRef ref, dynamic colors) {
    final userSearchState = ref.watch(exploreUserSearchProvider);
    final query = ref.watch(exploreSearchQueryProvider);

    if (query == null || query.trim().isEmpty) {
      return const Center(
        child: ScribesEmptyState(
          icon: HugeIcons.strokeRoundedUserMultiple,
          title: 'Find People',
          subtitle: 'Search for other scribes by name or handle.',
        ),
      );
    }

    return userSearchState.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(
            child: ScribesEmptyState(
              icon: HugeIcons.strokeRoundedUserRemove01,
              title: 'No users found',
              subtitle: 'We couldn\'t find anyone matching your search.',
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colors.surfaceRaised,
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: ScribesTextStyles.labelLg
                      .copyWith(color: colors.primaryText),
                ),
              ),
              title: Text(user.displayName,
                  style: ScribesTextStyles.labelLg
                      .copyWith(color: colors.primaryText)),
              subtitle: Text('@${user.handle}',
                  style: ScribesTextStyles.bodyMd
                      .copyWith(color: colors.secondaryText)),
              onTap: () => context.push('/users/${user.id}'),
            );
          },
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (err, st) => Center(
        child: ScribesErrorState(
          title: 'Could not load users',
          subtitle: err.toString(),
        ),
      ),
    );
  }

  Widget _buildSearchModeToggle(
      ExploreSearchMode mode, WidgetRef ref, dynamic colors) {
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
          Expanded(
              child: _buildToggleItem(
                  'Posts', ExploreSearchMode.posts, mode, ref, colors)),
          Expanded(
              child: _buildToggleItem(
                  'People', ExploreSearchMode.users, mode, ref, colors)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, ExploreSearchMode value,
      ExploreSearchMode current, WidgetRef ref, dynamic colors) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () =>
          ref.read(exploreSearchModeProvider.notifier).toggleMode(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
