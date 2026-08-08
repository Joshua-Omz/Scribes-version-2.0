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

class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get userAId => text()();
  TextColumn get userBId => text()();
  BoolColumn get blocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastActive => dateTime()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get userALastReadAt => dateTime().nullable()();
  DateTimeColumn get userBLastReadAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get senderId => text()();
  TextColumn get body => text()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get sentAt => dateTime()();
  TextColumn get replyToId => text().nullable()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('sent'))();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get body => text()();
  TextColumn get replyToId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [Drafts, Posts, SyncMetadata, Notebooks, Notes, Conversations, Messages, PendingChatMessages],
  daos: [NotesDao, DraftsDao, PostsDao],
)
class ScribesDatabase extends _$ScribesDatabase {
  ScribesDatabase() : super(connection.openConnection());

  @override
  int get schemaVersion => 13;

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
        if (from < 6) {
          await m.createTable(conversations);
          await m.createTable(messages);
        }
        if (from < 7) {
          await m.addColumn(messages, messages.replyToId);
          await m.addColumn(messages, messages.editedAt);
        }
        if (from < 8) {
          await m.addColumn(messages, messages.status);
        }
        if (from < 9) {
          await m.addColumn(conversations, conversations.isHidden);
        }
        if (from < 10) {
          await m.addColumn(drafts, drafts.serverSequence);
          await m.addColumn(drafts, drafts.localOnly);
          await m.addColumn(posts, posts.serverSequence);
          await m.addColumn(notes, notes.serverSequence);
          await m.addColumn(notes, notes.localOnly);
        }
        if (from < 11) {
          await m.createTable(pendingChatMessages);
        }
        if (from < 12) {
          await m.addColumn(posts, posts.coverImageUrl);
          await m.addColumn(posts, posts.postType);
        }
        if (from < 13) {
          await m.addColumn(conversations, conversations.userALastReadAt);
          await m.addColumn(conversations, conversations.userBLastReadAt);
        }
      },
    );
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(conversations).go();
      await delete(messages).go();
      await delete(drafts).go();
      await delete(posts).go();
      await delete(notebooks).go();
      await delete(notes).go();
      await delete(syncMetadata).go();
    });
  }
}

