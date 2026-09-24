import '../../domain/bible_models.dart';

abstract class BibleLocalDatasource {
  Future<List<BibleTranslation>> getTranslations();

  Future<List<BibleBook>> getBooks({String translation = 'BSB'});

  Future<BibleChapter> getChapter(
    String bookName,
    int chapter, {
    String translation = 'BSB',
  });

  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range, {
    String translation = 'BSB',
  });

  Future<List<BibleSearchResult>> search(
    String query, {
    String translation = 'BSB',
    int limit = 20,
  });

  Future<List<BibleComparisonResult>> compareVerse(
    String bookName,
    int chapter,
    int verse, {
    List<String>? translations,
  });

  Future<void> ensureTranslationAvailable(String translationCode);

  Future<void> evictTranslation(String translationCode);
}
