import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/secure_storage.dart';
import '../domain/user.dart';
import 'auth_api.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final api = ref.watch(authApiProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(api, storage);
}

class AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepository(this._api, this._storage);

  Future<User> register({
    required String email,
    required String handle,
    required String displayName,
    required String password,
  }) async {
    final response = await _api.register(
      email: email,
      handle: handle,
      displayName: displayName,
      password: password,
    );

    final token = response['token'] as String;
    await _storage.saveToken(token);

    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.login(
      email: email,
      password: password,
    );

    final token = response['token'] as String;
    await _storage.saveToken(token);

    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> hasToken() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
