import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/posts/data/post_repository.dart';
import 'package:scribes/features/posts/application/post_detail_state.dart';
import 'package:scribes/features/posts/application/my_posts_provider.dart';
import 'package:scribes/features/posts/application/user_posts_provider.dart';

import 'package:scribes/features/posts/domain/post.dart';
part 'post_detail_provider.g.dart';

@riverpod
class PostDetailNotifier extends _$PostDetailNotifier {
  @override
  Future<PostDetailState> build(String postId) async {
    final postRepo = ref.watch(postRepositoryProvider);
    final post = await postRepo.getPost(postId);

    return PostDetailState(post: post);
  }

  Future<void> loadVersions() async {
    if (state.value == null) return;
    
    final postRepo = ref.read(postRepositoryProvider);
    final versions = await postRepo.getPostVersions(postId);
    
    state = AsyncData(state.value!.copyWith(versions: versions));
  }

  void optimisticDeletePost() {
    // 1. Optimistic removal from feeds
    ref.read(myPostsProvider.notifier).optimisticRemove(postId);

    if (state.value?.post != null) {
      ref.read(userPostsProvider(state.value!.post.authorId).notifier).optimisticRemove(postId);
    }

    // 2. Fire background network call with silent retry
    _deleteInBackground();
  }

  Future<void> _deleteInBackground() async {
    final postRepo = ref.read(postRepositoryProvider);
    int attempts = 0;
    while (attempts < 3) {
      try {
        await postRepo.deletePost(postId);
        return; // Success
      } catch (e) {
        attempts++;
        if (attempts >= 3) {
          print('[PostDetailNotifier] Failed to delete post in background after 3 attempts: $e');
          // In a full production app, we would revert the optimistic state here,
          // but per user request, we silently retry and then stop on ultimate failure.
          return;
        }
        await Future.delayed(Duration(seconds: 2 * attempts)); // Backoff
      }
    }
  }
}

@riverpod
Future<List<Post>> similarPosts(Ref ref, String postId) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getSimilarPosts(postId);
}
