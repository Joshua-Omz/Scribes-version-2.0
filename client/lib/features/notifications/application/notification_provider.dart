import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/notification_model.dart';
import '../data/notification_repository.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  @override
  Future<List<NotificationItem>> build() async {
    final repo = ref.read(notificationRepositoryProvider);
    final response = await repo.getNotifications();
    
    // Update the unread count when we fetch the list
    if (response.hasUnread) {
      // Invalidate hasn't changed it to true because it might already be true, 
      // but it's good to keep them in sync if we had a way to set the unread provider directly.
      // For now, fetching notifications doesn't clear unread on the server (only reading them does).
    }
    
    return response.notifications;
  }

  Future<void> markAllRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllRead();
    
    // Invalidate both lists and the badge
    ref.invalidateSelf();
    ref.invalidate(hasUnreadNotificationsProvider);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
  Future<void> clearAll() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.clearAll();
    ref.invalidateSelf();
    ref.invalidate(hasUnreadNotificationsProvider);
  }

  Future<void> deleteSelected(List<String> ids) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.bulkDelete(ids);
    ref.invalidateSelf();
    ref.invalidate(hasUnreadNotificationsProvider);
  }

  Future<void> markSelectedRead(List<String> ids) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.bulkRead(ids);
    ref.invalidateSelf();
    ref.invalidate(hasUnreadNotificationsProvider);
  }
}

// Separate lightweight provider for the badge dot
// Polled on Feed screen open — does not fetch full list, but uses the same endpoint.
@riverpod
Future<bool> hasUnreadNotifications(Ref ref) async {
  final repo = ref.read(notificationRepositoryProvider);
  final response = await repo.getNotifications();
  return response.hasUnread;
}

@riverpod
Stream<NotificationItem> notificationStream(Ref ref) {
  final repo = ref.read(notificationRepositoryProvider);
  return repo.streamNotifications();
}
