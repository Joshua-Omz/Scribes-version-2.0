import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/notification_preferences.dart';

part 'settings_provider.g.dart';

@riverpod
class NotificationSettingsNotifier extends _$NotificationSettingsNotifier {
  @override
  Future<NotificationPreferences> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return repo.getNotificationPreferences();
  }

  Future<void> updatePreferences(NotificationPreferences preferences) async {
    final repo = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return repo.updateNotificationPreferences(preferences);
    });
  }
}
