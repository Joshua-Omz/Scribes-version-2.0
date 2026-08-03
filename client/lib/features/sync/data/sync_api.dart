import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/sync_event.dart';

final syncApiProvider = Provider((ref) {
  final dio = ref.watch(apiClientProvider);
  return SyncApi(dio);
});

class SyncApi {
  final Dio _dio;

  SyncApi(this._dio);

  Future<List<SyncEvent>> getSyncEvents(int lastSeq) async {
    final response = await _dio.get(
      '/sync',
      queryParameters: {'seq': lastSeq},
    );
    final data = response.data;
    if (data == null || data is String && data.isEmpty) return [];
    
    final listData = data as List<dynamic>;
    return listData.map((e) => SyncEvent.fromJson(e)).toList();
  }

  /// Push a batch of offline mutations to the server in a single request.
  /// Returns the server's max_sequence after applying the batch.
  Future<Map<String, dynamic>> pushBatch(List<Map<String, dynamic>> events) async {
    final response = await _dio.post(
      '/sync/push',
      data: {'events': events},
    );
    return response.data as Map<String, dynamic>;
  }
}
