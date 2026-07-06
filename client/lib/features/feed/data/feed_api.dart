import 'package:dio/dio.dart';
import '../domain/paginated_feed.dart';

class FeedApi {
  final Dio _dio;

  FeedApi(this._dio);

  Future<PaginatedFeed> getFeed({String? cursor, int limit = 20}) async {
    final response = await _dio.get(
      '/feed',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
      },
    );
    return PaginatedFeed.fromJson(response.data);
  }
}
