import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../domain/notification_model.dart';

part 'notification_api.g.dart';

class NotificationApi {
  final Dio _dio;

  NotificationApi(this._dio);

  Future<NotificationResponse> getNotifications() async {
    final response = await _dio.get(Endpoints.notifications);
    return NotificationResponse.fromJson(response.data);
  }

  Future<void> markAllRead() async {
    await _dio.post(Endpoints.notificationsReadAll);
  }
  Future<void> clearAll() async {
    await _dio.delete(Endpoints.notificationsClearAll);
  }

  Future<void> bulkDelete(List<String> ids) async {
    await _dio.post(Endpoints.notificationsBulkDelete, data: {'ids': ids});
  }

  Future<void> bulkRead(List<String> ids) async {
    await _dio.post(Endpoints.notificationsBulkRead, data: {'ids': ids});
  }

  Stream<NotificationItem> streamNotifications() async* {
    final response = await _dio.get<ResponseBody>(
      '/notifications/stream',
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream;
    
    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      final lines = text.split('\n');
      for (final line in lines) {
        if (line.startsWith('data:')) {
          final dataStr = line.substring(5).trim();
          if (dataStr.isNotEmpty) {
            try {
              final json = jsonDecode(dataStr);
              yield NotificationItem.fromJson(json);
            } catch (e) {
              // ignore malformed chunks
            }
          }
        }
      }
    }
  }
}

@riverpod
NotificationApi notificationApi(Ref ref) {
  return NotificationApi(ref.watch(apiClientProvider));
}
