import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../feed/domain/paginated_feed.dart';
import '../domain/category.dart';
import 'explore_api.dart';
import '../../../core/network/api_client.dart';

final exploreRepositoryProvider = Provider<ExploreRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ExploreRepository(ExploreApi(dio));
});

class ExploreRepository {
  final ExploreApi _api;

  ExploreRepository(this._api);

  Future<PaginatedFeed> getExplore({String? cursor, String? categoryId}) {
    return _api.getExplore(cursor: cursor, categoryId: categoryId);
  }

  Future<List<PostCategory>> getCategories() {
    return _api.getCategories();
  }
}
