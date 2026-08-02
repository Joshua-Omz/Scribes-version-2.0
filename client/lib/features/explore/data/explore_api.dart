import 'package:dio/dio.dart';



class ExploreApi {
  final Dio _dio;

  ExploreApi(this._dio);

  Future<Map<String, dynamic>> getExplore({
    String? cursor, 
    int limit = 20, 
    String? tag,
    String? searchQuery,
    String? scriptureBook,
    int? scriptureChapter,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (cursor != null) queryParams['cursor'] = cursor;
    if (tag != null) queryParams['tag'] = tag;
    if (searchQuery != null) queryParams['search_query'] = searchQuery;
    if (scriptureBook != null) queryParams['scripture_book'] = scriptureBook;
    if (scriptureChapter != null) queryParams['scripture_chapter'] = scriptureChapter;

    final response = await _dio.get(
      '/explore',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return {'posts': []};
    return data as Map<String, dynamic>;
  }


  Future<Map<String, dynamic>> getRecommendations({
    required String sortType,
    String? cursor, 
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'sort': sortType,
      'limit': limit,
    };
    if (cursor != null) queryParams['offset'] = cursor; // Using offset as cursor for simplicity if that's how the backend is doing it

    final response = await _dio.get(
      '/posts/recommendations',
      queryParameters: queryParams,
    );
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return {'posts': []};
    return data as Map<String, dynamic>;
  }
}
