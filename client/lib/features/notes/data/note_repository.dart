import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../auth/application/auth_notifier.dart';
import '../domain/note.dart' as domain;
import 'note_api.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(noteApiProvider);
  final authState = ref.watch(authProvider);

  String? currentUserId = authState.value?.id;

  return NoteRepository(db, api, currentUserId);
});

class NoteRepository {
  final ScribesDatabase _db;
  final NoteApi _api;
  final String? _currentUserId;

  NoteRepository(this._db, this._api, this._currentUserId);

  Future<void> saveNoteLocally(String id, String content, {String? title, String? notebookId}) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final now = DateTime.now();

    await _db.into(_db.notes).insertOnConflictUpdate(
      NotesCompanion(
        id: Value(id),
        authorId: Value(userId),
        content: Value(content),
        title: Value(title),
        notebookId: Value(notebookId),
        isSynced: const Value(false),
        createdAt: Value(now), // This will update createdAt as well, but for simplicity it works
        updatedAt: Value(now),
      ),
    );
  }

  Future<domain.Note?> getNoteLocally(String id) async {
    final record = await (_db.select(_db.notes)..where((t) => t.id.equals(id))).getSingleOrNull();
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
        'title': record.title ?? '',
        'body': decoded,
      };
    } else {
      contentMap = {'body': []};
    }

    return domain.Note(
      id: record.id,
      authorId: record.authorId,
      content: contentMap,
      title: record.title,
      notebookId: record.notebookId,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  Future<void> deleteNoteLocally(String id) async {
    await (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
  }

  Future<List<domain.Note>> getAllLocalNotes({String? notebookId}) async {
    final userId = _currentUserId;
    if (userId == null) return [];
    
    var query = _db.select(_db.notes)..where((t) => t.authorId.equals(userId));
    if (notebookId != null) {
      query = query..where((t) => t.notebookId.equals(notebookId));
    }
    
    final records = await (query..orderBy([(t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)])).get();

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
        contentMap = {
          'title': record.title ?? '',
          'body': decoded,
        };
      } else {
        contentMap = {'body': []};
      }

      return domain.Note(
        id: record.id,
        authorId: record.authorId,
        content: contentMap,
        title: record.title,
        notebookId: record.notebookId,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );
    }).toList();
  }

  Future<domain.Note> pushToCloud(String id) async {
    final local = await getNoteLocally(id);
    if (local == null) throw Exception('Note not found locally');

    final payload = {
      'content': local.content,
      'title': local.title,
      'notebook_id': local.notebookId,
    };

    domain.Note cloudNote;
    try {
      // Try update
      final data = await _api.updateNote(id, payload);
      cloudNote = domain.Note.fromJson(data);
    } catch (e) {
      // If fails (e.g. 404), create
      final data = await _api.createNote(payload);
      cloudNote = domain.Note.fromJson(data);
    }
    
    await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
      const NotesCompanion(isSynced: Value(true)),
    );
    
    return cloudNote;
  }

  Future<Map<String, dynamic>> promoteToDraft(String id) async {
    // 1. Sync to cloud first
    final cloudNote = await pushToCloud(id);
    
    // 2. Call promote endpoint
    final draftData = await _api.promoteNoteToDraft(cloudNote.id);
    
    // 3. Delete note locally as it is now a draft
    await deleteNoteLocally(id);
    
    return draftData;
  }
}
