import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/social/data/social_api.dart';
import 'package:scribes/features/social/domain/comment.dart';
import 'package:scribes/features/social/domain/reaction_count.dart';


final socialRepositoryProvider = Provider((ref) {
  final api = ref.watch(socialApiProvider);
  return SocialRepository(api);
});

class SocialRepository {
  final SocialApi _api;

  SocialRepository(this._api);

  Future<List<ReactionCount>> getReactions(String postId) async {
    final data = await _api.getReactions(postId);
    return data.map((e) => ReactionCount.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> react(String postId, String type) async {
    await _api.react(postId, type);
  }

  Future<void> unreact(String postId) async {
    await _api.unreact(postId);
  }

  Future<List<Comment>> getComments(String postId) async {
    final data = await _api.getComments(postId);
    return data.map((e) => Comment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Comment> addComment(String postId, String body, List<String> mentions) async {
    final data = await _api.addComment(postId, body, mentions);
    return Comment.fromJson(data);
  }
}
