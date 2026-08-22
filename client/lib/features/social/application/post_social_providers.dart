import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/social/data/social_repository.dart';
import 'package:scribes/features/social/domain/reaction_count.dart';
import 'package:scribes/features/social/domain/comment.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:uuid/uuid.dart';

part 'post_social_providers.g.dart';

class PostReactionsState {
  final List<ReactionCount> counts;
  final String? userReaction;
  final bool modifiedReaction;
  PostReactionsState({
    required this.counts,
    this.userReaction,
    this.modifiedReaction = false,
  });
}

@riverpod
class PostReactionsNotifier extends _$PostReactionsNotifier {
  @override
  Future<PostReactionsState> build(String postId) async {
    // Do NOT fetch immediately to prevent N+1 issues in feeds.
    // Reactions will be fetched explicitly by the detail screen or updated optimistically.
    return PostReactionsState(counts: []);
  }

  Future<void> fetch() async {
    final repo = ref.read(socialRepositoryProvider);
    try {
      final counts = await repo.getReactions(postId);
      final currentState = state.value;
      state = AsyncData(
        PostReactionsState(
          counts: counts,
          userReaction: currentState?.userReaction,
          modifiedReaction: currentState?.modifiedReaction ?? false,
        ),
      );
    } catch (e) {
      debugPrint('[PostReactionsNotifier] Reactions fetch failed: $e');
    }
  }

  Future<void> react(
    String type, {
    int? initialAmenCount,
    int? initialInsightCount,
    int? initialThoughtProvokingCount,
    String? knownUserReaction,
  }) async {
    final repo = ref.read(socialRepositoryProvider);

    final currentState = state.value;
    final currentUserReaction = currentState?.modifiedReaction == true
        ? currentState?.userReaction
        : knownUserReaction;

    final isRemoving = currentUserReaction == type;

    // --- OPTIMISTIC UPDATE ---
    List<ReactionCount> currentCounts = currentState?.counts ?? [];
    if (currentCounts.isEmpty) {
      if (initialAmenCount != null) {
        currentCounts.add(ReactionCount(type: 'amen', count: initialAmenCount));
      }
      if (initialInsightCount != null) {
        currentCounts.add(
          ReactionCount(type: 'insightful', count: initialInsightCount),
        );
      }
      if (initialThoughtProvokingCount != null) {
        currentCounts.add(
          ReactionCount(
            type: 'thought_provoking',
            count: initialThoughtProvokingCount,
          ),
        );
      }
    }

    if (isRemoving) {
      final newCounts = List<ReactionCount>.from(currentCounts);
      final idx = newCounts.indexWhere((c) => c.type == type);
      if (idx >= 0) {
        newCounts[idx] = ReactionCount(
          type: type,
          count: (newCounts[idx].count - 1).clamp(0, 999999),
        );
      }
      state = AsyncData(
        PostReactionsState(
          counts: newCounts,
          userReaction: null,
          modifiedReaction: true,
        ),
      );
    } else {
      final newCounts = List<ReactionCount>.from(currentCounts);

      if (currentUserReaction != null) {
        final oldIdx = newCounts.indexWhere(
          (c) => c.type == currentUserReaction,
        );
        if (oldIdx >= 0) {
          newCounts[oldIdx] = ReactionCount(
            type: currentUserReaction,
            count: (newCounts[oldIdx].count - 1).clamp(0, 999999),
          );
        }
      }

      final newIdx = newCounts.indexWhere((c) => c.type == type);
      if (newIdx >= 0) {
        newCounts[newIdx] = ReactionCount(
          type: type,
          count: newCounts[newIdx].count + 1,
        );
      } else {
        newCounts.add(ReactionCount(type: type, count: 1));
      }
      state = AsyncData(
        PostReactionsState(
          counts: newCounts,
          userReaction: type,
          modifiedReaction: true,
        ),
      );
    }

    // --- NETWORK CALL ---
    try {
      if (isRemoving) {
        await repo.unreact(postId);
      } else {
        await repo.react(postId, type);
      }

      // Fetch from server to sync
      await fetch();
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
      debugPrint('[PostCommentsNotifier] Comments fetch failed: $e');
      return [];
    }
  }

  Future<void> addComment(String body, List<String> mentions) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    final tempId = 'temp-${const Uuid().v4()}';
    final tempComment = Comment(
      id: tempId,
      postId: postId,
      authorId: user.id,
      body: body,
      mentions: mentions,
      createdAt: DateTime.now(),
      isHidden: false,
      isDeleted: false,
    );

    // Optimistic Add
    if (state.value != null) {
      state = AsyncData([...state.value!, tempComment]);
    }

    // Background Network Call
    _addCommentInBackground(body, mentions, tempId);
  }

  Future<void> _addCommentInBackground(
    String body,
    List<String> mentions,
    String tempId,
  ) async {
    final repo = ref.read(socialRepositoryProvider);
    int attempts = 0;
    while (attempts < 3) {
      try {
        await repo.addComment(postId, body, mentions);
        // Refresh to get actual comment ID from server
        final freshComments = await repo.getComments(postId);
        if (state.value != null) {
          state = AsyncData(freshComments);
        }
        return;
      } catch (e) {
        attempts++;
        if (attempts >= 3) {
          debugPrint(
            '[PostCommentsNotifier] Failed to add comment after retries: $e',
          );
          // Revert optimistic add
          if (state.value != null) {
            state = AsyncData(
              state.value!.where((c) => c.id != tempId).toList(),
            );
          }
          return;
        }
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
  }

  Future<void> hideComment(String commentId) async {
    if (state.value != null) {
      final currentList = state.value!;
      final idx = currentList.indexWhere((c) => c.id == commentId);
      if (idx >= 0) {
        final updatedList = List<Comment>.from(currentList);
        updatedList[idx] = updatedList[idx].copyWith(isHidden: true);
        state = AsyncData(updatedList);
      }
    }

    final repo = ref.read(socialRepositoryProvider);
    try {
      await repo.hideComment(commentId);
    } catch (e) {
      debugPrint('[PostCommentsNotifier] hide failed: $e');
      // Silently fail for now
    }
  }

  Future<void> deleteComment(String commentId) async {
    if (state.value != null) {
      state = AsyncData(state.value!.where((c) => c.id != commentId).toList());
    }

    _deleteCommentInBackground(commentId);
  }

  Future<void> _deleteCommentInBackground(String commentId) async {
    final repo = ref.read(socialRepositoryProvider);
    int attempts = 0;
    while (attempts < 3) {
      try {
        await repo.deleteComment(commentId);
        return;
      } catch (e) {
        attempts++;
        if (attempts >= 3) {
          debugPrint(
            '[PostCommentsNotifier] Failed to delete comment after retries: $e',
          );
          return;
        }
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
  }
}
