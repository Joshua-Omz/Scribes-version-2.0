import 'package:dio/dio.dart';

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
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return {'posts': []};
    return data as Map<String, dynamic>;
  }

  Future<List<PostCategory>> getCategories() async {
    final response = await _dio.get('/categories');
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return [];
    final List listData = data as List;
    return listData.map((json) => PostCategory.fromJson(json)).toList();
  }
}
