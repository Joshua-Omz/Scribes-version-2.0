import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/posts/data/post_repository.dart';
import 'package:scribes/features/posts/application/post_detail_provider.dart';

part 'revise_post_provider.g.dart';

@riverpod
class RevisePostNotifier extends _$RevisePostNotifier {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<void> revisePost(String id, Map<String, dynamic> content, String? caption, List<String>? tags) async {
    state = const AsyncLoading();
    try {
      final postRepo = ref.read(postRepositoryProvider);
      await postRepo.revisePost(id, content, caption, tags);
      
      // Invalidate the post detail so it fetches the new version
      ref.invalidate(postDetailProvider(id));
      
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
