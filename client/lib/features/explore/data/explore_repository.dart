import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/domain/paginated_feed.dart';

import 'explore_api.dart';
import '../../../core/network/api_client.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ExploreRepository(ExploreApi(dio));
});

class ExploreRepository {
  final ExploreApi _api;

  ExploreRepository(this._api);

  Future<PaginatedFeed> getExplore({
    String? cursor, 
    String? tag,
    String? searchQuery,
    String? scriptureBook,
    int? scriptureChapter,
  }) async {
    final rawData = await _api.getExplore(
      cursor: cursor, 
      tag: tag,
      searchQuery: searchQuery,
      scriptureBook: scriptureBook,
      scriptureChapter: scriptureChapter,
    );
    return _mapPaginatedFeed(rawData);
  }

  Future<PaginatedFeed> getRecommendations({
    required String sortType,
    String? cursor,
    int limit = 20,
  }) async {
    final rawData = await _api.getRecommendations(sortType: sortType, cursor: cursor, limit: limit);
    return _mapPaginatedFeed(rawData);
  }

  PaginatedFeed _mapPaginatedFeed(Map<String, dynamic> data) {
    final posts = (data['posts'] as List<dynamic>?)?.map((p) => _mapPostData(p as Map<String, dynamic>)).toList() ?? [];
    return PaginatedFeed.fromJson({
      ...data,
      'posts': posts,
    });
  }

  Map<String, dynamic> _mapPostData(Map<String, dynamic> data) {
    return {
      ...data,
      'is_correction': data['is_correction'] ?? false,
      'is_deleted': data['is_deleted'] ?? false,
      'current_version': data['current_version'] ?? 1,
      'content': data['content'] ?? {},
      'visibility': data['visibility'] ?? 'public',
      'author_name': data['author_name'] ?? 'Unknown Author',
      'author_handle': data['author_handle'] ?? 'unknown',
    };
  }


}
