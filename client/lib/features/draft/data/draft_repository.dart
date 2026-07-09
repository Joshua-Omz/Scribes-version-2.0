import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../auth/application/auth_notifier.dart';
import '../domain/draft.dart' as domain;
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
  Future<void> saveDraftLocally(String id, String content, {String? caption, String? sermonSource}) async {
    if (_currentUserId == null) return;

    final now = DateTime.now();

    await _db.into(_db.drafts).insertOnConflictUpdate(
      DraftsCompanion(
        id: Value(id),
        authorId: Value(_currentUserId!),
        content: Value(content),
        caption: Value(caption),
        sermonSource: Value(sermonSource),
        createdAt: Value(now), // Ideally we only set this on insert, but update works for now
        updatedAt: Value(now),
      ),
    );
  }

  /// Loads a draft from local SQLite
  Future<domain.Draft?> getDraftLocally(String id) async {
    final record = await (_db.select(_db.drafts)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (record == null) return null;

    return domain.Draft(
      id: record.id,
      authorId: record.authorId,
      content: jsonDecode(record.content) as Map<String, dynamic>,
      caption: record.caption,
      sermonSource: record.sermonSource,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  /// Delete draft locally
  Future<void> deleteDraftLocally(String id) async {
    await (_db.delete(_db.drafts)..where((t) => t.id.equals(id))).go();
  }

  /// Explicit sync to backend: Creates or Updates the draft.
  Future<domain.Draft> pushToCloud(String id) async {
    final local = await getDraftLocally(id);
    if (local == null) throw Exception('Draft not found locally');

    final payload = {
      'content': local.content,
      'caption': local.caption,
      'sermon_source': local.sermonSource,
    };

    try {
      // Try update first
      final data = await _api.updateDraft(id, payload);
      return domain.Draft.fromJson(data);
    } catch (e) {
      // If 404, create it
      // In a real app we'd check status code
      final data = await _api.createDraft(payload);
      return domain.Draft.fromJson(data);
    }
  }
}
