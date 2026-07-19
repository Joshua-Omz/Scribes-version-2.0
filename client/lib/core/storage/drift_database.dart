import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:sqlite3/sqlite3.dart';

part 'drift_database.g.dart';

class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get authorId => text()();
  TextColumn get content => text()(); // Stores JSON string of Quill Document
  TextColumn get caption => text().nullable()();
  TextColumn get sermonSource => text().nullable()();
  TextColumn get scriptureTags => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
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

@DriftDatabase(tables: [Drafts, Posts, SyncMetadata, Notebooks, Notes])
class ScribesDatabase extends _$ScribesDatabase {
  ScribesDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'scribes.sqlite'));

    // Make sqlite3 pick up the proper library
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
