import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../draft/data/draft_repository.dart';
import '../../notes/data/note_repository.dart';
import '../data/sync_api.dart';
import '../domain/sync_event.dart';

final syncServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(syncApiProvider);
  final draftRepo = ref.watch(draftRepositoryProvider);
  final noteRepo = ref.watch(noteRepositoryProvider);
  return SyncService(db, api, draftRepo, noteRepo);
});

class SyncService {
  final ScribesDatabase _db;
  final SyncApi _api;
  final DraftRepository _draftRepo;
  final NoteRepository _noteRepo;

  SyncService(this._db, this._api, this._draftRepo, this._noteRepo);

  /// Synchronize the local database with the server.
  Future<void> sync({String? authorId}) async {
    await pushNotes();
    await pushDrafts();
    await pullEvents(authorId: authorId);
  }

  /// Push unsynced notes to the server.
  Future<void> pushNotes() async {
    final unsynced = await (_db.select(_db.notes)..where((t) => t.isSynced.equals(false))).get();
    for (final note in unsynced) {
      try {
        await _noteRepo.pushToCloud(note.id);
      } catch (e) {
        // Log error and continue to the next note
        print('Failed to push note ${note.id}: $e');
      }
    }
  }

  /// Push unsynced drafts to the server.
  Future<void> pushDrafts() async {
    final unsynced = await (_db.select(_db.drafts)..where((t) => t.isSynced.equals(false))).get();
    for (final draft in unsynced) {
      try {
        await _draftRepo.pushToCloud(draft.id);
      } catch (e) {
        // Log error and continue to the next draft
        print('Failed to push draft ${draft.id}: $e');
      }
    }
  }

  /// Pull new events from the server.
  Future<void> pullEvents({String? authorId}) async {
    final lastSeqKey = 'last_sequence_id';
    
    // Get last sequence ID
    final metaRecord = await (_db.select(_db.syncMetadata)..where((t) => t.key.equals(lastSeqKey))).getSingleOrNull();
    int lastSeq = 0;
    if (metaRecord != null) {
      lastSeq = int.tryParse(metaRecord.value) ?? 0;
    }

    try {
      final events = await _api.getSyncEvents(lastSeq);
      if (events.isEmpty) return;

      int maxSeq = lastSeq;

      await _db.transaction(() async {
        for (final event in events) {
          if (event.serverSequence > maxSeq) {
            maxSeq = event.serverSequence;
          }

          if (event.type == 'post') {
            await _upsertPost(event, authorId: authorId);
          } else if (event.type == 'draft') {
            await _upsertDraft(event, authorId: authorId);
          } else if (event.type == 'note') {
            await _upsertNote(event, authorId: authorId);
          }
        }

        // Save new max sequence
        await _db.into(_db.syncMetadata).insertOnConflictUpdate(
          SyncMetadataCompanion(
            key: const Value('last_sequence_id'),
            value: Value(maxSeq.toString()),
          ),
        );
      });
    } catch (e) {
      print('Failed to pull sync events: $e');
    }
  }

  Future<void> _upsertPost(SyncEvent event, {String? authorId}) async {
    final content = event.content;
    final resolvedAuthorId = content['author_id'] ?? authorId ?? '';
    
    // Determine JSON fields safely
    String contentStr = jsonEncode(content['content'] ?? content);
    String? sermonSourceStr = content['sermon_source'] != null ? jsonEncode(content['sermon_source']) : null;
    String? scriptureTagsStr = content['scripture_tags'] != null ? jsonEncode(content['scripture_tags']) : null;

    await _db.into(_db.posts).insertOnConflictUpdate(
      PostsCompanion(
        id: Value(event.id),
        authorId: Value(resolvedAuthorId),
        authorHandle: Value(content['author_handle'] ?? ''),
        authorName: Value(content['author_name'] ?? ''),
        content: Value(contentStr),
        caption: Value(event.titleOrCaption),
        visibility: Value(content['visibility'] ?? 'public'),
        currentVersion: Value(content['current_version'] ?? 1),
        isCorrection: Value(content['is_correction'] ?? false),
        correctsPostId: Value(content['corrects_post_id']),
        sermonSource: Value(sermonSourceStr),
        scriptureTags: Value(scriptureTagsStr),
        isDeleted: Value(content['is_deleted'] ?? false),
        publishedAt: Value(DateTime.parse(content['published_at'] ?? event.timestamp.toIso8601String())),
      ),
    );
  }

  Future<void> _upsertDraft(SyncEvent event, {String? authorId}) async {
    final content = event.content;
    final resolvedAuthorId = content['author_id'] ?? authorId ?? '';
    
    // Determine JSON fields safely
    String contentStr = jsonEncode(content['content'] ?? content);
    String? sermonSourceStr = content['sermon_source'] != null ? jsonEncode(content['sermon_source']) : null;
    String? scriptureTagsStr = content['scripture_tags'] != null ? jsonEncode(content['scripture_tags']) : null;

    await _db.into(_db.drafts).insertOnConflictUpdate(
      DraftsCompanion(
        id: Value(event.id),
        authorId: Value(resolvedAuthorId),
        content: Value(contentStr),
        caption: Value(event.titleOrCaption),
        sermonSource: Value(sermonSourceStr),
        scriptureTags: Value(scriptureTagsStr),
        isSynced: const Value(true), // We pulled it from the server
        createdAt: Value(event.timestamp),
        updatedAt: Value(event.timestamp),
      ),
    );
  }

  Future<void> _upsertNote(SyncEvent event, {String? authorId}) async {
    final existing = await (_db.select(_db.notes)..where((t) => t.id.equals(event.id))).getSingleOrNull();
    if (existing != null && existing.isSynced == false) {
      return;
    }

    final contentStr = jsonEncode(event.content);
    final resolvedAuthorId = authorId ?? existing?.authorId ?? '';
    if (resolvedAuthorId.isEmpty) {
      return;
    }

    await _db.into(_db.notes).insertOnConflictUpdate(
      NotesCompanion(
        id: Value(event.id),
        authorId: Value(resolvedAuthorId),
        content: Value(contentStr),
        title: Value(event.titleOrCaption),
        notebookId: Value(event.parentId),
        isSynced: const Value(true),
        createdAt: Value(existing?.createdAt ?? event.timestamp),
        updatedAt: Value(event.timestamp),
      ),
    );
  }
}
