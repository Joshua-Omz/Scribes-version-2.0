import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../domain/bible_models.dart';
import 'bible_local_datasource_interface.dart';

final bibleLocalDatasourceProvider = Provider<BibleLocalDatasource>((ref) {
  return BibleLocalDatasourceNative();
});

class BibleLocalDatasourceNative implements BibleLocalDatasource {
  Database? _db;

  Future<Database> _getDb() async {
    if (_db != null) return _db!;

    final dbPath = await _ensureDatabaseCopied();
    _db = sqlite3.open(dbPath, mode: OpenMode.readOnly);
    return _db!;
  }

  Future<String> _ensureDatabaseCopied() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDir.path, 'bsb.sqlite3');
    final dbFile = File(dbPath);

    final byteData = await rootBundle.load('assets/bible/bsb.sqlite3');
    final assetLength = byteData.lengthInBytes;

    if (!await dbFile.exists() || (await dbFile.length()) < assetLength) {
      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await dbFile.writeAsBytes(bytes, flush: true);
    }
    return dbPath;
  }

  String _cleanBookName(String input) {
    return input.trim().replaceAll('-', ' ').replaceAll('_', ' ');
  }

  @override
  Future<List<BibleBook>> getBooks() async {
    final db = await _getDb();
    final ResultSet results = db.select(
      'SELECT id, name, short_name, testament, book_order, chapter_count FROM books ORDER BY book_order ASC',
    );

    return results.map((row) {
      return BibleBook(
        id: row['short_name']?.toString() ?? row['id'].toString(),
        name: row['name'] as String,
        shortName: row['short_name'] as String,
        testament: row['testament'] as String,
        order: row['book_order'] as int,
        chapterCount: row['chapter_count'] as int,
      );
    }).toList();
  }

  @override
  Future<BibleChapter> getChapter(String bookName, int chapter) async {
    final db = await _getDb();
    final clean = _cleanBookName(bookName);

    final ResultSet results = db.select(
      '''
      SELECT b.name as book_name, v.chapter, v.verse, v.text
      FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE (LOWER(b.name) = LOWER(?) OR LOWER(b.short_name) = LOWER(?))
        AND v.chapter = ?
      ORDER BY v.verse ASC
    ''',
      [clean, clean, chapter],
    );

    if (results.isEmpty) {
      throw Exception('Book or chapter not found: $bookName $chapter');
    }

    final resolvedBook = results.first['book_name'] as String;
    final verses = results.map((row) {
      return BibleVerse(
        book: resolvedBook,
        chapter: row['chapter'] as int,
        verse: row['verse'] as int,
        text: row['text'] as String,
      );
    }).toList();

    return BibleChapter(
      translation: 'BSB',
      book: resolvedBook,
      chapter: chapter,
      verses: verses,
    );
  }

  @override
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range,
  ) async {
    final db = await _getDb();
    final clean = _cleanBookName(bookName);

    int startVerse = 1;
    int endVerse = 1;

    final trimmed = range.trim();
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      startVerse = int.tryParse(parts[0]) ?? 1;
      endVerse = int.tryParse(parts[1]) ?? startVerse;
    } else {
      startVerse = int.tryParse(trimmed) ?? 1;
      endVerse = startVerse;
    }

    if (endVerse < startVerse) {
      endVerse = startVerse;
    }

    final ResultSet results = db.select(
      '''
      SELECT b.name as book_name, v.chapter, v.verse, v.text
      FROM verses v
      JOIN books b ON b.id = v.book_id
      WHERE (LOWER(b.name) = LOWER(?) OR LOWER(b.short_name) = LOWER(?))
        AND v.chapter = ?
        AND v.verse >= ?
        AND v.verse <= ?
      ORDER BY v.verse ASC
    ''',
      [clean, clean, chapter, startVerse, endVerse],
    );

    if (results.isEmpty) {
      throw Exception('Verses not found: $bookName $chapter:$range');
    }

    final resolvedBook = results.first['book_name'] as String;
    final verses = results.map((row) {
      return BibleVerse(
        book: resolvedBook,
        chapter: row['chapter'] as int,
        verse: row['verse'] as int,
        text: row['text'] as String,
      );
    }).toList();

    final refStr = startVerse == endVerse
        ? '$resolvedBook $chapter:$startVerse'
        : '$resolvedBook $chapter:$startVerse-$endVerse';

    return VerseRangeResult(
      translation: 'BSB',
      reference: refStr,
      verses: verses,
    );
  }
}
