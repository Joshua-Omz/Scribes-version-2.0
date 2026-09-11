import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';

part 'saved_posts_provider.g.dart';

@riverpod
class SavedPosts extends _$SavedPosts {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.watch(socialRepositoryProvider);
    return repo.getSavedPosts();
  }

  Future<void> savePost(String postId) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.savePost(postId);
    ref.invalidateSelf();
  }

  Future<void> unsavePost(String postId) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.unsavePost(postId);
    ref.invalidateSelf();
  }
}

/// Memoized set of saved post IDs for O(1) membership lookups in feed cards.
final savedPostIdsProvider = Provider<Set<String>>((ref) {
  final savedState = ref.watch(savedPostsProvider);
  final list = savedState.value;
  if (list == null) return const <String>{};
  return list
      .map((p) => (p['id'] ?? p['post_id'])?.toString())
      .whereType<String>()
      .toSet();
});
