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
}
