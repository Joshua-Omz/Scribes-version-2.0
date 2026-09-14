import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_text_field.dart';
import '../../../core/widgets/scribes_user_card.dart';
import '../../../core/widgets/scribes_icon_button.dart';
import '../../../core/widgets/scribes_scripture_selector.dart';
import '../application/search_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final TabController _tabController;
  DateTime? _lastChange;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _lastChange = DateTime.now();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted &&
          _lastChange != null &&
          DateTime.now().difference(_lastChange!).inMilliseconds >= 350) {
        ref.read(searchProvider.notifier).search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.primaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: ScribesTextField(
          controller: _controller,
          hintText: 'Search posts, scriptures, or tags...',
          autofocus: true,
          isSearchPill: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (q) => ref.read(searchProvider.notifier).search(q),
        ),
        actions: [
          Tooltip(
            message: 'Filter by Scripture',
            child: ScribesIconButton(
              icon: HugeIcons.strokeRoundedBookOpen01,
              color: searchState.scriptureBook != null
                  ? colors.gold
                  : colors.secondaryText,
              onPressed: () => _showScriptureFilterSheet(context, ref, colors),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.primaryText,
          indicatorWeight: 2,
          labelColor: colors.primaryText,
          unselectedLabelColor: colors.secondaryText,
          labelStyle: ScribesTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: ScribesTextStyles.labelLg.copyWith(
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(searchState, colors),
          _buildPeopleTab(searchState, colors),
        ],
      ),
    );
  }

  Widget _buildPostsTab(SearchState state, dynamic colors) {
    if (state.isLoading) {
      return const Center(child: ScribesLoadingIndicator());
    }

    if (state.error != null) {
      return Center(
        child: ScribesErrorState(
          title: 'Search failed',
          subtitle: state.error!,
        ),
      );
    }

    if (state.query.isEmpty && state.scriptureBook == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colors.glassFill,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.goldEdge, width: 1.0),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedBookOpen01,
                    color: colors.gold,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Explore Sacred Writings',
                style: ScribesTextStyles.displayMd.copyWith(
                  color: colors.primaryText,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Search by title, topics, authors, or scripture tags (e.g. "John 3:16", "Romans 8").\n\nTip: Tap the book icon in the top right to filter posts by specific biblical books and chapters.',
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.secondaryText,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.posts.isEmpty) {
      return Center(
        child: ScribesEmptyState(
          icon: HugeIcons.strokeRoundedSearch01,
          title: 'No posts found',
          subtitle: 'Try adjusting your search terms or scripture filters.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: ScribesConnectedPostCard(
            post: post,
            isFeatured: false,
            isSearchScreen: true,
          ),
        );
      },
    );
  }

  Widget _buildPeopleTab(SearchState state, dynamic colors) {
    if (state.isLoading) {
      return const Center(child: ScribesLoadingIndicator());
    }

    if (state.error != null) {
      return Center(
        child: ScribesErrorState(
          title: 'Search failed',
          subtitle: state.error!,
        ),
      );
    }

    if (state.query.isEmpty) {
      return Center(
        child: ScribesEmptyState(
          icon: HugeIcons.strokeRoundedSearch01,
          title: 'Find fellow scribes',
          subtitle: 'Search for authors, churches, and ministries.',
        ),
      );
    }

    if (state.authors.isEmpty) {
      return Center(
        child: ScribesEmptyState(
          icon: HugeIcons.strokeRoundedUserRemove01,
          title: 'No scribes found',
          subtitle: 'Try adjusting your search terms.',
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: state.authors.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final author = state.authors[index];
        return ScribesUserCard(user: author, isListTile: true);
      },
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
        ref.read(searchProvider.notifier).setScriptureFilter(book, chapter);
      },
    );
  }
}
