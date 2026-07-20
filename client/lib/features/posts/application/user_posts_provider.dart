import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/posts/data/post_repository.dart';
import 'package:scribes/features/posts/domain/post.dart';

part 'user_posts_provider.g.dart';

@riverpod
class UserPosts extends _$UserPosts {
  @override
  Future<List<Post>> build(String userId) async {
    final repo = ref.watch(postRepositoryProvider);
    return repo.listByAuthor(userId);
  }
}
