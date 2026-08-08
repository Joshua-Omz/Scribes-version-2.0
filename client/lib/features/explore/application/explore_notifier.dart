import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../posts/domain/post.dart';

import '../data/explore_repository.dart';
import '../../feed/data/feed_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user.dart';


part 'explore_notifier.g.dart';



@riverpod
class ExploreSelectedTag extends _$ExploreSelectedTag {
  @override
  String? build() => null;

  void select(String? tag) {
    state = tag;
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
class ExploreFilteredNotifier extends _$ExploreFilteredNotifier {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    return _fetch(null);
  }

  Future<List<Post>> _fetch(String? cursor) async {
    final filter = ref.read(exploreScriptureFilterProvider);
    if (filter == null) return [];
    
    final repo = ref.read(exploreRepositoryProvider);
    final response = await repo.getExplore(
      cursor: cursor,
      scriptureBook: filter.book,
      scriptureChapter: filter.chapter,
    );
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final newPosts = await _fetch(_nextCursor);
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
      final posts = await _fetch(null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
@riverpod
class ExploreTrendingNotifier extends _$ExploreTrendingNotifier {
  String? _nextCursor;
  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    return _fetch(null);
  }

  Future<List<Post>> _fetch(String? cursor) async {
    final repo = ref.read(exploreRepositoryProvider);
    final response = await repo.getRecommendations(sortType: 'overall', cursor: cursor);
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final newPosts = await _fetch(_nextCursor);
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
      final posts = await _fetch(null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
Future<List<Post>> exploreInsightful(Ref ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  final response = await repo.getRecommendations(sortType: 'insightful', limit: 10);
  return response.posts;
}

@riverpod
Future<List<Post>> exploreProphetic(Ref ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  final response = await repo.getRecommendations(sortType: 'prophetic', limit: 10);
  return response.posts;
}

@riverpod
Future<List<Post>> exploreAffirmed(Ref ref) async {
  final repo = ref.watch(exploreRepositoryProvider);
  final response = await repo.getRecommendations(sortType: 'affirmed', limit: 10);
  return response.posts;
}

@riverpod
class ExploreForYouNotifier extends _$ExploreForYouNotifier {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    return _fetch(null);
  }

  Future<List<Post>> _fetch(String? cursor) async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getForYouPosts(cursor: cursor);
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final newPosts = await _fetch(_nextCursor);
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
      final posts = await _fetch(null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
class ExploreChurchesNotifier extends _$ExploreChurchesNotifier {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    return _fetch(null);
  }

  Future<List<Post>> _fetch(String? cursor) async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getChurchPosts(cursor: cursor);
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;
    if (state.isLoading || state.isRefreshing) return;

    try {
      final newPosts = await _fetch(_nextCursor);
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
      final posts = await _fetch(null);
      state = AsyncData(posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
Future<List<User>> exploreSuggestedUsers(Ref ref) async {
  final repo = ref.read(authRepositoryProvider);
  return repo.getSuggestedUsers(limit: 10);
}
