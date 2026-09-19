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
  Future<List<BibleBook>> getBooks() {
    return _api.getBooks(translation: 'BSB');
  }

  @override
  Future<BibleChapter> getChapter(String bookName, int chapter) {
    return _api.getChapter(bookName, chapter, translation: 'BSB');
  }

  @override
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range,
  ) {
    return _api.getVerseRange(bookName, chapter, range, translation: 'BSB');
  }
}
