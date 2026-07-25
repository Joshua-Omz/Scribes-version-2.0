import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/auth/domain/user.dart';
import 'package:scribes/features/social/data/social_repository.dart';

final followersProvider = FutureProvider.family<List<User>, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowers(userId);
});

final followingProvider = FutureProvider.family<List<User>, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowing(userId);
});
