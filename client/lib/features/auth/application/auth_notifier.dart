import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';
import '../../sync/application/sync_service.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final hasToken = await repo.hasToken();
    if (!hasToken) {
      return null;
    }
    
    // Fetch the user profile from the /me endpoint
    try {
      final user = await repo.getMe();
      // Trigger sync in background
      _triggerSync();
      return user;
    } catch (e) {
      // If fetching the profile fails (e.g., token expired/invalid on server),
      // we might want to log out or just return null.
      // For now, if /me fails, we assume we're not authenticated.
      await repo.logout();
      return null;
    }
  }

  void _triggerSync() {
    // Fire and forget
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sync();
      } catch (e) {
        print('Background sync failed: \$e');
      }
    });
  }

  Future<void> register({
    required String email,
    required String handle,
    required String displayName,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        email: email,
        handle: handle,
        displayName: displayName,
        password: password,
      );
      _triggerSync();
      return user;
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      _triggerSync();
      return user;
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}
