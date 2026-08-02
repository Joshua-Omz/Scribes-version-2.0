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
    final data = response.data;
    if (data == null || data is String && data.isEmpty) throw Exception('Post not found');
    return data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPostVersions(String id) async {
    final response = await _dio.get('${Endpoints.posts}/$id/versions');
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return [];
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getMyPosts() async {
    final response = await _dio.get(Endpoints.posts);
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return [];
    return data as List<dynamic>;
  }

  Future<List<dynamic>> listMyPosts() async {
    final response = await _dio.get(Endpoints.posts);
    if (response.data == null) return [];
    return response.data as List<dynamic>;
  }

  Future<List<dynamic>> listByAuthor(String userId) async {
    final response = await _dio.get('${Endpoints.users}/$userId/posts');
    if (response.data == null) return [];
    return response.data as List<dynamic>;
  }

  Future<void> deletePost(String id) async {
    await _dio.delete('${Endpoints.posts}/$id');
  }

  Future<Map<String, dynamic>> revisePost(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('${Endpoints.posts}/$id/revise', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSimilarPosts(String id) async {
    final response = await _dio.get('${Endpoints.posts}/$id/similar');
    final data = response.data['posts'];
    if (data == null) return [];
    return data as List<dynamic>;
  }
}
