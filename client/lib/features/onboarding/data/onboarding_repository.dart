import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/core/network/api_client.dart';
import 'package:scribes/core/storage/secure_storage.dart';
import 'onboarding_api.dart';

part 'onboarding_repository.g.dart';

@riverpod
OnboardingRepository onboardingRepository(Ref ref) {
  final api = OnboardingApi(ref.watch(apiClientProvider));
  final storage = ref.watch(secureStorageProvider);
  return OnboardingRepository(api, storage);
}

class OnboardingRepository {
  final OnboardingApi _api;
  final SecureStorage _storage;

  OnboardingRepository(this._api, this._storage);

  Future<List<String>> getAvailableTopics() async {
    return _api.getAvailableTopics();
  }

  Future<void> saveTopics(List<String> topics) async {
    await _api.saveUserTopics(topics);
    await _storage.saveTopics(topics);
  }

  Future<List<String>?> getSavedTopics() async {
    return _storage.getTopics();
  }
}
