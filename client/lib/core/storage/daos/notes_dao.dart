import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../../../features/sync/domain/sync_response.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<ScribesDatabase> with _$NotesDaoMixin {
  NotesDao(ScribesDatabase db) : super(db);

  Future<int?> getMaxServerSequence() {
    return (selectOnly(notes)..addColumns([notes.serverSequence.max()]))
        .map((row) => row.read(notes.serverSequence.max()))
        .getSingleOrNull();
  }

  Future<List<Note>> getLocalOnly() {
    return (select(notes)..where((n) => n.localOnly.equals(true))).get();
  }

  Future<void> upsertFromServer(SyncRecord record) {
    return into(notes).insertOnConflictUpdate(
      NotesCompanion.insert(
        id: record.localId,
        content: record.content['content'] ?? '',
        title: Value(record.content['title'] as String?),
        authorId: record.content['author_id'] ?? '',
        serverSequence: Value(record.serverSequence),
        localOnly: const Value(false),
        updatedAt: record.updatedAt,
        createdAt: record.content['created_at'] != null 
            ? DateTime.parse(record.content['created_at']) 
            : record.updatedAt,
      ),
    );
  }

  Future<void> markSynced(String localId, int serverSequence) {
    return (update(notes)..where((n) => n.id.equals(localId))).write(
      NotesCompanion(
        serverSequence: Value(serverSequence),
        localOnly: const Value(false),
      ),
    );
  }
}
