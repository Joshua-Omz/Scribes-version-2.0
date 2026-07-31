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


}
