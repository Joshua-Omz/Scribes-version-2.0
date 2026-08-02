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
import '../application/search_notifier.dart';

enum SearchMode { posts, people }

class SearchModeNotifier extends Notifier<SearchMode> {
  @override
  SearchMode build() => SearchMode.posts;
  
  void setMode(SearchMode mode) => state = mode;
}

final searchModeProvider =
    NotifierProvider<SearchModeNotifier, SearchMode>(SearchModeNotifier.new);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;
  // A simple manual debounce mechanism
  DateTime? _lastChange;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _lastChange = DateTime.now();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _lastChange != null && DateTime.now().difference(_lastChange!).inMilliseconds >= 400) {
        ref.read(searchProvider.notifier).search(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final searchState = ref.watch(searchProvider);
    final searchMode = ref.watch(searchModeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: ScribesTextField(
          controller: _controller,
          hintText: 'Search posts, people...',
          autofocus: true,
          isSearchPill: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          onChanged: _onSearchChanged,
          onSubmitted: (q) => ref.read(searchProvider.notifier).search(q),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _buildSearchModeToggle(searchMode, ref, colors),
          ),
          Expanded(
            child: _buildBody(searchState, searchMode, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state, SearchMode mode, dynamic colors) {
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
          title: 'What are you looking for?',
          subtitle: 'Search for posts or other scribes.',
        ),
      );
    }

    if (mode == SearchMode.posts) {
      if (state.posts.isEmpty) {
        return Center(
          child: ScribesEmptyState(
            icon: HugeIcons.strokeRoundedSearch01,
            title: 'No posts found',
            subtitle: 'Try adjusting your search terms.',
          ),
        );
      }
      return ListView.builder(
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ScribesConnectedPostCard(post: post, isFeatured: false),
          );
        },
      );
    } else {
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: state.authors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final author = state.authors[index];
          return ScribesUserCard(user: author);
        },
      );
    }
  }

  Widget _buildSearchModeToggle(
      SearchMode mode, WidgetRef ref, dynamic colors) {
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
                  'Posts', SearchMode.posts, mode, ref, colors)),
          Expanded(
              child: _buildToggleItem(
                  'People', SearchMode.people, mode, ref, colors)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, SearchMode value,
      SearchMode current, WidgetRef ref, dynamic colors) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => ref.read(searchModeProvider.notifier).setMode(value),
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
