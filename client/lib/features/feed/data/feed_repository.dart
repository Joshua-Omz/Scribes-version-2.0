import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../posts/domain/post.dart';
import '../domain/paginated_feed.dart';
import 'feed_api.dart';
import '../../../core/network/api_client.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return FeedRepository(FeedApi(dio));
});

class FeedRepository {
  final FeedApi _api;

  FeedRepository(this._api);

  Future<PaginatedFeed> getFeed({String? cursor}) {
    return _api.getFeed(cursor: cursor);
  }
}
