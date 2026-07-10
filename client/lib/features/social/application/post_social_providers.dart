import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';
import 'package:scribes/features/social/domain/reaction_count.dart';
import 'package:scribes/features/social/domain/comment.dart';

part 'post_social_providers.g.dart';

class PostReactionsState {
  final List<ReactionCount> counts;
  final String? userReaction;
  PostReactionsState({required this.counts, this.userReaction});
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

  Future<void> react(String type) async {
    final repo = ref.read(socialRepositoryProvider);
    
    // Toggle reaction if it's the same
    final currentState = state.value;
    final isRemoving = currentState != null && currentState.userReaction == type;
    
    if (isRemoving) {
      await repo.unreact(postId);
      // Optimistic update
      final newCounts = List<ReactionCount>.from(currentState.counts);
      final idx = newCounts.indexWhere((c) => c.type == type);
      if (idx >= 0) {
        newCounts[idx] = ReactionCount(type: type, count: (newCounts[idx].count - 1).clamp(0, 999999));
      }
      state = AsyncData(PostReactionsState(counts: newCounts, userReaction: null));
    } else {
      await repo.react(postId, type);
      // Optimistic update
      if (currentState != null) {
        final newCounts = List<ReactionCount>.from(currentState.counts);
        
        // Remove old reaction count if any
        if (currentState.userReaction != null) {
           final oldIdx = newCounts.indexWhere((c) => c.type == currentState.userReaction);
           if (oldIdx >= 0) {
             newCounts[oldIdx] = ReactionCount(type: currentState.userReaction!, count: (newCounts[oldIdx].count - 1).clamp(0, 999999));
           }
        }
        
        // Add new reaction count
        final newIdx = newCounts.indexWhere((c) => c.type == type);
        if (newIdx >= 0) {
          newCounts[newIdx] = ReactionCount(type: type, count: newCounts[newIdx].count + 1);
        } else {
          newCounts.add(ReactionCount(type: type, count: 1));
        }
        state = AsyncData(PostReactionsState(counts: newCounts, userReaction: type));
      }
    }
    
    // Fetch from server to sync (optional, could just rely on optimistic)
    final freshCounts = await repo.getReactions(postId);
    if (state.value != null) {
        state = AsyncData(PostReactionsState(counts: freshCounts, userReaction: state.value!.userReaction));
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
    final repo = ref.read(socialRepositoryProvider);
    await repo.addComment(postId, body, mentions);
    ref.invalidateSelf();
  }
}
