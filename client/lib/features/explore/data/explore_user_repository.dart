import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/user.dart';
import '../../social/data/social_api.dart';

final exploreUserRepositoryProvider = Provider<ExploreUserRepository>((ref) {
  final api = ref.watch(socialApiProvider);
  return ExploreUserRepository(api);
});

class ExploreUserRepository {
  final SocialApi _api;

  ExploreUserRepository(this._api);

  Future<List<User>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final results = await _api.searchUsers(query);
    return results.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }
}
