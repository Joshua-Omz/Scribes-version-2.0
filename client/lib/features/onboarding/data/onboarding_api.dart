import 'package:dio/dio.dart';
import 'package:scribes/core/network/api_exception.dart';

class OnboardingApi {
  final Dio _client;

  OnboardingApi(this._client);

  /// MOCK IMPLEMENTATION
  /// The backend doesn't currently have a dedicated topics/categories endpoint.
  Future<List<String>> getAvailableTopics() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      'Theology', 'Scripture Study', 'Sermons', 'Devotionals', 
      'Christian Living', 'Church History', 'Apologetics', 
      'Prayer', 'Ministry', 'Worship', 'Discipleship', 'Missions'
    ];
  }

  /// MOCK IMPLEMENTATION
  Future<void> saveUserTopics(List<String> topics) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check for mock failure
    if (topics.isEmpty) {
      throw ApiException('At least one topic must be selected');
    }
    
    // In a real implementation this would be something like:
    // await _client.dio.post('/me/topics', data: {'topics': topics});
  }
}
