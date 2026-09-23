import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/core/storage/daos/bible_dao.dart';
import 'package:scribes/core/storage/drift_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScribesDatabase db;
  late BibleDao bibleDao;

  setUp(() {
    db = ScribesDatabase.forTesting(NativeDatabase.memory());
    bibleDao = db.bibleDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('Decoupled Bible User Data & Drift Storage Tests', () {
    test('Reading position saves locally and resolves correctly', () async {
      const userId = 'user_abc';
      final now = DateTime.now().toUtc();

      await bibleDao.saveReadingPosition(
        BibleReadingPositionsCompanion(
          userId: const Value(userId),
          bookCode: const Value('JHN'),
          chapter: const Value(3),
          verse: const Value(16),
          preferredTranslation: const Value('BSB'),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      final pos = await bibleDao.getReadingPosition(userId);
      expect(pos, isNotNull);
      expect(pos!.userId, userId);
      expect(pos.bookCode, 'JHN');
      expect(pos.chapter, 3);
      expect(pos.verse, 16);
      expect(pos.preferredTranslation, 'BSB');
      expect(pos.isSynced, isFalse);
    });

    test('Marking reading position synced updates isSynced flag', () async {
      const userId = 'user_sync_test';
      final now = DateTime.now().toUtc();

      await bibleDao.saveReadingPosition(
        BibleReadingPositionsCompanion(
          userId: const Value(userId),
          bookCode: const Value('ROM'),
          chapter: const Value(8),
          verse: const Value(28),
          preferredTranslation: const Value('BSB'),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      var pos = await bibleDao.getReadingPosition(userId);
      expect(pos!.isSynced, isFalse);

      await bibleDao.markReadingPositionSynced(userId);

      pos = await bibleDao.getReadingPosition(userId);
      expect(pos!.isSynced, isTrue);
    });

    test('Highlights save, query by chapter, and delete', () async {
      const userId = 'user_highlight_1';
      final now = DateTime.now().toUtc();

      // Save John 3:16 highlight
      await bibleDao.saveHighlight(
        BibleHighlightsCompanion(
          id: const Value('hl_jhn_3_16'),
          userId: const Value(userId),
          verseId: const Value(43003016),
          bookCode: const Value('JHN'),
          chapter: const Value(3),
          verse: const Value(16),
          colorHex: const Value('#F5A623'),
          createdAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // Save John 3:17 highlight
      await bibleDao.saveHighlight(
        BibleHighlightsCompanion(
          id: const Value('hl_jhn_3_17'),
          userId: const Value(userId),
          verseId: const Value(43003017),
          bookCode: const Value('JHN'),
          chapter: const Value(3),
          verse: const Value(17),
          colorHex: const Value('#4A90E2'),
          createdAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // Query highlights for John 3
      final chapterHighlights = await bibleDao.getHighlightsForChapter('JHN', 3);
      expect(chapterHighlights.length, 2);
      expect(chapterHighlights.any((h) => h.verse == 16), isTrue);
      expect(chapterHighlights.any((h) => h.verse == 17), isTrue);

      // Query for different chapter should be empty
      final ch4Highlights = await bibleDao.getHighlightsForChapter('JHN', 4);
      expect(ch4Highlights.isEmpty, isTrue);

      // Delete John 3:16
      await bibleDao.deleteHighlight('hl_jhn_3_16');
      final remaining = await bibleDao.getHighlightsForChapter('JHN', 3);
      expect(remaining.length, 1);
      expect(remaining.first.verse, 17);
    });

    test('reparentGuestData atomically re-parents reading position and highlights', () async {
      const guestId = 'guest_device_xyz';
      const authenticatedUserId = 'user_auth_999';
      final now = DateTime.now().toUtc();

      // 1. Guest creates reading position
      await bibleDao.saveReadingPosition(
        BibleReadingPositionsCompanion(
          userId: const Value(guestId),
          bookCode: const Value('PSA'),
          chapter: const Value(23),
          verse: const Value(1),
          preferredTranslation: const Value('BSB'),
          updatedAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // 2. Guest creates highlight
      await bibleDao.saveHighlight(
        BibleHighlightsCompanion(
          id: const Value('hl_guest_psa'),
          userId: const Value(guestId),
          verseId: const Value(19023001),
          bookCode: const Value('PSA'),
          chapter: const Value(23),
          verse: const Value(1),
          colorHex: const Value('#7ED321'),
          createdAt: Value(now),
          isSynced: const Value(false),
        ),
      );

      // 3. Trigger atomic re-parenting
      await bibleDao.reparentGuestData(guestId, authenticatedUserId);

      // 4. Verify old guest ID data is migrated
      final oldGuestPos = await bibleDao.getReadingPosition(guestId);
      expect(oldGuestPos, isNull);

      // 5. Verify new user ID owns the reading position and is marked for cloud sync
      final newPos = await bibleDao.getReadingPosition(authenticatedUserId);
      expect(newPos, isNotNull);
      expect(newPos!.bookCode, 'PSA');
      expect(newPos.chapter, 23);
      expect(newPos.verse, 1);
      expect(newPos.isSynced, isFalse);

      // 6. Verify highlights re-parented to new user
      final userHighlights = await bibleDao.getHighlightsForChapter('PSA', 23);
      expect(userHighlights.length, 1);
      expect(userHighlights.first.userId, authenticatedUserId);
      expect(userHighlights.first.isSynced, isFalse);
    });

    test('Downloaded translations registry lifecycle (register and remove)', () async {
      final now = DateTime.now().toUtc();

      await bibleDao.registerDownloadedTranslation(
        BibleDownloadedTranslationsCompanion(
          code: const Value('KJV'),
          name: const Value('King James Version'),
          version: const Value(1),
          sizeBytes: const Value(5200000),
          localPath: const Value('/data/bible/kjv.sqlite3'),
          installedAt: Value(now),
        ),
      );

      var list = await bibleDao.getDownloadedTranslations();
      expect(list.length, 1);
      expect(list.first.code, 'KJV');
      expect(list.first.name, 'King James Version');

      await bibleDao.removeDownloadedTranslation('KJV');
      list = await bibleDao.getDownloadedTranslations();
      expect(list.isEmpty, isTrue);
    });
  });
}
