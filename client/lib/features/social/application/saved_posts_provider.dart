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
