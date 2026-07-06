
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

@riverpod
SecureStorage secureStorage(Ref ref) {
  return SecureStorage();
}

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage() : _storage = const FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static const _topicsKey = 'onboarding_topics';

  Future<void> saveTopics(List<String> topics) async {
    await _storage.write(key: _topicsKey, value: topics.join(','));
  }

  Future<List<String>?> getTopics() async {
    final value = await _storage.read(key: _topicsKey);
    if (value == null || value.isEmpty) return null;
    return value.split(',');
  }
}
