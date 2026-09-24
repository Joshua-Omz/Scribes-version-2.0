import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/posts/data/post_api.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/posts/domain/post_version.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart' as db;

final postRepositoryProvider = Provider((ref) {
  final api = ref.watch(postApiProvider);
  final database = ref.watch(databaseProvider);
  return PostRepository(api, database);
});

class PostRepository {
  final PostApi _api;
  final db.ScribesDatabase _db;

  PostRepository(this._api, this._db);

  Future<Post> createPost(Map<String, dynamic> data) async {
    final res = await _api.createPost(data);
    _cacheSinglePost(res);
    return Post.fromJson(res);
  }

  Future<Post> getPost(String id) async {
    // 1. Check local cache first so UI renders immediately without network request
    db.Post? record;
    try {
      record = await (_db.select(_db.posts)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (record != null) {
        final mapped = _mapRecordToMap(record);
        final cachedPost = Post.fromJson(mapped);

        // INVARIANT: Prevent shallow cache poisoning for passage posts.
        // If it's a passage post but panels were never hydrated, do NOT treat this as a complete cache hit.
        final isShallowPassage =
            cachedPost.postType == 'passage' && cachedPost.panels.isEmpty;

        if (!isShallowPassage) {
          // Revalidate in background
          _revalidatePostInBackground(id);
          return cachedPost;
        }
      }
    } catch (_) {}

    // 2. Fall back to network
    try {
      final data = await _api.getPost(id);
      final post = Post.fromJson(data);

      // 3. Cache retrieved post
      _cacheSinglePost(data);

      return post;
    } catch (e) {
      // 4. True offline fallback: if network fails and we had a cached record (even shallow),
      // return what we have rather than crashing.
      if (record != null) {
        return Post.fromJson(_mapRecordToMap(record));
      }
      rethrow;
    }
  }

  void _revalidatePostInBackground(String id) {
    Future.microtask(() async {
      try {
        final data = await _api.getPost(id);
        _cacheSinglePost(data);
      } catch (_) {}
    });
  }

  void _cacheSinglePost(Map<String, dynamic> item) {
    Future.microtask(() async {
      try {
        final postId = item['id']?.toString();
        if (postId == null || postId.isEmpty) return;

        final authorId = item['author_id']?.toString() ?? '';
        final authorHandle = item['author_handle']?.toString() ?? '';
        final authorName = item['author_name']?.toString() ?? '';
        final caption = item['caption']?.toString();
        final visibility = item['visibility']?.toString() ?? 'public';
        final currentVersion = item['current_version'] is int
            ? item['current_version'] as int
            : 1;
        final isCorrection = item['is_correction'] == true;
        final correctsPostId = item['corrects_post_id']?.toString();
        final isDeleted = item['is_deleted'] == true;
        final coverImageUrl = item['cover_image_url']?.toString();
        final postType = item['post_type']?.toString() ?? 'standard';
        final publishedAt =
            DateTime.tryParse(item['published_at']?.toString() ?? '') ??
            DateTime.now();

        final contentPayload = {
          'body': item['content'] is Map
              ? item['content']['body']
              : item['content'],
          'title': item['content'] is Map ? item['content']['title'] : '',
          'excerpt': item['content'] is Map ? item['content']['excerpt'] : '',
          'reflection_image_url': item['reflection_image_url'],
          'sound_id': item['sound_id'],
          'sound': item['sound'],
          'panels': item['panels'],
          '_full_post': item,
        };

        await _db.into(_db.posts).insertOnConflictUpdate(
          db.PostsCompanion(
            id: Value(postId),
            authorId: Value(authorId),
            authorHandle: Value(authorHandle),
            authorName: Value(authorName),
            content: Value(jsonEncode(contentPayload)),
            caption: Value(caption),
            visibility: Value(visibility),
            currentVersion: Value(currentVersion),
            isCorrection: Value(isCorrection),
            correctsPostId: Value(correctsPostId),
            sermonSource: Value(
              item['sermon_source'] != null
                  ? jsonEncode(item['sermon_source'])
                  : null,
            ),
            scriptureTags: Value(
              item['scripture_tags'] != null
                  ? jsonEncode(item['scripture_tags'])
                  : null,
            ),
            isDeleted: Value(isDeleted),
            coverImageUrl: Value(coverImageUrl),
            postType: Value(postType),
            publishedAt: Value(publishedAt),
          ),
        );
      } catch (_) {}
    });
  }

  Map<String, dynamic> _mapRecordToMap(db.Post record) {
    dynamic contentDecoded;
    try {
      contentDecoded = jsonDecode(record.content);
    } catch (_) {
      contentDecoded = {'body': [], 'excerpt': '', 'title': 'Untitled'};
    }

    if (contentDecoded is Map && contentDecoded['_full_post'] is Map) {
      return Map<String, dynamic>.from(contentDecoded['_full_post']);
    }

    dynamic sermonDecoded;
    if (record.sermonSource != null) {
      try {
        sermonDecoded = jsonDecode(record.sermonSource!);
      } catch (_) {}
    }

    dynamic scriptureDecoded;
    if (record.scriptureTags != null) {
      try {
        scriptureDecoded = jsonDecode(record.scriptureTags!);
      } catch (_) {}
    }

    return {
      'id': record.id,
      'author_id': record.authorId,
      'author_handle': record.authorHandle,
      'author_name': record.authorName,
      'content': contentDecoded,
      'caption': record.caption,
      'visibility': record.visibility,
      'current_version': record.currentVersion,
      'is_correction': record.isCorrection,
      'corrects_post_id': record.correctsPostId,
      'sermon_source': sermonDecoded,
      'scripture_tags': scriptureDecoded ?? [],
      'is_deleted': record.isDeleted,
      'cover_image_url': record.coverImageUrl,
      'post_type': record.postType,
      'published_at': record.publishedAt.toIso8601String(),
      'reflection_image_url': contentDecoded is Map
          ? contentDecoded['reflection_image_url']
          : null,
      'panels': contentDecoded is Map && contentDecoded['panels'] is List
          ? contentDecoded['panels']
          : [],
      'sound': contentDecoded is Map ? contentDecoded['sound'] : null,
      'sound_id': contentDecoded is Map ? contentDecoded['sound_id'] : null,
    };
  }

  Future<List<PostVersion>> getPostVersions(String id) async {
    final data = await _api.getPostVersions(id);
    return data
        .map((e) => PostVersion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Post>> listMyPosts() async {
    final data = await _api.listMyPosts();
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Post>> listByAuthor(String userId) async {
    final data = await _api.listByAuthor(userId);
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> deletePost(String id) async {
    await _api.deletePost(id);
  }

  Future<Post> revisePost(
    String id,
    Map<String, dynamic> content,
    String? caption,
    List<String>? tags,
  ) async {
    final payload = {
      'content': content,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      'tags': ?tags,
    };
    final data = await _api.revisePost(id, payload);
    return Post.fromJson(data);
  }

  Future<List<Post>> getSimilarPosts(String id) async {
    final data = await _api.getSimilarPosts(id);
    return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> exportPost(String id, String format) async {
    return _api.exportPost(id, format);
  }
}
