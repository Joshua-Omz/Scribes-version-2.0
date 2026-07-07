
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../posts/domain/post.dart';
import '../data/feed_repository.dart';


part 'feed_notifier.g.dart';

@riverpod
class FeedNotifier extends _$FeedNotifier {
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
    
    // Using AsyncLoading will replace the previous list, which is bad for infinite scroll,
    // so we handle it without setting state to loading if we want to keep current posts.
    // Instead we just fetch and append.
    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFeed(cursor: _nextCursor);
      _nextCursor = response.nextCursor;
      
      final currentPosts = state.value ?? [];
      state = AsyncData([...currentPosts, ...response.posts]);
    } catch (e, stack) {
      // Don't override state with error, just keep old posts or handle error in UI
      // If we strictly follow riverpod best practices, we could keep previous state.
      state = AsyncError(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    _nextCursor = null;
    try {
      final repo = ref.read(feedRepositoryProvider);
      final response = await repo.getFeed();
      _nextCursor = response.nextCursor;
      state = AsyncData(response.posts);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
