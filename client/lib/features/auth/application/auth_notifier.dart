import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';

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
    
    // In a real app, you might want to fetch the user profile here using the token
    // For now, if we have a token, we assume we're authenticated, but we don't 
    // have the User object unless we parse the JWT or hit a /me endpoint.
    // For v1, returning a dummy user or just null since the token exists.
    // Actually, let's just leave it null if we don't have a /me endpoint yet, 
    // but the state needs to know we are logged in.
    // Let's create a minimal user since we know we're logged in.
    return User(
      id: 'stored-token-user', 
      email: '', 
      handle: '', 
      displayName: '', 
      createdAt: DateTime.now()
    );
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
      return await repo.register(
        email: email,
        handle: handle,
        displayName: displayName,
        password: password,
      );
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return await repo.login(email: email, password: password);
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}
