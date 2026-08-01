import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';

part 'auth_api.g.dart';

@riverpod
AuthApi authApi(Ref ref) {
  final dio = ref.watch(apiClientProvider);
  return AuthApi(dio);
}

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String handle,
    required String displayName,
    required String password,
    required bool isChurch,
  }) async {
    final response = await _dio.post(Endpoints.register, data: {
      'email': email,
      'handle': handle,
      'display_name': displayName,
      'password': password,
      'is_church': isChurch,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(Endpoints.login, data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    final response = await _dio.post(Endpoints.googleLogin, data: {
      'id_token': idToken,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get(Endpoints.me);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    required String handle,
    required String displayName,
    String? bio,
    bool isChurch = false,
  }) async {
    final response = await _dio.patch(Endpoints.me, data: {
      'handle': handle,
      'display_name': displayName,
      'bio': bio,
      'is_church': isChurch,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTags(List<String> tags) async {
    final response = await _dio.put(Endpoints.meTags, data: {
      'tags': tags,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    await _dio.patch(Endpoints.updateEmail, data: {
      'new_email': newEmail,
      'current_password': currentPassword,
    });
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.patch(Endpoints.updatePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<Map<String, dynamic>> getNotificationPreferences() async {
    final response = await _dio.get(Endpoints.notificationPreferences);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateNotificationPreferences({
    required bool pushEnabled,
    required bool emailEnabled,
    required bool dmAlerts,
    required bool newFollowerAlerts,
  }) async {
    final response = await _dio.patch(Endpoints.notificationPreferences, data: {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'dm_alerts': dmAlerts,
      'new_follower_alerts': newFollowerAlerts,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSuggestedUsers({int limit = 10}) async {
    final response = await _dio.get(Endpoints.suggestedUsers, queryParameters: {
      'limit': limit,
    });
    return response.data as List<dynamic>;
  }
}
