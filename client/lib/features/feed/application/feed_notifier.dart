import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/state/scroll_aware_state_mixin.dart';
import '../../posts/domain/post.dart';
import '../data/feed_repository.dart';

part 'feed_notifier.g.dart';

@riverpod
class FeedNotifier extends _$FeedNotifier with ScrollAwareStateMixin<List<Post>> {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getFeed();
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;

    // Prevent duplicate loads
    if (state.isLoading || state.isRefreshing) return;

    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;

      final currentPosts = state.value ?? [];
      setStateWhenIdle(AsyncData([...currentPosts, ...response.posts]));
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
      setStateWhenIdle(AsyncData(response.posts));
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }
}

@riverpod
class FollowingFeedNotifier extends _$FollowingFeedNotifier with ScrollAwareStateMixin<List<Post>> {
  String? _nextCursor;

  bool get hasMore => _nextCursor != null;

  @override
  FutureOr<List<Post>> build() async {
    final repo = ref.read(feedRepositoryProvider);
    final response = await repo.getFollowingFeed();
    _nextCursor = response.nextCursor;
    return response.posts;
  }

  Future<void> loadMore() async {
    if (_nextCursor == null) return;

    if (state.isLoading || state.isRefreshing) return;

    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFollowingFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;

      final currentPosts = state.value ?? [];
      setStateWhenIdle(AsyncData([...currentPosts, ...response.posts]));
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
      setStateWhenIdle(AsyncData(response.posts));
    } catch (e, stack) {
      setStateWhenIdle(AsyncError(e, stack));
    }
  }
}
