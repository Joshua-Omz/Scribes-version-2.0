import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_explore_card.dart';
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
import '../../auth/application/auth_notifier.dart';
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

    return Scaffold(
      backgroundColor: colors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: colors.background,
              surfaceTintColor: Colors.transparent,
              floating: true,
              pinned: true,
              elevation: 0,
              centerTitle: true,
              leading: null,
              title: Text(
                'Explore',
                style: ScribesTextStyles.displayMd
                    .copyWith(color: colors.primaryText),
              ),
              actions: [
                ScribesIconButton(
                  icon: HugeIcons.strokeRoundedSearch01,
                  color: colors.secondaryText,
                  onPressed: () => context.push('/search'),
                ),
                const SizedBox(width: 8),
                ScribesIconButton(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: colors.secondaryText,
                  onPressed: () =>
                      _showScriptureFilterSheet(context, ref, colors),
                ),
                const SizedBox(width: 8),
              ],
              bottom: TabBar(
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
                  Tab(text: 'Discover'),
                  Tab(text: 'Churches'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildForYouTab(ref, colors),
            _buildDiscoverTab(ref, colors),
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
    final user = ref.watch(authProvider).value;
    final selectedTags = user?.selectedTags ?? [];

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
                        onContinue: () {
                          Navigator.of(ctx).pop();
                          ref.invalidate(exploreForYouProvider);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (selectedTags.isEmpty)
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
                              onContinue: () {
                                Navigator.of(ctx).pop();
                                ref.invalidate(exploreForYouProvider);
                              },
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
              children: selectedTags.map((tag) {
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

  Widget _buildDiscoverTab(WidgetRef ref, dynamic colors) {
    final trendingState = ref.watch(exploreTrendingProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(exploreInsightfulProvider);
        ref.invalidate(explorePropheticProvider);
        ref.invalidate(exploreAffirmedProvider);
        await ref.read(exploreTrendingProvider.notifier).refresh();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildRecommendationRow(
              title: 'Most Insightful',
              provider: exploreInsightfulProvider,
              colors: colors,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildRecommendationRow(
              title: 'Prophetic of the Times',
              provider: explorePropheticProvider,
              colors: colors,
            ),
          ),
          SliverToBoxAdapter(
            child: _buildRecommendationRow(
              title: 'Most Affirmed',
              provider: exploreAffirmedProvider,
              colors: colors,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
              child: Text(
                'Trending This Week',
                style: ScribesTextStyles.labelLg
                    .copyWith(color: colors.secondaryText, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          _buildPostsFeedSliver(
            trendingState,
            colors,
            onLoadMore: () => ref.read(exploreTrendingProvider.notifier).loadMore(),
            hasMore: ref.read(exploreTrendingProvider.notifier).hasMore,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationRow({
    required String title,
    required dynamic provider,
    required dynamic colors,
  }) {
    final AsyncValue<List<Post>> state = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 12.0),
          child: Text(
            title,
            style: ScribesTextStyles.labelLg
                .copyWith(color: colors.secondaryText, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 340,
          child: state.when(
            data: (posts) {
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    'No posts available.',
                    style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: posts.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 320,
                    child: ScribesExploreCard(
                      post: posts[index],
                      categoryLabel: title == 'Most Insightful' ? 'Insightful' 
                                   : title == 'Prophetic of the Times' ? 'Prophetic' 
                                   : 'Affirmed',
                      onTap: () => context.push('/post/${posts[index].id}'),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return ScribesShimmer(
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
            error: (e, st) => Center(
              child: Text(
                'Could not load.',
                style: ScribesTextStyles.labelSm.copyWith(color: colors.orange),
              ),
            ),
          ),
        ),
      ],
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
                    isExploreScreen: true,
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

}
