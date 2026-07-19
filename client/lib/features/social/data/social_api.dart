import 'package:dio/dio.dart';
import 'package:scribes/core/network/api_client.dart';
import 'package:scribes/core/network/endpoints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final socialApiProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SocialApi(apiClient);
});

class SocialApi {
  final Dio _dio;

  SocialApi(this._dio);

  // ── Reactions ──────────────────────────────────

  Future<List<dynamic>> getReactions(String postId) async {
    final response = await _dio.get('${Endpoints.posts}/$postId/reactions');
    if (response.data == null) return [];
    return response.data as List<dynamic>;
  }

  Future<void> react(String postId, String type) async {
    await _dio.post('${Endpoints.posts}/$postId/reactions', data: {'type': type});
  }

  Future<void> unreact(String postId) async {
    await _dio.delete('${Endpoints.posts}/$postId/reactions');
  }

  // ── Comments ───────────────────────────────────

  Future<List<dynamic>> getComments(String postId) async {
    final response = await _dio.get('${Endpoints.posts}/$postId/comments');
    if (response.data == null) return [];
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> addComment(String postId, String body, List<String> mentions) async {
    final response = await _dio.post('${Endpoints.posts}/$postId/comments', data: {
      'body': body,
      'mentions': mentions,
    });
    return response.data as Map<String, dynamic>;
  }

  /// Unified PATCH endpoint for hide/delete actions.
  /// [action] must be "hide" or "delete".
  Future<void> patchComment(String commentId, String action) async {
    await _dio.patch('${Endpoints.comments}/$commentId', data: {
      'action': action,
    });
  }

  // ── User Lookup ────────────────────────────────

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await _dio.get('${Endpoints.users}/$userId');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> searchUsers(String query) async {
    final response = await _dio.get('${Endpoints.users}/search', queryParameters: {
      'q': query,
    });
    if (response.data == null) return [];
    return response.data as List<dynamic>;
  }
}
