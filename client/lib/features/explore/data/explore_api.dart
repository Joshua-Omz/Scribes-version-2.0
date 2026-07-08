import 'package:dio/dio.dart';
import '../../feed/domain/paginated_feed.dart';
import '../domain/category.dart';

class ExploreApi {
  final Dio _dio;

  ExploreApi(this._dio);

  Future<Map<String, dynamic>> getExplore({String? cursor, int limit = 20, String? categoryId}) async {
    final response = await _dio.get(
      '/explore',
      queryParameters: {
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
    return response.data;
  }

  Future<List<PostCategory>> getCategories() async {
    final response = await _dio.get('/categories');
    final List data = response.data;
    return data.map((json) => PostCategory.fromJson(json)).toList();
  }
}
