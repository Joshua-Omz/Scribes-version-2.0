import 'package:dio/dio.dart';
import 'package:scribes/core/network/api_exception.dart';


class SearchApi {
  final Dio _client;

  SearchApi(this._client);

  Future<List<dynamic>> searchPosts(String query, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get(
        '/search/posts',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );
      
      final data = response.data['posts'] as List<dynamic>?;
      return data ?? [];
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', e.response?.statusCode);
    }
  }

  Future<List<dynamic>> searchAuthors(String query, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get(
        '/search/users',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );
      
      final data = response.data['authors'] as List<dynamic>?;
      return data ?? [];
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', e.response?.statusCode);
    }
  }

  Future<List<String>> suggestTags(String query) async {
    try {
      final response = await _client.get(
        '/tags/suggest',
        queryParameters: {
          'q': query,
          'limit': 10,
        },
      );
      
      final data = response.data as List<dynamic>?;
      return data?.map((e) => e['name'].toString()).toList() ?? [];
    } on DioException catch (e) {
      throw ApiException(e.message ?? 'Unknown error', e.response?.statusCode);
    }
  }
}
