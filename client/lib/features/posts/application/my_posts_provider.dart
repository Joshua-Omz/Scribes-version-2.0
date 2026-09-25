import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/post.dart';
import '../domain/sermon_source.dart';
import '../domain/scripture_ref.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart' hide Post;
import '../data/post_repository.dart';
import 'package:drift/drift.dart';
import 'dart:convert';

final myPostsProvider = AsyncNotifierProvider<MyPostsNotifier, List<Post>>(() {
  return MyPostsNotifier();
});

class MyPostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  FutureOr<List<Post>> build() async {
    return _fetchMyPosts();
  }

  /// Primary ground truth: Remote API.
  /// Falls back to local SQLite DB only when offline/network error occurs.
  Future<List<Post>> _fetchMyPosts() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];

    try {
      final repo = ref.read(postRepositoryProvider);
      final apiPosts = await repo.listMyPosts();

      final activePosts = apiPosts.where((p) => !p.isDeleted).toList();

      // Synchronize SQLite cache in background for offline durability
      unawaited(_syncLocalDb(activePosts, user.id));

      // Return remote ground truth directly — no reliance on stale local DB
      return activePosts;
    } catch (e) {
      debugPrint("[MyPostsNotifier] API unavailable ($e). Falling back to local cache.");
      return _getCachedPosts(user.id);
    }
  }

List<Map<String, dynamic>> _prepareMyPostsForCache(List<Post> activePosts) {
  return activePosts.map((post) {
    return {
      'id': post.id,
      'authorId': post.authorId,
      'authorHandle': post.authorHandle,
      'authorName': post.authorName,
      'content': jsonEncode(post.content),
      'caption': post.caption,
      'visibility': post.visibility,
      'currentVersion': post.currentVersion,
      'isCorrection': post.isCorrection,
      'correctsPostId': post.correctsPostId,
      'sermonSource': post.sermonSource != null ? jsonEncode(post.sermonSource!.toJson()) : null,
      'scriptureTags': jsonEncode(post.scriptureRefs.map((r) => r.toJson()).toList()),
      'isDeleted': post.isDeleted,
      'publishedAt': post.publishedAt.millisecondsSinceEpoch,
    };
  }).toList();
}

  Future<void> _syncLocalDb(List<Post> activePosts, String userId) async {
    try {
      final db = ref.read(databaseProvider);
      final activeIds = activePosts.map((p) => p.id).toSet();

      // Prune deleted or unlisted posts from local database
      await (db.delete(db.posts)
            ..where((t) => t.authorId.equals(userId) & t.id.isNotIn(activeIds)))
          .go();

      // Upsert current active posts
      if (activePosts.isNotEmpty) {
        // Run heavy JSON encoding on background isolate
        final preparedPosts = await compute(_prepareMyPostsForCache, activePosts);

        // Yield back to the event loop before acquiring the database transaction
        await Future.delayed(const Duration(milliseconds: 20));

        await db.batch((batch) {
          for (final postMap in preparedPosts) {
            batch.insert(
              db.posts,
              PostsCompanion(
                id: Value(postMap['id'] as String),
                authorId: Value(postMap['authorId'] as String),
                authorHandle: Value(postMap['authorHandle'] as String),
                authorName: Value(postMap['authorName'] as String),
                content: Value(postMap['content'] as String),
                caption: Value(postMap['caption'] as String?),
                visibility: Value(postMap['visibility'] as String),
                currentVersion: Value(postMap['currentVersion'] as int),
                isCorrection: Value(postMap['isCorrection'] as bool),
                correctsPostId: Value(postMap['correctsPostId'] as String?),
                sermonSource: Value(postMap['sermonSource'] as String?),
                scriptureTags: Value(postMap['scriptureTags'] as String),
                isDeleted: Value(postMap['isDeleted'] as bool),
                publishedAt: Value(DateTime.fromMillisecondsSinceEpoch(postMap['publishedAt'] as int)),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint("[MyPostsNotifier] Error syncing local database: $e");
    }
  }

  Future<List<Post>> _getCachedPosts(String userId) async {
    try {
      final db = ref.read(databaseProvider);
      final localPosts = await (db.select(db.posts)
            ..where((t) => t.authorId.equals(userId) & t.isDeleted.equals(false)))
          .get();

      return localPosts.map((row) {
        Map<String, dynamic> decodedContent = {
          'title': 'Untitled',
          'body': '',
          'excerpt': '',
        };
        try {
          final decoded = jsonDecode(row.content);
          if (decoded is Map<String, dynamic>) {
            decodedContent = decoded;
          }
        } catch (_) {}

        SermonSource? decodedSermon;
        if (row.sermonSource != null) {
          try {
            final decoded = jsonDecode(row.sermonSource!);
            if (decoded is Map<String, dynamic>) {
              decodedSermon = SermonSource.fromJson(decoded);
            }
          } catch (_) {}
        }

        List<ScriptureRef> decodedRefs = [];
        if (row.scriptureTags != null) {
          try {
            final decoded = jsonDecode(row.scriptureTags!);
            if (decoded is List) {
              decodedRefs = decoded
                  .map((e) => ScriptureRef.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          } catch (_) {}
        }

        return Post(
          id: row.id,
          authorId: row.authorId,
          authorHandle: row.authorHandle,
          authorName: row.authorName,
          content: decodedContent,
          caption: row.caption,
          visibility: row.visibility,
          currentVersion: row.currentVersion,
          isCorrection: row.isCorrection,
          correctsPostId: row.correctsPostId,
          sermonSource: decodedSermon,
          scriptureRefs: decodedRefs,
          isDeleted: row.isDeleted,
          publishedAt: row.publishedAt,
        );
      }).toList();
    } catch (e) {
      debugPrint("[MyPostsNotifier] Failed to read local cache: $e");
      return [];
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMyPosts());
  }

  void optimisticRemove(String postId) {
    if (state.value != null) {
      final currentList = state.value!;
      state = AsyncData(currentList.where((p) => p.id != postId).toList());
    }

    // Immediately purge from local SQLite table so it never resurrects
    try {
      final db = ref.read(databaseProvider);
      unawaited(
        (db.delete(db.posts)..where((t) => t.id.equals(postId))).go(),
      );
    } catch (e) {
      debugPrint("[MyPostsNotifier] Failed to purge post $postId from local db: $e");
    }
  }

  Future<void> deletePost(String id) async {
    // 1. Optimistically remove from state & local storage
    optimisticRemove(id);

    // 2. Perform remote deletion
    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.deletePost(id);
    } catch (e) {
      debugPrint("[MyPostsNotifier] Error deleting post: $e");
      // Restore server ground truth if remote request failed
      await refresh();
      throw Exception('Failed to delete post: $e');
    }
  }
}
