import 'package:drift/drift.dart';
import 'connection/connection.dart' as connection;
import 'daos/notes_dao.dart';
import 'daos/drafts_dao.dart';
import 'daos/posts_dao.dart';
part 'drift_database.g.dart';

class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text()();
  TextColumn get content => text()(); // Stores JSON string of Quill Document
  TextColumn get caption => text().nullable()();
  TextColumn get sermonSource => text().nullable()();
  TextColumn get scriptureTags => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  IntColumn get serverSequence => integer().nullable()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Posts extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text()();
  TextColumn get authorHandle => text()();
  TextColumn get authorName => text()();
  TextColumn get content => text()(); // JSON string
  TextColumn get caption => text().nullable()();
  TextColumn get visibility => text()();
  IntColumn get currentVersion => integer()();
  BoolColumn get isCorrection => boolean()();
  TextColumn get correctsPostId => text().nullable()();
  TextColumn get sermonSource => text().nullable()(); // JSON string
  TextColumn get scriptureTags => text().nullable()(); // JSON list
  BoolColumn get isDeleted => boolean()();
  IntColumn get serverSequence => integer().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get postType => text().withDefault(const Constant('standard'))();
  DateTimeColumn get publishedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notebooks extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text()();
  TextColumn get content => text()(); // JSON string
  TextColumn get title => text().nullable()();
  TextColumn get notebookId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  IntColumn get serverSequence => integer().nullable()();
  BoolColumn get localOnly => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Drafts,
    Posts,
    SyncMetadata,
    Notebooks,
    Notes,
  ],
  daos: [NotesDao, DraftsDao, PostsDao],
)
class ScribesDatabase extends _$ScribesDatabase {
  ScribesDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(drafts, drafts.scriptureTags);
        }
        if (from < 3) {
          await m.addColumn(drafts, drafts.isSynced);
          await m.createTable(posts);
          await m.createTable(syncMetadata);
        }
        if (from < 4) {
          await m.createTable(notebooks);
          await m.createTable(notes);
        }
        if (from < 5) {
          // categoryIds removed
        }
        if (from < 10) {
          await m.addColumn(drafts, drafts.serverSequence);
          await m.addColumn(drafts, drafts.localOnly);
          await m.addColumn(posts, posts.serverSequence);
          await m.addColumn(notes, notes.serverSequence);
          await m.addColumn(notes, notes.localOnly);
        }
        if (from < 12) {
          await m.addColumn(posts, posts.coverImageUrl);
          await m.addColumn(posts, posts.postType);
        }
      },
    );
  }

  Future<void> clearAllData({bool preserveUnsynced = true}) async {
    await transaction(() async {
      await delete(posts).go();
      await delete(syncMetadata).go();
      if (preserveUnsynced) {
        // Only delete synced cloud data, preserving local offline work
        await (delete(drafts)..where((t) => t.isSynced.equals(true))).go();
        await (delete(notes)..where((t) => t.isSynced.equals(true))).go();
      } else {
        await delete(drafts).go();
        await delete(notebooks).go();
        await delete(notes).go();
      }
    });
  }
}
