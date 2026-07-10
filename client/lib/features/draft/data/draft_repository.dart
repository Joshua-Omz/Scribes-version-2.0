import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../auth/application/auth_notifier.dart';
import '../domain/draft.dart' as domain;
import '../../posts/domain/sermon_source.dart';
import 'draft_api.dart';

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(draftApiProvider);
  final authState = ref.watch(authProvider);

  String? currentUserId = authState.value?.id;

  return DraftRepository(db, api, currentUserId);
});

class DraftRepository {
  final ScribesDatabase _db;
  final DraftApi _api;
  final String? _currentUserId;

  DraftRepository(this._db, this._api, this._currentUserId);

  /// Auto-saves the draft locally to Drift.
  Future<void> saveDraftLocally(String id, String content, {String? caption, String? sermonSource, List<String>? scriptureTags}) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final now = DateTime.now();
    final tagsJson = scriptureTags != null ? jsonEncode(scriptureTags) : null;

    await _db.into(_db.drafts).insertOnConflictUpdate(
      DraftsCompanion(
        id: Value(id),
        authorId: Value(userId),
        content: Value(content),
        caption: Value(caption),
        sermonSource: Value(sermonSource),
        scriptureTags: Value(tagsJson),
        isSynced: const Value(false),
        createdAt: Value(now), // Ideally we only set this on insert, but update works for now
        updatedAt: Value(now),
      ),
    );
  }

  /// Loads a draft from local SQLite
  Future<domain.Draft?> getDraftLocally(String id) async {
    final record = await (_db.select(_db.drafts)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (record == null) return null;

    dynamic decoded;
    try {
      decoded = jsonDecode(record.content);
    } catch (e) {
      decoded = {'body': []};
    }

    Map<String, dynamic> contentMap;
    if (decoded is Map<String, dynamic>) {
      contentMap = decoded;
    } else if (decoded is List) {
      contentMap = {
        'title': '',
        'excerpt': '',
        'body': decoded,
      };
    } else {
      contentMap = {'body': []};
    }

    List<String> tags = [];
    if (record.scriptureTags != null) {
      try {
        tags = List<String>.from(jsonDecode(record.scriptureTags!));
      } catch (_) {}
    }

    return domain.Draft(
      id: record.id,
      authorId: record.authorId,
      content: contentMap,
      caption: record.caption,
      sermonSource: record.sermonSource != null ? SermonSource(preacher: record.sermonSource) : null,
      scriptureTags: tags,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  /// Delete draft locally
  Future<void> deleteDraftLocally(String id) async {
    await (_db.delete(_db.drafts)..where((t) => t.id.equals(id))).go();
  }

  /// Loads all drafts from local SQLite
  Future<List<domain.Draft>> getAllLocalDrafts() async {
    final userId = _currentUserId;
    if (userId == null) return [];
    
    final records = await (_db.select(_db.drafts)
          ..where((t) => t.authorId.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)]))
        .get();

    return records.map((record) {
      dynamic decoded;
      try {
        decoded = jsonDecode(record.content);
      } catch (e) {
        decoded = {'body': []};
      }

      Map<String, dynamic> contentMap;
      if (decoded is Map<String, dynamic>) {
        contentMap = decoded;
      } else if (decoded is List) {
        // Fallback for old drafts saved purely as delta arrays
        contentMap = {
          'title': '',
          'excerpt': '',
          'body': decoded,
        };
      } else {
        contentMap = {'body': []};
      }

      List<String> tags = [];
      if (record.scriptureTags != null) {
        try {
          tags = List<String>.from(jsonDecode(record.scriptureTags!));
        } catch (_) {}
      }

      return domain.Draft(
        id: record.id,
        authorId: record.authorId,
        content: contentMap,
        caption: record.caption,
        sermonSource: record.sermonSource != null ? SermonSource(preacher: record.sermonSource) : null,
        scriptureTags: tags,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );
    }).toList();
  }

  /// Explicit sync to backend: Creates or Updates the draft.
  Future<domain.Draft> pushToCloud(String id) async {
    final local = await getDraftLocally(id);
    if (local == null) throw Exception('Draft not found locally');

    final payload = {
      'content': local.content,
      'caption': local.caption,
      'sermon_source': local.sermonSource != null ? jsonEncode(local.sermonSource!.toJson()) : null,
      'scripture_tags': local.scriptureTags,
    };

    domain.Draft cloudDraft;
    try {
      // Try update first
      final data = await _api.updateDraft(id, payload);
      cloudDraft = domain.Draft.fromJson(data);
    } catch (e) {
      // If 404, create it
      // In a real app we'd check status code
      final data = await _api.createDraft(payload);
      cloudDraft = domain.Draft.fromJson(data);
    }
    
    // Mark as synced locally
    await (_db.update(_db.drafts)..where((t) => t.id.equals(id))).write(
      const DraftsCompanion(isSynced: Value(true)),
    );
    
    return cloudDraft;
  }

  Future<Map<String, dynamic>> publishDraft(String id) async {
    // 1. Ensure it's pushed to the cloud first
    final cloudDraft = await pushToCloud(id);
    
    // 2. Call the publish endpoint with the cloud ID
    final postData = await _api.publishDraft(cloudDraft.id);
    
    // 3. Delete the draft locally since it's now a post
    await deleteDraftLocally(id);
    
    return postData;
  }
}
