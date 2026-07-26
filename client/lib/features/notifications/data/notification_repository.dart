import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/notification_model.dart';
import 'notification_api.dart';

part 'notification_repository.g.dart';

class NotificationRepository {
  final NotificationApi _api;

  NotificationRepository(this._api);

  Future<NotificationResponse> getNotifications() async {
    return _api.getNotifications();
  }

  Future<void> markAllRead() async {
    await _api.markAllRead();
  }

  // Returns grouped notifications by time period: TODAY, THIS WEEK, EARLIER
  Map<String, List<NotificationItem>> groupByTime(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = items.where((n) {
      final diff = now.difference(n.createdAt);
      return diff.inHours < 24 && now.day == n.createdAt.day;
    }).toList();

    final thisWeek = items.where((n) {
      final diff = now.difference(n.createdAt);
      return diff.inDays < 7 && !today.contains(n);
    }).toList();

    final earlier = items.where((n) {
      return !today.contains(n) && !thisWeek.contains(n);
    }).toList();

    final result = <String, List<NotificationItem>>{};
    if (today.isNotEmpty) result['TODAY'] = today;
    if (thisWeek.isNotEmpty) result['THIS WEEK'] = thisWeek;
    if (earlier.isNotEmpty) result['EARLIER'] = earlier;
    
    return result;
  }
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepository(ref.watch(notificationApiProvider));
}
