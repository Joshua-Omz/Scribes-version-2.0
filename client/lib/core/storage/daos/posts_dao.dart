import 'package:drift/drift.dart';
import '../drift_database.dart';
import '../../../features/sync/domain/sync_response.dart';

part 'posts_dao.g.dart';

@DriftAccessor(tables: [Posts])
class PostsDao extends DatabaseAccessor<ScribesDatabase> with _$PostsDaoMixin {
  PostsDao(ScribesDatabase db) : super(db);

  Future<int?> getMaxServerSequence() {
    return (selectOnly(posts)..addColumns([posts.serverSequence.max()]))
        .map((row) => row.read(posts.serverSequence.max()))
        .getSingleOrNull();
  }

  Future<void> upsertFromServer(SyncRecord record) {
    return into(posts).insertOnConflictUpdate(
      PostsCompanion.insert(
        id: record.localId,
        content: record.content['content'] ?? '',
        caption: Value(record.content['caption'] as String?),
        authorId: record.content['author_id'] ?? '',
        authorHandle: record.content['author_handle'] ?? '',
        authorName: record.content['author_name'] ?? '',
        visibility: record.content['visibility'] ?? 'public',
        currentVersion: record.content['current_version'] ?? 1,
        isCorrection: record.content['is_correction'] ?? false,
        isDeleted: record.content['is_deleted'] ?? false,
        serverSequence: Value(record.serverSequence),
        publishedAt: record.updatedAt,
      ),
    );
  }
}
