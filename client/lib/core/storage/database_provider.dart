import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'daos/bible_dao.dart';
import 'drift_database.dart';

final databaseProvider = Provider<ScribesDatabase>((ref) {
  final db = ScribesDatabase();
  ref.onDispose(db.close);
  return db;
});

final bibleDaoProvider = Provider<BibleDao>((ref) {
  return ref.watch(databaseProvider).bibleDao;
});
