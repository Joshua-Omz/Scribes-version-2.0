import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../domain/bible_models.dart';
import 'bible_local_datasource_interface.dart';

final bibleLocalDatasourceProvider = Provider<BibleLocalDatasource>((ref) {
  return BibleLocalDatasourceNative();
});

class BibleLocalDatasourceNative implements BibleLocalDatasource {
  final Map<String, Database> _databases = {};

  Future<String> _getBibleDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final bibleDir = Directory(p.join(docsDir.path, 'bible'));
    if (!await bibleDir.exists()) {
      await bibleDir.create(recursive: true);
    }
    return bibleDir.path;
  }

  Future<Database> _getDb(String translationCode) async {
    final code = translationCode.toUpperCase().trim();
    if (_databases.containsKey(code)) {
      return _databases[code]!;
    }

    final bibleDirPath = await _getBibleDirectory();
    final dbFile = File(p.join(bibleDirPath, '${code.toLowerCase()}.sqlite3'));

    if (code == 'BSB') {
      // Asset hydration for the default bundled translation
      final byteData = await rootBundle.load('assets/bible/bsb.sqlite3');
      final assetLength = byteData.lengthInBytes;

      if (!await dbFile.exists() || (await dbFile.length()) < assetLength) {
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        await dbFile.writeAsBytes(bytes, flush: true);
      }
    }

    if (!await dbFile.exists()) {
      throw Exception(
        'Translation $code is not installed locally. Please download it first.',
      );
    }

    final db = sqlite3.open(dbFile.path, mode: OpenMode.readOnly);
    _databases[code] = db;
    return db;
  }

  String _cleanBookName(String input) {
    return input.trim().replaceAll('-', ' ').replaceAll('_', ' ');
  }

  @override
  Future<void> ensureTranslationAvailable(String translationCode) async {
    await _getDb(translationCode);
  }

  @override
  Future<void> evictTranslation(String translationCode) async {
    final code = translationCode.toUpperCase().trim();
    if (_databases.containsKey(code)) {
      try {
        _databases[code]!.close();
      } catch (_) {}
      _databases.remove(code);
    }
  }

  @override
  Future<List<BibleTranslation>> getTranslations() async {
    final List<BibleTranslation> results = [];
    final bibleDirPath = await _getBibleDirectory();

    try {
      String manifestJson;
      final cachedManifest = File(p.join(bibleDirPath, 'manifest.json'));
      if (cachedManifest.existsSync()) {
        try {
          manifestJson = await cachedManifest.readAsString();
        } catch (_) {
          manifestJson = await rootBundle.loadString(
            'assets/bible/manifest.json',
          );
        }
      } else {
        manifestJson = await rootBundle.loadString(
          'assets/bible/manifest.json',
        );
      }
      final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;
      final list = decoded['translations'] as List<dynamic>? ?? [];

      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final t = BibleTranslation.fromJson(item);
          final localFile = File(
            p.join(bibleDirPath, '${t.code.toLowerCase()}.sqlite3'),
          );
          final isDownloaded = t.isBundled || localFile.existsSync();
          results.add(
            t.copyWith(
              isDownloaded: isDownloaded,
              isDefault: t.code == 'BSB',
            ),
          );
        }
      }
    } catch (_) {
      // Fallback to BSB if manifest read fails
      results.add(
        const BibleTranslation(
          id: 'BSB',
          code: 'BSB',
          name: 'Berean Standard Bible',
          language: 'en',
          attributionText: 'Berean Standard Bible, public domain (BSB)',
          source: 'bundled',
          isDefault: true,
          isBundled: true,
          isDownloaded: true,
        ),
      );
    }

    return results;
  }

  @override
  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) async {
    final db = await _getDb(translation);
    final ResultSet results = db.select(
      'SELECT canonical_id, code, name, short_name, testament, book_order, chapter_count FROM books ORDER BY book_order ASC',
    );

    return results.map((row) {
      return BibleBook(
        id: row['code']?.toString() ?? row['canonical_id'].toString(),
        name: row['name'] as String,
        shortName: row['short_name'] as String,
        testament: (row['testament'] as String).toLowerCase(),
        order: row['book_order'] as int,
        chapterCount: row['chapter_count'] as int,
      );
    }).toList();
  }

  @override
  Future<BibleChapter> getChapter(
    String bookName,
    int chapter, {
    String translation = 'BSB',
  }) async {
    final db = await _getDb(translation);
    final clean = _cleanBookName(bookName);

    final ResultSet results = db.select(
      '''
      SELECT b.name as book_name, v.chapter, v.verse, v.verse_end, v.text, v.is_omitted
      FROM verses v
      JOIN books b ON b.canonical_id = v.book_id
      WHERE (LOWER(b.name) = LOWER(?) OR LOWER(b.code) = LOWER(?) OR LOWER(b.short_name) = LOWER(?))
        AND v.chapter = ?
      ORDER BY v.verse ASC
    ''',
      [clean, clean, clean, chapter],
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
        verseEnd: row['verse_end'] as int?,
        text: row['text'] as String,
        isOmitted: (row['is_omitted'] as int? ?? 0) == 1,
      );
    }).toList();

    return BibleChapter(
      translation: translation.toUpperCase(),
      book: resolvedBook,
      chapter: chapter,
      verses: verses,
    );
  }

  @override
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) async {
    final db = await _getDb(translation);
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
      SELECT b.name as book_name, v.chapter, v.verse, v.verse_end, v.text, v.is_omitted
      FROM verses v
      JOIN books b ON b.canonical_id = v.book_id
      WHERE (LOWER(b.name) = LOWER(?) OR LOWER(b.code) = LOWER(?) OR LOWER(b.short_name) = LOWER(?))
        AND v.chapter = ?
        AND (
          (v.verse >= ? AND v.verse <= ?)
          OR (v.verse_end IS NOT NULL AND v.verse <= ? AND v.verse_end >= ?)
        )
      ORDER BY v.verse ASC
    ''',
      [clean, clean, clean, chapter, startVerse, endVerse, startVerse, endVerse],
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
        verseEnd: row['verse_end'] as int?,
        text: row['text'] as String,
        isOmitted: (row['is_omitted'] as int? ?? 0) == 1,
      );
    }).toList();

    final refStr = startVerse == endVerse
        ? '$resolvedBook $chapter:$startVerse'
        : '$resolvedBook $chapter:$startVerse-$endVerse';

    return VerseRangeResult(
      translation: translation.toUpperCase(),
      reference: refStr,
      verses: verses,
    );
  }

  @override
  Future<List<BibleSearchResult>> search(
    String query, {
    String translation = 'BSB',
    int limit = 20,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final db = await _getDb(translation);

    // Escape query for FTS5 syntax safety
    final sanitized = trimmed.replaceAll('"', '""');
    final ftsQuery = '"$sanitized"';

    try {
      final ResultSet results = db.select(
        '''
        SELECT b.name as book_name, v.chapter, v.verse, v.text
        FROM verses_fts
        JOIN verses v ON v.id = verses_fts.rowid
        JOIN books b ON b.canonical_id = v.book_id
        WHERE verses_fts MATCH ?
        LIMIT ?
      ''',
        [ftsQuery, limit],
      );

      return results.map((row) {
        return BibleSearchResult(
          book: row['book_name'] as String,
          chapter: row['chapter'] as int,
          verse: row['verse'] as int,
          text: row['text'] as String,
        );
      }).toList();
    } catch (_) {
      // Fallback to prefix token search if phrase match syntax errors
      final tokenQuery = '$sanitized*';
      final ResultSet results = db.select(
        '''
        SELECT b.name as book_name, v.chapter, v.verse, v.text
        FROM verses_fts
        JOIN verses v ON v.id = verses_fts.rowid
        JOIN books b ON b.canonical_id = v.book_id
        WHERE verses_fts MATCH ?
        LIMIT ?
      ''',
        [tokenQuery, limit],
      );

      return results.map((row) {
        return BibleSearchResult(
          book: row['book_name'] as String,
          chapter: row['chapter'] as int,
          verse: row['verse'] as int,
          text: row['text'] as String,
        );
      }).toList();
    }
  }

  @override
  Future<List<BibleComparisonResult>> compareVerse(
    String bookName,
    int chapter,
    int verse, {
    List<String>? translations,
  }) async {
    final targets = translations ?? ['BSB'];
    final List<BibleComparisonResult> comparisons = [];

    // 1. Resolve canonical book id using default translation
    final bsbDb = await _getDb('BSB');
    final clean = _cleanBookName(bookName);
    final bookRow = bsbDb.select(
      'SELECT canonical_id, name, code FROM books WHERE LOWER(name)=LOWER(?) OR LOWER(code)=LOWER(?) OR LOWER(short_name)=LOWER(?) LIMIT 1',
      [clean, clean, clean],
    );

    if (bookRow.isEmpty) return [];

    final canonicalId = bookRow.first['canonical_id'] as int;
    final resolvedName = bookRow.first['name'] as String;
    final verseCoordId = (canonicalId * 1000000) + (chapter * 1000) + verse;

    for (final trans in targets) {
      try {
        final db = await _getDb(trans);
        final verseRow = db.select(
          'SELECT text FROM verses WHERE id = ? LIMIT 1',
          [verseCoordId],
        );
        if (verseRow.isNotEmpty) {
          final meta = db.select('SELECT name, attribution FROM translation_meta LIMIT 1');
          final transName = meta.isNotEmpty ? meta.first['name'] as String : trans;
          final attribution = meta.isNotEmpty ? meta.first['attribution'] as String : '';

          comparisons.add(
            BibleComparisonResult(
              translation: trans.toUpperCase(),
              translationName: transName,
              reference: '$resolvedName $chapter:$verse',
              text: verseRow.first['text'] as String,
              attribution: attribution,
            ),
          );
        }
      } catch (_) {
        // Skip uninstalled or unavailable translation
        continue;
      }
    }

    return comparisons;
  }
}
