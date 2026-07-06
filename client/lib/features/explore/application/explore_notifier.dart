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
class ExplorePostsNotifier extends _$ExplorePostsNotifier {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    final categoryId = ref.watch(exploreSelectedCategoryProvider);
    return _fetch(categoryId, null);
  }

  Future<List<Post>> _fetch(String? categoryId, String? cursor) async {
    final repo = ref.read(exploreRepositoryProvider);
    final response = await repo.getExplore(cursor: cursor, categoryId: categoryId);
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final categoryId = ref.read(exploreSelectedCategoryProvider);
      final newPosts = await _fetch(categoryId, _nextCursor);
      
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
      final posts = await _fetch(categoryId, null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
