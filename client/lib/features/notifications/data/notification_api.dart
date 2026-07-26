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
}

@riverpod
NotificationApi notificationApi(Ref ref) {
  return NotificationApi(ref.watch(apiClientProvider));
}
