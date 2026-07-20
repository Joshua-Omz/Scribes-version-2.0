import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/posts/data/post_api.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/posts/domain/post_version.dart';

final postRepositoryProvider = Provider((ref) {
  final api = ref.watch(postApiProvider);
  return PostRepository(api);
});

class PostRepository {
  final PostApi _api;

  PostRepository(this._api);

  Future<Post> getPost(String id) async {
    final data = await _api.getPost(id);
    return Post.fromJson(data);
  }

  Future<List<PostVersion>> getPostVersions(String id) async {
    final data = await _api.getPostVersions(id);
    return data.map((e) => PostVersion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Post>> listMyPosts() async {
    final data = await _api.listMyPosts();
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Post>> listByAuthor(String userId) async {
    final data = await _api.listByAuthor(userId);
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }
}
