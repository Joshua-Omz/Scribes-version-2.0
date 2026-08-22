import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible_api.dart';
import 'local/bible_local_datasource.dart';
import '../domain/bible_models.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final api = ref.watch(bibleApiProvider);
  final local = ref.watch(bibleLocalDatasourceProvider);
  return BibleRepository(api, local);
});

class BibleRepository {
  final BibleApi _api;
  final BibleLocalDatasource _local;

  final Map<String, List<BibleBook>> _booksCache = {};
  final Map<String, BibleChapter> _chapterCache = {};
  final Map<String, VerseRangeResult> _rangeCache = {};

  BibleRepository(this._api, this._local);

  /// Reading — always local and instant for BSB, never touches the network
  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) async {
    if (translation.toUpperCase() == 'BSB') {
      return _local.getBooks();
    }
    if (_booksCache.containsKey(translation)) {
      return _booksCache[translation]!;
    }
    final books = await _api.getBooks(translation: translation);
    _booksCache[translation] = books;
    return books;
  }

  /// Reading — always local and instant for BSB, never touches the network
  Future<BibleChapter> getChapter(
    String book,
    int chapter, {
    String translation = 'BSB',
  }) async {
    if (translation.toUpperCase() == 'BSB') {
      return _local.getChapter(book, chapter);
    }
    final key = '$translation:$book:$chapter';
    if (_chapterCache.containsKey(key)) {
      return _chapterCache[key]!;
    }
    final ch = await _api.getChapter(book, chapter, translation: translation);
    _chapterCache[key] = ch;
    return ch;
  }

  /// Reading — always local and instant for BSB, never touches the network
  Future<VerseRangeResult> getVerseRange(
    String book,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) async {
    if (translation.toUpperCase() == 'BSB') {
      return _local.getVerseRange(book, chapter, range);
    }
    final key = '$translation:$book:$chapter:$range';
    if (_rangeCache.containsKey(key)) {
      return _rangeCache[key]!;
    }
    final res = await _api.getVerseRange(
      book,
      chapter,
      range,
      translation: translation,
    );
    _rangeCache[key] = res;
    return res;
  }

  /// Search — remote full-text search against the server
  Future<List<BibleSearchResult>> search(
    String query, {
    int limit = 20,
    String translation = 'BSB',
  }) {
    return _api.search(query, limit: limit, translation: translation);
  }

  /// Reading position — server sync for cross-device state
  Future<BibleReadingPosition?> getReadingPosition() {
    return _api.getReadingPosition();
  }

  Future<void> saveReadingPosition(String book, int chapter) {
    return _api.saveReadingPosition(book, chapter);
  }
}
