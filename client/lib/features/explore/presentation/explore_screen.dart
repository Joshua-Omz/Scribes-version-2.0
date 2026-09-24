import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/core/widgets/scribes_user_card.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';

import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_discover_tile.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../../../core/widgets/scribes_spotlight_card.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../posts/domain/post.dart';
import '../application/explore_notifier.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_shimmer.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../../../core/theme/scribes_colors.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../../core/widgets/scribes_keep_alive_item.dart';
import 'topic_selection_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  int _selectedSection = 0; // 0: For You, 1: Discover, 2: Churches
  String _selectedSpotlightFilter = 'all';
  String _selectedForYouTag = 'all';

  Widget _buildSectionChip(int index, String label, ScribesColors colors) {
    final isSelected = _selectedSection == index;
    return GestureDetector(
      onTap: () {
        if (_selectedSection != index) {
          setState(() => _selectedSection = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.glassFill : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.goldEdge
                : colors.border.withValues(alpha: 0.5),
            width: isSelected ? 1.2 : 0.6,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.gold.withValues(alpha: 0.12),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: ScribesTextStyles.labelLg.copyWith(
            color: isSelected ? colors.primaryText : colors.secondaryText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final scriptureFilter = ref.watch(exploreScriptureFilterProvider);

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 1),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              floating: false,
              pinned: true,
              elevation: 0,
              centerTitle: false,
              leading: null,
              title: InkWell(
                onTap: () => context.push('/search'),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: colors.secondaryText,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Search posts, scriptures, authors...',
                          style: ScribesTextStyles.bodyMd.copyWith(
                            color: colors.secondaryText,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                if (scriptureFilter != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: Text(
                        '${scriptureFilter.book} ${scriptureFilter.chapter ?? ''}'
                            .trim(),
                      ),
                      onPressed: () {
                        ref
                            .read(exploreScriptureFilterProvider.notifier)
                            .clear();
                      },
                      avatar: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: colors.primaryText,
                        size: 14,
                      ),
                      backgroundColor: colors.surfaceRaised,
                      labelStyle: ScribesTextStyles.labelSm.copyWith(
                        color: colors.primaryText,
                      ),
                      side: BorderSide(color: colors.goldEdge, width: 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                Tooltip(
                  message: 'Filter by Scripture',
                  child: ScribesIconButton(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    color: scriptureFilter != null
                        ? colors.gold
                        : colors.secondaryText,
                    onPressed: () =>
                        _showScriptureFilterSheet(context, ref, colors),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              bottom: scriptureFilter == null
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(46),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        alignment: Alignment.centerLeft,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSectionChip(0, 'For You', colors),
                              const SizedBox(width: 8),
                              _buildSectionChip(1, 'Discover', colors),
                              const SizedBox(width: 8),
                              _buildSectionChip(2, 'Churches', colors),
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: scriptureFilter == null
            ? AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_selectedSection),
                  child: switch (_selectedSection) {
                    0 => _buildForYouTab(context, ref, colors),
                    1 => _buildDiscoverTab(ref, colors),
                    2 => _buildChurchesTab(ref, colors),
                    _ => _buildForYouTab(context, ref, colors),
                  },
                ),
              )
            : _buildFilteredTab(ref, colors),
      ),
    );
  }

  Widget _buildFilteredTab(WidgetRef ref, dynamic colors) {
    final filteredState = ref.watch(exploreFilteredProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 600) {
          final notifier = ref.read(exploreFilteredProvider.notifier);
          final currentState = ref.read(exploreFilteredProvider);
          if (notifier.hasMore &&
              !currentState.isLoading &&
              !currentState.isRefreshing) {
            notifier.loadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(exploreFilteredProvider.notifier).refresh(),
        child: CustomScrollView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(1500),
          slivers: [
            filteredState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return SliverFillRemaining(
                    child: ScribesEmptyState(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      title: 'No posts found',
                      subtitle: 'No scriptures have been referenced here yet.',
                    ),
                  );
                }
                final hasMore = ref
                    .read(exploreFilteredProvider.notifier)
                    .hasMore;
                final postIndexMap = {
                  for (var i = 0; i < posts.length; i++) posts[i].id: i,
                };
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == posts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: ScribesLoadingIndicator(),
                          );
                        }
                        return Padding(
                          key: ValueKey(posts[index].id),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: RepaintBoundary(
                            child: ScribesConnectedPostCard(
                              post: posts[index],
                              isFeatured: false,
                              isExploreScreen: true,
                            ),
                          ),
                        );
                      },
                      childCount: posts.length + (hasMore ? 1 : 0),
                      findChildIndexCallback: (Key key) {
                        if (key is ValueKey<String>) {
                          return postIndexMap[key.value];
                        }
                        return null;
                      },
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                    ),
                  ),
                );
              },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
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
                }, childCount: 4),
              ),
            ),
            error: (e, st) => SliverFillRemaining(
              child: ScribesErrorState(
                title: 'Could not load posts',
                subtitle: e.toString(),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    ),
  );
}

  void _openTopicSelectionModal(
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: TopicSelectionScreen(
          isModal: true,
          onContinue: () {
            Navigator.of(ctx).pop();
            ref.invalidate(exploreForYouProvider);
          },
        ),
      ),
    );
  }

  Widget _buildForYouFilterChip({
    required String id,
    required String label,
    required dynamic colors,
  }) {
    final isSelected = _selectedForYouTag == id;
    return GestureDetector(
      onTap: () {
        if (_selectedForYouTag != id) {
          setState(() {
            _selectedForYouTag = id;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.glassFill : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colors.goldEdge
                : colors.border.withValues(alpha: 0.6),
            width: isSelected ? 1.2 : 0.6,
          ),
        ),
        child: Text(
          label,
          style: ScribesTextStyles.caption.copyWith(
            color: colors.primaryText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildForYouHeaderAndTopics(
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
  ) {
    final user = ref.watch(authProvider).value;
    final selectedTags = user?.selectedTags ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedQuillWrite01,
                    color: colors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PERSONAL CHRONICLE',
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _openTopicSelectionModal(context, ref, colors),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSlidersHorizontal,
                        color: colors.gold,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Interests',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedTags.isEmpty)
            InkWell(
              onTap: () => _openTopicSelectionModal(context, ref, colors),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedPlusSign,
                      color: colors.gold,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Choose theological interests...',
                      style: ScribesTextStyles.labelSm.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            RepaintBoundary(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildForYouFilterChip(
                      id: 'all',
                      label: 'All',
                      colors: colors,
                    ),
                    const SizedBox(width: 6),
                    ...selectedTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: _buildForYouFilterChip(
                          id: tag.toLowerCase(),
                          label: tag,
                          colors: colors,
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () =>
                          _openTopicSelectionModal(context, ref, colors),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceRaised.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.5),
                            width: 0.6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedEdit02,
                              color: colors.secondaryText,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestedUsersSection(WidgetRef ref, dynamic colors) {
    final suggestedUsersState = ref.watch(exploreSuggestedUsersProvider);

    return suggestedUsersState.when(
      data: (users) {
        if (users.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedUserCheck01,
                      color: colors.gold,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FAITHFUL SCRIBES',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Voices to Follow',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 175,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return ScribesUserCard(user: users[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildForYouFeedSliver(
    AsyncValue<List<Post>> forYouState,
    dynamic colors,
  ) {
    return forYouState.when(
      data: (allPosts) {
        if (allPosts.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedBookOpen01,
                title: 'No manuscripts found',
                subtitle:
                    'Check back soon or select more interests to personalize your feed.',
              ),
            ),
          );
        }

        final posts = _selectedForYouTag == 'all'
            ? allPosts
            : allPosts.where((p) {
                final tagMatch = p.tags.any(
                  (t) =>
                      t.toLowerCase() == _selectedForYouTag.toLowerCase(),
                );
                if (tagMatch) return true;
                final excerpt = p.plainTextBody.toLowerCase();
                return excerpt.contains(_selectedForYouTag.toLowerCase());
              }).toList();

        if (posts.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedFilter,
                      color: colors.secondaryText,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No scrolls tagged with "$_selectedForYouTag"',
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try selecting "All" or exploring different topics.',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          setState(() => _selectedForYouTag = 'all'),
                      child: Text(
                        'Show All Scrolls',
                        style: TextStyle(color: colors.gold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final spotlightCount = posts.length >= 3 ? 3 : 1;
        final spotlightPosts = posts.take(spotlightCount).toList();
        final remainingPosts = posts.skip(spotlightCount).toList();
        final hasMore = ref.read(exploreForYouProvider.notifier).hasMore;

        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 10.0),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSparkles,
                          color: colors.gold,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RECOMMENDED SPOTLIGHT',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Selected for You',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText
                                .withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 215,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      scrollDirection: Axis.horizontal,
                      scrollCacheExtent: const ScrollCacheExtent.pixels(800),
                      physics: const BouncingScrollPhysics(),
                      itemCount: spotlightPosts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final post = spotlightPosts[index];
                        return ScribesKeepAliveItem(
                          key: ValueKey('for_you_spotlight_${post.id}'),
                          child: RepaintBoundary(
                            child: ScribesSpotlightCard(
                              post: post,
                              categoryLabel: post.tags.isNotEmpty
                                  ? post.tags.first.toUpperCase()
                                  : 'RECOMMENDED',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 6.0),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      color: colors.primaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CURATED CHRONICLES',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Personal Feed',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText
                            .withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Builder(
              builder: (context) {
                final postIndexMap = {
                  for (var i = 0; i < remainingPosts.length; i++)
                    remainingPosts[i].id: i,
                };
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == remainingPosts.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: ScribesLoadingIndicator()),
                          );
                        }
                        final post = remainingPosts[index];
                        return Padding(
                          key: ValueKey(post.id),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: RepaintBoundary(
                            child: ScribesDiscoverTile(
                              post: post,
                              categoryLabel:
                                  post.tags.isNotEmpty ? post.tags.first : null,
                            ),
                          ),
                        );
                      },
                      childCount: remainingPosts.length + (hasMore ? 1 : 0),
                      findChildIndexCallback: (Key key) {
                        if (key is ValueKey<String>) {
                          return postIndexMap[key.value];
                        }
                        return null;
                      },
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => SliverPadding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ScribesShimmer(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            childCount: 5,
          ),
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        child: ScribesErrorState(
          title: 'Could not load your feed',
          subtitle: e.toString(),
        ),
      ),
    );
  }

  Widget _buildForYouTab(
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
  ) {
    final forYouState = ref.watch(exploreForYouProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 600) {
          final notifier = ref.read(exploreForYouProvider.notifier);
          final currentState = ref.read(exploreForYouProvider);
          if (notifier.hasMore &&
              !currentState.isLoading &&
              !currentState.isRefreshing) {
            notifier.loadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(exploreForYouProvider.notifier).refresh(),
        child: CustomScrollView(
        scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
        slivers: [
          // 1. Personalized Header & Interactive Topics
          SliverToBoxAdapter(
            child: _buildForYouHeaderAndTopics(context, ref, colors),
          ),

          // 2. Faithful Scribes Section (collapses to 0 if empty/loading)
          SliverToBoxAdapter(
            child: _buildSuggestedUsersSection(ref, colors),
          ),

          // 3. For You Posts Stream (Hero Spotlight + Curated Discovery Tiles)
          _buildForYouFeedSliver(forYouState, colors),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDiscoverTab(WidgetRef ref, dynamic colors) {
    final discoverState = ref.watch(exploreDiscoverProvider);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 600) {
          final notifier = ref.read(exploreDiscoverProvider.notifier);
          final currentState = ref.read(exploreDiscoverProvider);
          if (notifier.hasMore &&
              !currentState.isLoading &&
              !currentState.isRefreshing) {
            notifier.loadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(exploreInsightfulProvider);
          ref.invalidate(explorePropheticProvider);
          ref.invalidate(exploreAffirmedProvider);
          await ref.read(exploreDiscoverProvider.notifier).refresh();
        },
        child: CustomScrollView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(1200),
          slivers: [
            // 1. Curated Spotlight Header & Filter Chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedSparkles,
                              color: colors.gold,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CURATED SPOTLIGHT',
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Theological Index',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Responsive Filter Chips Row (No horizontal scroll fight)
                    Row(
                      children: [
                        _buildSpotlightFilterChip(
                          id: 'all',
                          label: 'Curated',
                          colors: colors,
                        ),
                        const SizedBox(width: 6),
                        _buildSpotlightFilterChip(
                          id: 'insightful',
                          label: 'Insightful',
                          colors: colors,
                        ),
                        const SizedBox(width: 6),
                        _buildSpotlightFilterChip(
                          id: 'prophetic',
                          label: 'Prophetic',
                          colors: colors,
                        ),
                        const SizedBox(width: 6),
                        _buildSpotlightFilterChip(
                          id: 'affirmed',
                          label: 'Affirmed',
                          colors: colors,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. The Single Hero Spotlight Carousel (215px instead of 1200px stack!)
            SliverToBoxAdapter(
              child: _buildSpotlightCarousel(ref, colors),
            ),

            // 3. Section Header for Recent Discoveries
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 6.0),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBookOpen01,
                      color: colors.primaryText,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RECENT DISCOVERIES',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Sacred Archive',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. True High-Performance Virtualized Slivers for Discoveries
            _buildDiscoverTilesFeedSliver(discoverState, colors),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightFilterChip({
    required String id,
    required String label,
    required dynamic colors,
  }) {
    final isSelected = _selectedSpotlightFilter == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedSpotlightFilter != id) {
            setState(() {
              _selectedSpotlightFilter = id;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? colors.gold : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? colors.gold : colors.border.withValues(alpha: 0.6),
              width: 0.6,
            ),
          ),
          child: Text(
            label,
            style: ScribesTextStyles.caption.copyWith(
              color: isSelected ? colors.background : colors.primaryText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildSpotlightCarousel(WidgetRef ref, dynamic colors) {
    AsyncValue<List<Post>> state;
    String categoryLabel;
    switch (_selectedSpotlightFilter) {
      case 'insightful':
        state = ref.watch(exploreInsightfulProvider);
        categoryLabel = 'Insightful';
        break;
      case 'prophetic':
        state = ref.watch(explorePropheticProvider);
        categoryLabel = 'Prophetic';
        break;
      case 'affirmed':
        state = ref.watch(exploreAffirmedProvider);
        categoryLabel = 'Affirmed';
        break;
      case 'all':
      default:
        state = ref.watch(exploreInsightfulProvider);
        categoryLabel = 'Curated';
        break;
    }

    return SizedBox(
      height: 220,
      child: state.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Text(
                'No spotlight manuscripts available.',
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.secondaryText,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            scrollCacheExtent: const ScrollCacheExtent.pixels(800),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final post = posts[index];
              return ScribesKeepAliveItem(
                key: ValueKey('discover_spotlight_${post.id}'),
                child: RepaintBoundary(
                  child: ScribesSpotlightCard(
                    post: post,
                    categoryLabel: categoryLabel,
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 14),
          itemBuilder: (context, index) => ScribesShimmer(
            child: Container(
              width: 290,
              height: 215,
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        error: (e, st) => Center(
          child: Text(
            'Could not load spotlight.',
            style: ScribesTextStyles.labelSm.copyWith(color: colors.orange),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverTilesFeedSliver(
    AsyncValue<List<Post>> discoverState,
    dynamic colors,
  ) {
    return discoverState.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedSearch01,
                title: 'No manuscripts found',
                subtitle: 'Check back soon for new theological reflections.',
              ),
            ),
          );
        }
        final hasMore = ref.read(exploreDiscoverProvider.notifier).hasMore;
        final postIndexMap = {
          for (var i = 0; i < posts.length; i++) posts[i].id: i,
        };
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: ScribesLoadingIndicator()),
                  );
                }
                final post = posts[index];
                return Padding(
                  key: ValueKey(post.id),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RepaintBoundary(
                    child: ScribesDiscoverTile(
                      post: post,
                      categoryLabel:
                          post.tags.isNotEmpty ? post.tags.first : null,
                    ),
                  ),
                );
              },
              childCount: posts.length + (hasMore ? 1 : 0),
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<String>) {
                  return postIndexMap[key.value];
                }
                return null;
              },
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ScribesShimmer(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            childCount: 5,
          ),
        ),
      ),
      error: (e, st) => SliverFillRemaining(
        child: ScribesErrorState(
          title: 'Could not load discoveries',
          subtitle: e.toString(),
        ),
      ),
    );
  }

  Widget _buildChurchesTab(WidgetRef ref, dynamic colors) {
    final churchesState = ref.watch(exploreChurchesProvider);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 600) {
          final notifier = ref.read(exploreChurchesProvider.notifier);
          final currentState = ref.read(exploreChurchesProvider);
          if (notifier.hasMore &&
              !currentState.isLoading &&
              !currentState.isRefreshing) {
            notifier.loadMore();
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => ref.read(exploreChurchesProvider.notifier).refresh(),
        child: CustomScrollView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(1500),
          slivers: [
            _buildPostsFeedSliver(
              churchesState,
              colors,
              hasMore: ref.read(exploreChurchesProvider.notifier).hasMore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsFeedSliver(
    AsyncValue<List<Post>> postsState,
    dynamic colors, {
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

        final postIndexMap = {
          for (var i = 0; i < posts.length; i++) posts[i].id: i,
        };

        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == posts.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: ScribesLoadingIndicator()),
                  );
                }

                final post = posts[index];
                return Padding(
                  key: ValueKey(post.id),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: RepaintBoundary(
                    child: ScribesConnectedPostCard(
                      post: post,
                      isFeatured: false,
                      isExploreScreen: true,
                    ),
                  ),
                );
              },
              childCount: posts.length + (hasMore ? 1 : 0),
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<String>) {
                  return postIndexMap[key.value];
                }
                return null;
              },
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
            ),
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
          }, childCount: 4),
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
    BuildContext context,
    WidgetRef ref,
    dynamic colors,
  ) {
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
}
