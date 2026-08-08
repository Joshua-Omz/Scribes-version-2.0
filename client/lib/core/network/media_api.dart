import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_client.dart';
import 'endpoints.dart';
import 'api_exception.dart';

part 'media_api.g.dart';

@riverpod
MediaApi mediaApi(Ref ref) {
  return MediaApi(ref.watch(apiClientProvider));
}

class MediaApi {
  final Dio _apiClient;
  
  // Create a separate Dio instance without interceptors for direct R2 uploads
  final Dio _uploadClient = Dio();

  MediaApi(this._apiClient);

  Future<String> uploadImage(File file, String mimeType) async {
    try {
      final sizeBytes = await file.length();
      
      // 1. Get presigned URL
      final presignRes = await _apiClient.post(
        Endpoints.mediaUploadPresign,
        data: {
          'mime_type': mimeType,
          'size_bytes': sizeBytes,
        },
      );

      final uploadUrl = presignRes.data['upload_url'] as String;
      final fileUrl = presignRes.data['file_url'] as String;
      final uploadId = presignRes.data['upload_id'] as String;

      // 2. Upload file directly to R2
      final bytes = await file.readAsBytes();
      final uploadRes = await _uploadClient.put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': mimeType,
            'Content-Length': sizeBytes,
          },
        ),
      );

      if (uploadRes.statusCode != 200) {
         throw ApiException('Failed to upload image to storage', uploadRes.statusCode);
      }

      // 3. Confirm upload with backend
      await _apiClient.post(
        Endpoints.mediaUploadConfirm,
        data: {
          'upload_id': uploadId,
        },
      );

      return fileUrl;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw ApiException(e.message ?? 'Upload failed', e.response?.statusCode);
    } catch (e) {
      throw ApiException('Upload failed: $e');
    }
  }
}
