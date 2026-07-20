import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';
import 'package:scribes/features/social/domain/reaction_count.dart';
import 'package:scribes/features/social/domain/comment.dart';

part 'post_social_providers.g.dart';

class PostReactionsState {
  final List<ReactionCount> counts;
  final String? userReaction;
  final bool modifiedReaction;
  PostReactionsState({required this.counts, this.userReaction, this.modifiedReaction = false});
}

@riverpod
class PostReactionsNotifier extends _$PostReactionsNotifier {
  @override
  Future<PostReactionsState> build(String postId) async {
    final repo = ref.watch(socialRepositoryProvider);
    try {
      final counts = await repo.getReactions(postId);
      return PostReactionsState(counts: counts);
    } catch (e) {
      print('[PostReactionsNotifier] Reactions fetch failed: $e');
      return PostReactionsState(counts: []);
    }
  }

  Future<void> react(String type, {String? knownUserReaction}) async {
    final repo = ref.read(socialRepositoryProvider);
    
    final currentState = state.value;
    final currentUserReaction = currentState?.modifiedReaction == true 
        ? currentState?.userReaction 
        : knownUserReaction;
        
    final isRemoving = currentUserReaction == type;
    
    // --- OPTIMISTIC UPDATE ---
    if (isRemoving) {
      final newCounts = List<ReactionCount>.from(currentState?.counts ?? []);
      final idx = newCounts.indexWhere((c) => c.type == type);
      if (idx >= 0) {
        newCounts[idx] = ReactionCount(type: type, count: (newCounts[idx].count - 1).clamp(0, 999999));
      }
      state = AsyncData(PostReactionsState(counts: newCounts, userReaction: null, modifiedReaction: true));
    } else {
      if (currentState != null) {
        final newCounts = List<ReactionCount>.from(currentState.counts);
        
        if (currentUserReaction != null) {
           final oldIdx = newCounts.indexWhere((c) => c.type == currentUserReaction);
           if (oldIdx >= 0) {
             newCounts[oldIdx] = ReactionCount(type: currentUserReaction, count: (newCounts[oldIdx].count - 1).clamp(0, 999999));
           }
        }
        
        final newIdx = newCounts.indexWhere((c) => c.type == type);
        if (newIdx >= 0) {
          newCounts[newIdx] = ReactionCount(type: type, count: newCounts[newIdx].count + 1);
        } else {
          newCounts.add(ReactionCount(type: type, count: 1));
        }
        state = AsyncData(PostReactionsState(counts: newCounts, userReaction: type, modifiedReaction: true));
      }
    }
    
    // --- NETWORK CALL ---
    try {
      if (isRemoving) {
        await repo.unreact(postId);
      } else {
        await repo.react(postId, type);
      }
      
      // Fetch from server to sync 
      final freshCounts = await repo.getReactions(postId);
      if (state.value != null) {
          state = AsyncData(PostReactionsState(counts: freshCounts, userReaction: state.value!.userReaction, modifiedReaction: state.value!.modifiedReaction));
      }
    } catch (e) {
      // Revert on failure (simplified)
      if (currentState != null) {
        state = AsyncData(currentState);
      }
    }
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
    try {
      final repo = ref.read(socialRepositoryProvider);
      await repo.addComment(postId, body, mentions);
      ref.invalidateSelf();
    } catch (e) {
      print('[PostCommentsNotifier] Failed to add comment: $e');
      if (e is DioException) {
        print('[PostCommentsNotifier] Dio response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<void> hideComment(String commentId) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.hideComment(commentId);
    ref.invalidateSelf();
  }

  Future<void> deleteComment(String commentId) async {
    final repo = ref.read(socialRepositoryProvider);
    await repo.deleteComment(commentId);
    ref.invalidateSelf();
  }
}
