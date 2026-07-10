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
      return _mapPaginatedFeed(rawData);
    } catch (e) {
      // If network fails, serve from local DB
      final records = await (_db.select(_db.posts)
            ..orderBy([(t) => OrderingTerm(expression: t.publishedAt, mode: OrderingMode.desc)])
            ..limit(20)) // Simplistic pagination for offline
          .get();
          
      final posts = records.map(_mapRecordToMap).toList();
      return PaginatedFeed.fromJson({
        'posts': posts,
        'next_cursor': null, // No pagination offline for now
      });
    }
  }

  Map<String, dynamic> _mapRecordToMap(Post record) {
    dynamic contentDecoded;
    try {
      contentDecoded = jsonDecode(record.content);
    } catch (_) {
      contentDecoded = {'body': []};
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
      'published_at': record.publishedAt.toIso8601String(),
    };
  }

  PaginatedFeed _mapPaginatedFeed(Map<String, dynamic> data) {
    final posts = (data['posts'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    return PaginatedFeed.fromJson({
      ...data,
      'posts': posts,
    });
  }
}
