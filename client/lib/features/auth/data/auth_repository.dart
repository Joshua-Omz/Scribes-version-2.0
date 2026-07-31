import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/secure_storage.dart';
import '../../settings/domain/notification_preferences.dart';
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

  Future<User> loginWithGoogle(String idToken) async {
    final response = await _api.loginWithGoogle(idToken);

    final token = response['token'] as String;
    await _storage.saveToken(token);

    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<User> getMe() async {
    final response = await _api.getMe();
    return User.fromJson(response);
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> hasToken() async {
    final token = await _storage.getToken();
    return token != null;
  }

  Future<User> updateProfile({
    required String handle,
    required String displayName,
    String? bio,
    bool isChurch = false,
  }) async {
    final response = await _api.updateProfile(
      handle: handle,
      displayName: displayName,
      bio: bio,
      isChurch: isChurch,
    );
    return User.fromJson(response);
  }

  Future<User> updateTags(List<String> tags) async {
    final response = await _api.updateTags(tags);
    return User.fromJson(response);
  }

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    await _api.updateEmail(
      newEmail: newEmail,
      currentPassword: currentPassword,
    );
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<NotificationPreferences> getNotificationPreferences() async {
    final response = await _api.getNotificationPreferences();
    return NotificationPreferences.fromJson(response);
  }

  Future<NotificationPreferences> updateNotificationPreferences(
      NotificationPreferences preferences) async {
    final response = await _api.updateNotificationPreferences(
      pushEnabled: preferences.pushEnabled,
      emailEnabled: preferences.emailEnabled,
      dmAlerts: preferences.dmAlerts,
      newFollowerAlerts: preferences.newFollowerAlerts,
    );
    return NotificationPreferences.fromJson(response);
  }

  Future<List<User>> getSuggestedUsers({int limit = 10}) async {
    final response = await _api.getSuggestedUsers(limit: limit);
    return response.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }
}
