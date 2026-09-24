import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/paginated_feed.dart';
import 'feed_api.dart';
import '../../../core/network/api_client.dart';

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';

List<Map<String, dynamic>> _preparePostsForCache(List<dynamic> rawPosts) {
  final result = <Map<String, dynamic>>[];
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
    final publishedAtMillis =
        (DateTime.tryParse(item['published_at']?.toString() ?? '') ??
                DateTime.now()).millisecondsSinceEpoch;

    final contentPayload = {
      'body': item['content'] is Map
          ? item['content']['body']
          : item['content'],
      'title': item['content'] is Map ? item['content']['title'] : '',
      'excerpt': item['content'] is Map
          ? item['content']['excerpt']
          : '',
      'reflection_image_url': item['reflection_image_url'],
      'sound_id': item['sound_id'],
      'sound': item['sound'],
      'panels': item['panels'],
      '_full_post': item,
    };

    result.add({
      'id': postId,
      'authorId': authorId,
      'authorHandle': authorHandle,
      'authorName': authorName,
      'content': jsonEncode(contentPayload),
      'caption': caption,
      'visibility': visibility,
      'currentVersion': currentVersion,
      'isCorrection': isCorrection,
      'correctsPostId': correctsPostId,
      'sermonSource': item['sermon_source'] != null ? jsonEncode(item['sermon_source']) : null,
      'scriptureTags': item['scripture_tags'] != null ? jsonEncode(item['scripture_tags']) : null,
      'isDeleted': isDeleted,
      'coverImageUrl': coverImageUrl,
      'postType': postType,
      'publishedAt': publishedAtMillis,
    });
  }
  return result;
}

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
    Future(() async {
      try {
        // 1. Offload heavy JSON parsing/encoding to a background isolate
        final preparedData = await compute(_preparePostsForCache, rawPosts);
        if (preparedData.isEmpty) return;

        // 2. Yield to ensure scrolling frame can paint before DB hit
        await Future.delayed(const Duration(milliseconds: 50));

        // 3. Use Drift batch for fast, single-transaction write
        await _db.batch((batch) {
          final companions = preparedData.map((data) => PostsCompanion(
            id: Value(data['id'] as String),
            authorId: Value(data['authorId'] as String),
            authorHandle: Value(data['authorHandle'] as String),
            authorName: Value(data['authorName'] as String),
            content: Value(data['content'] as String),
            caption: Value(data['caption'] as String?),
            visibility: Value(data['visibility'] as String),
            currentVersion: Value(data['currentVersion'] as int),
            isCorrection: Value(data['isCorrection'] as bool),
            correctsPostId: Value(data['correctsPostId'] as String?),
            sermonSource: Value(data['sermonSource'] as String?),
            scriptureTags: Value(data['scriptureTags'] as String?),
            isDeleted: Value(data['isDeleted'] as bool),
            coverImageUrl: Value(data['coverImageUrl'] as String?),
            postType: Value(data['postType'] as String),
            publishedAt: Value(DateTime.fromMillisecondsSinceEpoch(data['publishedAt'] as int)),
          )).toList();
          
          batch.insertAllOnConflictUpdate(_db.posts, companions);
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

  PaginatedFeed _mapPaginatedFeed(Map<String, dynamic> data) {
    final posts =
        (data['posts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return PaginatedFeed.fromJson({...data, 'posts': posts});
  }
}
