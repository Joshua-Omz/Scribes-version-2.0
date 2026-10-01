// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_dao.dart';

// ignore_for_file: type=lint
mixin _$BibleDaoMixin on DatabaseAccessor<ScribesDatabase> {
  $BibleReadingPositionsTable get bibleReadingPositions =>
      attachedDatabase.bibleReadingPositions;
  $BibleHighlightsTable get bibleHighlights => attachedDatabase.bibleHighlights;
  $BibleDownloadedTranslationsTable get bibleDownloadedTranslations =>
      attachedDatabase.bibleDownloadedTranslations;
  $VerseNotesTable get verseNotes => attachedDatabase.verseNotes;
  BibleDaoManager get managers => BibleDaoManager(this);
}

class BibleDaoManager {
  final _$BibleDaoMixin _db;
  BibleDaoManager(this._db);
  $$BibleReadingPositionsTableTableManager get bibleReadingPositions =>
      $$BibleReadingPositionsTableTableManager(
        _db.attachedDatabase,
        _db.bibleReadingPositions,
      );
  $$BibleHighlightsTableTableManager get bibleHighlights =>
      $$BibleHighlightsTableTableManager(
        _db.attachedDatabase,
        _db.bibleHighlights,
      );
  $$BibleDownloadedTranslationsTableTableManager
  get bibleDownloadedTranslations =>
      $$BibleDownloadedTranslationsTableTableManager(
        _db.attachedDatabase,
        _db.bibleDownloadedTranslations,
      );
  $$VerseNotesTableTableManager get verseNotes =>
      $$VerseNotesTableTableManager(_db.attachedDatabase, _db.verseNotes);
}
