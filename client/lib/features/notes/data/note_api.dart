import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

final noteApiProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NoteApi(apiClient);
});

class NoteApi {
  final Dio _dio;

  NoteApi(this._dio);

  Future<List<dynamic>> getNotes() async {
    final response = await _dio.get(Endpoints.notes);
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return [];
    return data as List<dynamic>;
  }

  Future<Map<String, dynamic>> createNote(Map<String, dynamic> payload) async {
    final response = await _dio.post(Endpoints.notes, data: payload);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateNote(String id, Map<String, dynamic> payload) async {
    final response = await _dio.patch('${Endpoints.notes}/$id', data: payload);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteNote(String id) async {
    await _dio.delete('${Endpoints.notes}/$id');
  }

  Future<Map<String, dynamic>> promoteNoteToDraft(String id) async {
    final response = await _dio.post('${Endpoints.notes}/$id/promote');
    return response.data as Map<String, dynamic>;
  }
}
