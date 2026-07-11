import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage.dart';
import 'api_exception.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:8080';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        String message = 'An unexpected error occurred';
        if (e.response != null && e.response?.data is Map<String, dynamic>) {
          print('API ERROR DATA: ${e.response?.data}');
          final data = e.response!.data as Map<String, dynamic>;
          if (data.containsKey('error')) {
            message = data['error'];
          }
        } else if (e.response != null) {
          print('API RAW ERROR: ${e.response?.statusCode} ${e.response?.data}');
          if (e.response!.statusCode == 404) {
             message = 'Endpoint not found or resource does not exist (404)';
          } else {
             message = 'Server returned ${e.response!.statusCode}: ${e.response?.data}';
          }
        } else if (e.type == DioExceptionType.connectionTimeout) {
          message = 'Connection timed out';
        } else if (e.message != null) {
          message = e.message!;
        }

        return handler.next(
          DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: ApiException(message, e.response?.statusCode),
          ),
        );
      },
    ),
  );

  return dio;
}
