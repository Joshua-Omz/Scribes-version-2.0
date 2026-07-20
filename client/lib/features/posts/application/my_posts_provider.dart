import 'dart:async';
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

  Future<List<Post>> _fetchMyPosts() async {
    final db = ref.watch(databaseProvider);
    final user = ref.watch(authProvider).value;
    if (user == null) return [];

    try {
      final repo = ref.read(postRepositoryProvider);
      final apiPosts = await repo.listMyPosts();
      
      if (apiPosts.isNotEmpty) {
        await db.batch((batch) {
          for (final post in apiPosts) {
            batch.insert(
              db.posts,
              PostsCompanion(
                id: Value(post.id),
                authorId: Value(post.authorId),
                authorHandle: Value(post.authorHandle),
                authorName: Value(post.authorName),
                content: Value(jsonEncode(post.content)),
                caption: Value(post.caption),
                visibility: Value(post.visibility),
                currentVersion: Value(post.currentVersion),
                isCorrection: Value(post.isCorrection),
                correctsPostId: Value(post.correctsPostId),
                sermonSource: Value(post.sermonSource != null ? jsonEncode(post.sermonSource!.toJson()) : null),
                scriptureTags: Value(jsonEncode(post.scriptureRefs.map((r) => r.toJson()).toList())),
                isDeleted: Value(post.isDeleted),
                publishedAt: Value(post.publishedAt),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      // Ignore API errors, fallback to local DB
      print("Error fetching my posts from API: $e");
    }

    final localPosts = await (db.select(db.posts)..where((t) => t.authorId.equals(user.id))).get();
    
    return localPosts.map((row) {
      Map<String, dynamic> decodedContent = {'title': 'Untitled', 'body': '', 'excerpt': ''};
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
            decodedRefs = decoded.map((e) => ScriptureRef.fromJson(e as Map<String, dynamic>)).toList();
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
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchMyPosts());
  }
}
