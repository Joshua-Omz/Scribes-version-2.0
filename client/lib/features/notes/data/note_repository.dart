import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/application/auth_notifier.dart';
import '../domain/note.dart' as domain;
import 'note_api.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(noteApiProvider);
  final storage = ref.watch(secureStorageProvider);
  final authState = ref.watch(authProvider);

  String? currentUserId = authState.value?.id;

  return NoteRepository(db, api, storage, currentUserId);
});

class NoteRepository {
  final ScribesDatabase _db;
  final NoteApi _api;
  final SecureStorage _storage;
  final String? _currentUserId;

  NoteRepository(this._db, this._api, this._storage, this._currentUserId);

  Future<String> _resolveAuthorId() async {
    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      return _currentUserId;
    }
    return await _storage.getOrCreateGuestId();
  }

  Future<void> saveNoteLocally(
    String id,
    String content, {
    String? title,
    String? notebookId,
  }) async {
    final authorId = await _resolveAuthorId();
    final now = DateTime.now();

    await _db
        .into(_db.notes)
        .insertOnConflictUpdate(
          NotesCompanion(
            id: Value(id),
            authorId: Value(authorId),
            content: Value(content),
            title: Value(title),
            notebookId: Value(notebookId),
            isSynced: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  Future<domain.Note?> getNoteLocally(String id) async {
    final record = await (_db.select(
      _db.notes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
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
      contentMap = {'title': record.title ?? '', 'body': decoded};
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
    final authorId = await _resolveAuthorId();

    var query = _db.select(_db.notes)
      ..where((t) => t.authorId.equals(authorId));
    if (notebookId != null) {
      query = query..where((t) => t.notebookId.equals(notebookId));
    }

    final records =
        await (query..orderBy([
              (t) => OrderingTerm(
                expression: t.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
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
        contentMap = {'title': record.title ?? '', 'body': decoded};
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
      'id': id,
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

    if (cloudNote.id != id) {
      // Drift ignores primary key updates using .write(), so we must delete and recreate.
      await deleteNoteLocally(id);
      await saveNoteLocally(
        cloudNote.id,
        jsonEncode(cloudNote.content),
        title: cloudNote.title,
        notebookId: cloudNote.notebookId,
      );

      // Mark the newly inserted note as synced
      await (_db.update(_db.notes)..where((t) => t.id.equals(cloudNote.id)))
          .write(const NotesCompanion(isSynced: Value(true)));
    } else {
      await (_db.update(_db.notes)..where((t) => t.id.equals(id))).write(
        const NotesCompanion(isSynced: Value(true)),
      );
    }

    return cloudNote;
  }

  Future<Map<String, dynamic>> promoteToDraft(String id) async {
    final localNote = await getNoteLocally(id);
    if (localNote == null) throw Exception('Note not found locally');

    final authorId = await _resolveAuthorId();
    final now = DateTime.now();

    // If online & authenticated, promote via backend API
    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      try {
        final cloudNote = await pushToCloud(id);
        final draftDataResponse = await _api.promoteNoteToDraft(cloudNote.id);
        final draftId = draftDataResponse['draft_id'];
        final contentJson = jsonEncode(cloudNote.content);

        await _db
            .into(_db.drafts)
            .insertOnConflictUpdate(
              DraftsCompanion(
                id: Value(draftId),
                authorId: Value(authorId),
                content: Value(contentJson),
                caption: Value(localNote.title),
                isSynced: const Value(true),
                createdAt: Value(now),
                updatedAt: Value(now),
              ),
            );

        return {'id': draftId, 'content': cloudNote.content};
      } catch (_) {
        // Fallback to local offline promotion if server is offline
      }
    }

    // Local-first offline promotion
    final draftId = const Uuid().v4();
    final contentJson = jsonEncode(localNote.content);

    await _db
        .into(_db.drafts)
        .insertOnConflictUpdate(
          DraftsCompanion(
            id: Value(draftId),
            authorId: Value(authorId),
            content: Value(contentJson),
            caption: Value(localNote.title),
            isSynced: const Value(false),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return {'id': draftId, 'content': localNote.content};
  }
}
