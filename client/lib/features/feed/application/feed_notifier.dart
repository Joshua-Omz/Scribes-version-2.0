import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/state/scroll_aware_state_mixin.dart';
import '../../posts/domain/post.dart';
import '../data/feed_repository.dart';

part 'feed_notifier.g.dart';

class FeedState {
  final List<String> postIds;
  final Map<String, Post> posts;

  FeedState({required this.postIds, required this.posts});
}

@riverpod
class FeedNotifier extends _$FeedNotifier with ScrollAwareStateMixin<FeedState> {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<FeedState> build() async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getFeed();
    _nextCursor = response.nextCursor;
    final postIds = response.posts.map((p) => p.id).toList();
    final postsMap = {for (var p in response.posts) p.id: p};
    return FeedState(postIds: postIds, posts: postsMap);
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;

    // Prevent duplicate loads
    if (state.isLoading || state.isRefreshing) return;

    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;

      final current = state.value;
      if (current != null) {
        final newPostIds = [...current.postIds, ...response.posts.map((p) => p.id)];
        final newPostsMap = {...current.posts, for (var p in response.posts) p.id: p};
        setStateWhenIdle(AsyncData(FeedState(postIds: newPostIds, posts: newPostsMap)));
      }
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _nextCursor = null;
    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFeed();
      _nextCursor = response.nextCursor;
      final postIds = response.posts.map((p) => p.id).toList();
      final postsMap = {for (var p in response.posts) p.id: p};
      setStateWhenIdle(AsyncData(FeedState(postIds: postIds, posts: postsMap)));
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }
}

@riverpod
class FollowingFeedNotifier extends _$FollowingFeedNotifier with ScrollAwareStateMixin<FeedState> {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<FeedState> build() async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getFollowingFeed();
    _nextCursor = response.nextCursor;
    final postIds = response.posts.map((p) => p.id).toList();
    final postsMap = {for (var p in response.posts) p.id: p};
    return FeedState(postIds: postIds, posts: postsMap);
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;

    if (state.isLoading || state.isRefreshing) return;

    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFollowingFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;

      final current = state.value;
      if (current != null) {
        final newPostIds = [...current.postIds, ...response.posts.map((p) => p.id)];
        final newPostsMap = {...current.posts, for (var p in response.posts) p.id: p};
        setStateWhenIdle(AsyncData(FeedState(postIds: newPostIds, posts: newPostsMap)));
      }
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _nextCursor = null;
    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFollowingFeed();
      _nextCursor = response.nextCursor;
      final postIds = response.posts.map((p) => p.id).toList();
      final postsMap = {for (var p in response.posts) p.id: p};
      setStateWhenIdle(AsyncData(FeedState(postIds: postIds, posts: postsMap)));
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }
}
