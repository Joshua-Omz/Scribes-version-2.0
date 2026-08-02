import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

DatabaseConnection openConnection() {
  final db = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'scribes.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
  return DatabaseConnection(db);
}
