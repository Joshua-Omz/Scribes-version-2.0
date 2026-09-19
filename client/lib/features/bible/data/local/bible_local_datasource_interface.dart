import '../../domain/bible_models.dart';

abstract class BibleLocalDatasource {
  Future<List<BibleBook>> getBooks();
  Future<BibleChapter> getChapter(String bookName, int chapter);
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range,
  );
}
