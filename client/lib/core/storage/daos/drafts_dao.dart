import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../../../features/sync/domain/sync_response.dart';

part 'drafts_dao.g.dart';

@DriftAccessor(tables: [Drafts])
class DraftsDao extends DatabaseAccessor<ScribesDatabase> with _$DraftsDaoMixin {
  DraftsDao(ScribesDatabase db) : super(db);

  Future<int?> getMaxServerSequence() {
    return (selectOnly(drafts)..addColumns([drafts.serverSequence.max()]))
        .map((row) => row.read(drafts.serverSequence.max()))
        .getSingleOrNull();
  }

  Future<List<Draft>> getLocalOnly() {
    return (select(drafts)..where((d) => d.localOnly.equals(true))).get();
  }

  Future<void> upsertFromServer(SyncRecord record) {
    return into(drafts).insertOnConflictUpdate(
      DraftsCompanion.insert(
        id: record.localId,
        content: record.content['content'] ?? '',
        caption: Value(record.content['caption'] as String?),
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
    return (update(drafts)..where((d) => d.id.equals(localId))).write(
      DraftsCompanion(
        serverSequence: Value(serverSequence),
        localOnly: const Value(false),
      ),
    );
  }
}
