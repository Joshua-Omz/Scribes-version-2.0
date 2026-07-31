import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../posts/domain/post.dart';
import '../../social/domain/comment_author.dart';
import '../data/explore_user_repository.dart';
import '../data/explore_repository.dart';


part 'explore_notifier.g.dart';



@riverpod
class ExploreSelectedTag extends _$ExploreSelectedTag {
  @override
  String? build() => null;

  void select(String? tag) {
    state = tag;
  }
}

@riverpod
class ExploreSearchQuery extends _$ExploreSearchQuery {
  @override
  String? build() => null;

  void setQuery(String? query) {
    state = query;
  }
}

@riverpod
class ExploreSearchActive extends _$ExploreSearchActive {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
    if (!state) {
      // Clear query and reset mode when closing search
      ref.read(exploreSearchQueryProvider.notifier).setQuery(null);
      ref.read(exploreSearchModeProvider.notifier).toggleMode(ExploreSearchMode.posts);
    }
  }
}

enum ExploreSearchMode { posts, users }

@riverpod
class ExploreSearchModeNotifier extends _$ExploreSearchModeNotifier {
  @override
  ExploreSearchMode build() => ExploreSearchMode.posts;

  void toggleMode(ExploreSearchMode mode) {
    state = mode;
  }
}

@riverpod
Future<List<CommentAuthor>> exploreUserSearch(Ref ref) async {
  final query = ref.watch(exploreSearchQueryProvider);
  if (query == null || query.trim().isEmpty) return [];
  
  // Debounce search
  var isDisposed = false;
  ref.onDispose(() => isDisposed = true);
  await Future.delayed(const Duration(milliseconds: 400));
  if (isDisposed) return [];

  final repo = ref.watch(exploreUserRepositoryProvider);
  return repo.searchUsers(query);
}

class ScriptureFilter {
  final String book;
  final int? chapter;
  ScriptureFilter(this.book, this.chapter);
}

@riverpod
class ExploreScriptureFilter extends _$ExploreScriptureFilter {
  @override
  ScriptureFilter? build() => null;

  void setFilter(String book, int? chapter) {
    state = ScriptureFilter(book, chapter);
  }

  void clear() {
    state = null;
  }
}

@riverpod
class ExplorePostsNotifier extends _$ExplorePostsNotifier {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    final tag = ref.watch(exploreSelectedTagProvider);
    final searchQuery = ref.watch(exploreSearchQueryProvider);
    final scriptureFilter = ref.watch(exploreScriptureFilterProvider);
    return _fetch(tag, searchQuery, scriptureFilter, null);
  }

  Future<List<Post>> _fetch(String? tag, String? searchQuery, ScriptureFilter? scriptureFilter, String? cursor) async {
    final repo = ref.read(exploreRepositoryProvider);
    final response = await repo.getExplore(
      cursor: cursor, 
      tag: tag,
      searchQuery: searchQuery,
      scriptureBook: scriptureFilter?.book,
      scriptureChapter: scriptureFilter?.chapter,
    );
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final tag = ref.read(exploreSelectedTagProvider);
      final searchQuery = ref.read(exploreSearchQueryProvider);
      final scriptureFilter = ref.read(exploreScriptureFilterProvider);
      final newPosts = await _fetch(tag, searchQuery, scriptureFilter, _nextCursor);
      
      final currentPosts = state.value ?? [];
      state = AsyncData([...currentPosts, ...newPosts]);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _nextCursor = null;
    try {
      final tag = ref.read(exploreSelectedTagProvider);
      final searchQuery = ref.read(exploreSearchQueryProvider);
      final scriptureFilter = ref.read(exploreScriptureFilterProvider);
      final posts = await _fetch(tag, searchQuery, scriptureFilter, null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
