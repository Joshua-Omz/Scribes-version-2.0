import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  }) async {
    final response = await _dio.post(Endpoints.register, data: {
      'email': email,
      'handle': handle,
      'display_name': displayName,
      'password': password,
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
}
