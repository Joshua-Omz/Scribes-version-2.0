import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/paginated_feed.dart';
import 'feed_api.dart';
import '../../../core/network/api_client.dart';

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  return FeedRepository(FeedApi(dio), db);
});

class FeedRepository {
  final FeedApi _api;
  final ScribesDatabase _db;

  FeedRepository(this._api, this._db);

  Future<PaginatedFeed> getFeed({String? cursor}) async {
    try {
      final rawData = await _api.getFeed(cursor: cursor);
      _cachePosts(rawData['posts']);
      return _mapPaginatedFeed(rawData);
    } catch (e) {
      // If network fails, serve from local DB
      final records =
          await (_db.select(_db.posts)
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.publishedAt,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(40))
              .get();

      final posts = records.map(_mapRecordToMap).toList();
      return PaginatedFeed.fromJson({
        'posts': posts,
        'next_cursor': null, // No pagination offline
      });
    }
  }

  Future<PaginatedFeed> getFollowingFeed({String? cursor}) async {
    try {
      final rawData = await _api.getFollowingFeed(cursor: cursor);
      _cachePosts(rawData['posts']);
      return _mapPaginatedFeed(rawData);
    } catch (e) {
      // Offline fallback: serve local posts as well
      final records =
          await (_db.select(_db.posts)
                ..orderBy([
                  (t) => OrderingTerm(
                    expression: t.publishedAt,
                    mode: OrderingMode.desc,
                  ),
                ])
                ..limit(40))
              .get();

      final posts = records.map(_mapRecordToMap).toList();
      return PaginatedFeed.fromJson({
        'posts': posts,
        'next_cursor': null,
      });
    }
  }

  Future<PaginatedFeed> getChurchPosts({String? cursor}) async {
    try {
      final rawData = await _api.getChurchPosts(cursor: cursor);
      _cachePosts(rawData['posts']);
      return _mapPaginatedFeed(rawData);
    } catch (e) {
      return PaginatedFeed.fromJson({'posts': [], 'next_cursor': null});
    }
  }

  Future<PaginatedFeed> getForYouPosts({String? cursor}) async {
    try {
      final rawData = await _api.getForYouPosts(cursor: cursor);
      _cachePosts(rawData['posts']);
      return _mapPaginatedFeed(rawData);
    } catch (e) {
      return PaginatedFeed.fromJson({'posts': [], 'next_cursor': null});
    }
  }

  void _cachePosts(dynamic rawPosts) {
    if (rawPosts is! List) return;
    Future.microtask(() async {
      try {
        await _db.transaction(() async {
          for (final item in rawPosts) {
            if (item is! Map<String, dynamic>) continue;
            final postId = item['id']?.toString();
            if (postId == null || postId.isEmpty) continue;

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
              'excerpt': item['content'] is Map
                  ? item['content']['excerpt']
                  : '',
              '_full_post': item,
            };

            await _db.into(_db.posts).insertOnConflictUpdate(
              PostsCompanion(
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
          }
        });
      } catch (err) {
        // Silent background caching error
      }
    });
  }

  Map<String, dynamic> _mapRecordToMap(Post record) {
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
    };
  }

  PaginatedFeed _mapPaginatedFeed(Map<String, dynamic> data) {
    final posts =
        (data['posts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return PaginatedFeed.fromJson({...data, 'posts': posts});
  }
}
