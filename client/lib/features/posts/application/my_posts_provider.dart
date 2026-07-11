import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/post_repository.dart';
import '../domain/post.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/storage/drift_database.dart';
import 'dart:convert';
import 'package:drift/drift.dart';

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
        scriptureTags: row.scriptureTags != null ? List<String>.from(jsonDecode(row.scriptureTags!)) : null,
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
