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
}

@riverpod
NotificationApi notificationApi(Ref ref) {
  return NotificationApi(ref.watch(apiClientProvider));
}
