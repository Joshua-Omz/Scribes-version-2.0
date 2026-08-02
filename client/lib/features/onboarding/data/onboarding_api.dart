import 'package:dio/dio.dart';
import 'package:scribes/core/network/api_exception.dart';

class OnboardingApi {
  // ignore: unused_field
  final Dio _client;

  OnboardingApi(this._client);

  Future<List<String>> getAvailableTopics() async {
    try {
      final response = await _client.get('/tags/trending');
      final data = response.data as List<dynamic>?;
      if (data == null || data.isEmpty) {
        // Fallback if db is empty
        return [
          'Theology', 'Scripture Study', 'Sermons', 'Devotionals', 
          'Christian Living', 'Church History', 'Apologetics', 
          'Prayer', 'Ministry', 'Worship', 'Discipleship', 'Missions'
        ];
      }
      return data.map((e) => e['name'].toString()).toList();
    } on DioException {
      // Return fallback on failure
      return [
        'Theology', 'Scripture Study', 'Sermons', 'Devotionals', 
        'Christian Living', 'Church History', 'Apologetics', 
        'Prayer', 'Ministry', 'Worship', 'Discipleship', 'Missions'
      ];
    }
  }

  Future<void> saveUserTopics(List<String> topics) async {
    if (topics.isEmpty) {
      throw ApiException('At least one topic must be selected');
    }
    
    try {
      await _client.put('/me/tags', data: {'tags': topics});
    } on DioException catch (e) {
      throw ApiException(e.response?.data?['error'] ?? e.message ?? 'Unknown error');
    }
  }
}
