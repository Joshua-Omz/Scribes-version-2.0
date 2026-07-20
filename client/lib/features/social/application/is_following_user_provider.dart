import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';

part 'is_following_user_provider.g.dart';

@riverpod
class IsFollowingUser extends _$IsFollowingUser {
  @override
  Future<bool> build(String userId) async {
    final repo = ref.watch(socialRepositoryProvider);
    return repo.isFollowing(userId);
  }

  Future<void> toggleFollow() async {
    final repo = ref.read(socialRepositoryProvider);
    final currentState = state.value ?? false;
    
    // Optimistic update
    state = AsyncData(!currentState);

    try {
      if (currentState) {
        await repo.unfollowUser(userId);
      } else {
        await repo.followUser(userId);
      }
    } catch (e, st) {
      // Revert on error
      state = AsyncError(e, st);
    }
  }
}
