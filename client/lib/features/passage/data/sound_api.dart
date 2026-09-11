import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../domain/passage_models.dart';

part 'sound_api.g.dart';

@riverpod
SoundApi soundApi(Ref ref) {
  return SoundApi(ref.watch(apiClientProvider));
}

class SoundApi {
  final Dio _dio;

  SoundApi(this._dio);

  Future<List<SoundTrack>> listSounds() async {
    final response = await _dio.get(Endpoints.sounds);
    if (response.data is List) {
      return (response.data as List)
          .map((item) => SoundTrack.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
