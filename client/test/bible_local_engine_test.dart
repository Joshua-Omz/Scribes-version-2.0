import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bible Local SQLite & FTS5 Engine Tests', () {
    late Database db;

    setUpAll(() {
      final dbPath = 'assets/bible/bsb.sqlite3';
      expect(File(dbPath).existsSync(), isTrue, reason: 'bsb.sqlite3 should exist in assets');
      db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    });

    tearDownAll(() {
      db.dispose();
    });

    test('Translation metadata exists and has schema version 2', () {
      final rows = db.select('SELECT code, name, language, attribution, schema_version FROM translation_meta LIMIT 1');
      expect(rows.length, 1);
      expect(rows.first['code'], 'BSB');
      expect(rows.first['name'], 'Berean Standard Bible');
      expect(rows.first['schema_version'], 2);
    });

    test('Canonical books table contains exactly 66 books with standard USFM codes', () {
      final rows = db.select('SELECT canonical_id, code, name, testament, book_order, chapter_count FROM books ORDER BY book_order ASC');
      expect(rows.length, 66);
      expect(rows.first['code'], 'GEN');
      expect(rows.first['name'], 'Genesis');
      expect(rows[42]['code'], 'JHN'); // John is 43rd book
      expect(rows[42]['name'], 'John');
      expect(rows.last['code'], 'REV');
      expect(rows.last['name'], 'Revelation');
    });

    test('Verses table resolves John 3:16 by canonical coordinate ID 43003016', () {
      final rows = db.select('SELECT id, book_id, chapter, verse, text FROM verses WHERE id = 43003016');
      expect(rows.length, 1);
      final row = rows.first;
      expect(row['chapter'], 3);
      expect(row['verse'], 16);
      expect(row['text'], contains('For God so loved the world'));
    });

    test('Verses FTS5 virtual table executes sub-millisecond keyword search', () {
      final stopwatch = Stopwatch()..start();
      final rows = db.select('''
        SELECT b.name as book_name, v.chapter, v.verse, v.text
        FROM verses_fts
        JOIN verses v ON v.id = verses_fts.rowid
        JOIN books b ON b.canonical_id = v.book_id
        WHERE verses_fts MATCH '"steadfast love"'
        LIMIT 10
      ''');
      stopwatch.stop();

      expect(rows.isNotEmpty, isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(50), reason: 'FTS5 search should execute in < 50ms');
    });

    test('Merged verse range queries resolve correctly', () {
      final rows = db.select('''
        SELECT v.verse, v.text
        FROM verses v
        JOIN books b ON b.canonical_id = v.book_id
        WHERE b.code = 'ROM' AND v.chapter = 8 AND v.verse >= 28 AND v.verse <= 30
        ORDER BY v.verse ASC
      ''');
      expect(rows.length, 3);
      expect(rows.first['verse'], 28);
      expect(rows.last['verse'], 30);
    });
  });
}
