import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';
import 'package:scribes/features/social/domain/reaction_count.dart';
import 'package:scribes/features/social/domain/comment.dart';

part 'post_social_providers.g.dart';

@riverpod
class PostReactionsNotifier extends _$PostReactionsNotifier {
  @override
  Future<List<ReactionCount>> build(String postId) async {
    final repo = ref.watch(socialRepositoryProvider);
    try {
      return await repo.getReactions(postId);
    } catch (e) {
      print('[PostReactionsNotifier] Reactions fetch failed: $e');
      return [];
    }
  }

  Future<void> react(String type) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.react(postId, type);
    ref.invalidateSelf();
  }
}

@riverpod
class PostCommentsNotifier extends _$PostCommentsNotifier {
  @override
  Future<List<Comment>> build(String postId) async {
    final repo = ref.watch(socialRepositoryProvider);
    try {
      return await repo.getComments(postId);
    } catch (e) {
      print('[PostCommentsNotifier] Comments fetch failed: $e');
      return [];
    }
  }

  Future<void> addComment(String body, List<String> mentions) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.addComment(postId, body, mentions);
    ref.invalidateSelf();
  }
}
