import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/post.dart';
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
      final apiPosts = await repo.getMyPosts();
      
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
                scriptureTags: Value(jsonEncode(post.scriptureTags)),
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
      return Post(
        id: row.id,
        authorId: row.authorId,
        authorHandle: row.authorHandle,
        authorName: row.authorName,
        content: jsonDecode(row.content),
        caption: row.caption,
        visibility: row.visibility,
        currentVersion: row.currentVersion,
        isCorrection: row.isCorrection,
        correctsPostId: row.correctsPostId,
        sermonSource: row.sermonSource != null ? jsonDecode(row.sermonSource!) : null,
        scriptureTags: row.scriptureTags != null ? List<String>.from(jsonDecode(row.scriptureTags!)) : [],
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
