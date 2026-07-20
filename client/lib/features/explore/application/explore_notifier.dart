import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../posts/domain/post.dart';
import '../data/explore_repository.dart';
import '../domain/category.dart';

part 'explore_notifier.g.dart';

@riverpod
class CategoriesNotifier extends _$CategoriesNotifier {
  @override
  FutureOr<List<PostCategory>> build() async {
    final repo = ref.read(exploreRepositoryProvider);
    return repo.getCategories();
  }
}

@riverpod
class ExploreSelectedCategory extends _$ExploreSelectedCategory {
  @override
  String? build() => null;

  void select(String? categoryId) {
    state = categoryId;
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
    final categoryId = ref.watch(exploreSelectedCategoryProvider);
    final searchQuery = ref.watch(exploreSearchQueryProvider);
    final scriptureFilter = ref.watch(exploreScriptureFilterProvider);
    return _fetch(categoryId, searchQuery, scriptureFilter, null);
  }

  Future<List<Post>> _fetch(String? categoryId, String? searchQuery, ScriptureFilter? scriptureFilter, String? cursor) async {
    final repo = ref.read(exploreRepositoryProvider);
    final response = await repo.getExplore(
      cursor: cursor, 
      categoryId: categoryId,
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
      final categoryId = ref.read(exploreSelectedCategoryProvider);
      final searchQuery = ref.read(exploreSearchQueryProvider);
      final scriptureFilter = ref.read(exploreScriptureFilterProvider);
      final newPosts = await _fetch(categoryId, searchQuery, scriptureFilter, _nextCursor);
      
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
      final categoryId = ref.read(exploreSelectedCategoryProvider);
      final searchQuery = ref.read(exploreSearchQueryProvider);
      final scriptureFilter = ref.read(exploreScriptureFilterProvider);
      final posts = await _fetch(categoryId, searchQuery, scriptureFilter, null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
