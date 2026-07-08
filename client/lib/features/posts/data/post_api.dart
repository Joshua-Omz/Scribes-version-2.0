import 'package:dio/dio.dart';
import 'package:scribes/core/network/api_client.dart';
import 'package:scribes/core/network/endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postApiProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PostApi(apiClient);
});

class PostApi {
  final Dio _dio;

  PostApi(this._dio);

  Future<Map<String, dynamic>> getPost(String id) async {
    final response = await _dio.get('${Endpoints.posts}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPostVersions(String id) async {
    final response = await _dio.get('${Endpoints.posts}/$id/versions');
    return response.data as List<dynamic>;
  }
}
