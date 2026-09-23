import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/bible_models.dart';
import '../bible_api.dart';
import 'bible_local_datasource_interface.dart';

final bibleLocalDatasourceProvider = Provider<BibleLocalDatasource>((ref) {
  final api = ref.watch(bibleApiProvider);
  return BibleLocalDatasourceWeb(api);
});

class BibleLocalDatasourceWeb implements BibleLocalDatasource {
  final BibleApi _api;

  BibleLocalDatasourceWeb(this._api);

  @override
  Future<void> ensureTranslationAvailable(String translationCode) async {}

  @override
  Future<List<BibleTranslation>> getTranslations() async {
    try {
      final manifestJson = await rootBundle.loadString('assets/bible/manifest.json');
      final decoded = jsonDecode(manifestJson) as Map<String, dynamic>;
      final list = decoded['translations'] as List<dynamic>? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => BibleTranslation.fromJson(item).copyWith(isDownloaded: true))
          .toList();
    } catch (_) {
      return _api.getTranslations();
    }
  }

  @override
  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) {
    return _api.getBooks(translation: translation);
  }

  @override
  Future<BibleChapter> getChapter(
    String bookName,
    int chapter, {
    String translation = 'BSB',
  }) {
    return _api.getChapter(bookName, chapter, translation: translation);
  }

  @override
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) {
    return _api.getVerseRange(bookName, chapter, range, translation: translation);
  }

  @override
  Future<List<BibleSearchResult>> search(
    String query, {
    String translation = 'BSB',
    int limit = 20,
  }) {
    return _api.search(query, limit: limit, translation: translation);
  }

  @override
  Future<List<BibleComparisonResult>> compareVerse(
    String bookName,
    int chapter,
    int verse, {
    List<String>? translations,
  }) async {
    final targets = translations ?? ['BSB'];
    final List<BibleComparisonResult> results = [];
    for (final t in targets) {
      try {
        final res = await _api.getVerseRange(bookName, chapter, '$verse', translation: t);
        if (res.verses.isNotEmpty) {
          results.add(
            BibleComparisonResult(
              translation: t.toUpperCase(),
              translationName: t.toUpperCase(),
              reference: '$bookName $chapter:$verse',
              text: res.verses.first.text,
              attribution: '',
            ),
          );
        }
      } catch (_) {}
    }
    return results;
  }
}
