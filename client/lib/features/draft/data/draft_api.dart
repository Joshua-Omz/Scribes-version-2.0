import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

final draftApiProvider = Provider<DraftApi>((ref) {
  final dio = ref.watch(apiClientProvider);
  return DraftApi(dio);
});

class DraftApi {
  final Dio _dio;

  DraftApi(this._dio);

  Future<Map<String, dynamic>> createDraft(Map<String, dynamic> data) async {
    final response = await _dio.post(Endpoints.drafts, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDraft(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('${Endpoints.drafts}/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDraft(String id) async {
    final response = await _dio.get('${Endpoints.drafts}/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> listDrafts() async {
    final response = await _dio.get(Endpoints.drafts);
    return response.data as List<dynamic>;
  }

  Future<void> deleteDraft(String id) async {
    await _dio.delete('${Endpoints.drafts}/$id');
  }
}
