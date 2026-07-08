import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<PaginatedFeed> getFeed({String? cursor}) async {
    final rawData = await _api.getFeed(cursor: cursor);
    return _mapPaginatedFeed(rawData);
  }

  PaginatedFeed _mapPaginatedFeed(Map<String, dynamic> data) {
    final posts = (data['posts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return PaginatedFeed.fromJson({
      ...data,
      'posts': posts,
    });
  }
}
