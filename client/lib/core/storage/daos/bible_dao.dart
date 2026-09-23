import 'package:drift/drift.dart';
import '../drift_database.dart';

part 'bible_dao.g.dart';

@DriftAccessor(tables: [
  BibleReadingPositions,
  BibleHighlights,
  BibleDownloadedTranslations,
])
class BibleDao extends DatabaseAccessor<ScribesDatabase> with _$BibleDaoMixin {
  BibleDao(super.db);

  // ── Reading Position ────────────────────────────────────────

  Future<BibleReadingPosition?> getReadingPosition(String userId) {
    return (select(bibleReadingPositions)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Stream<BibleReadingPosition?> watchReadingPosition(String userId) {
    return (select(bibleReadingPositions)
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  Future<void> saveReadingPosition(BibleReadingPositionsCompanion pos) {
    return into(bibleReadingPositions).insertOnConflictUpdate(pos);
  }

  Future<void> markReadingPositionSynced(String userId) {
    return (update(bibleReadingPositions)
          ..where((t) => t.userId.equals(userId)))
        .write(const BibleReadingPositionsCompanion(isSynced: Value(true)));
  }

  // ── Highlights ──────────────────────────────────────────────

  Future<List<BibleHighlight>> getHighlightsForChapter(
    String bookCode,
    int chapter,
  ) {
    return (select(bibleHighlights)
          ..where(
            (t) =>
                t.bookCode.equals(bookCode.toUpperCase()) &
                t.chapter.equals(chapter),
          ))
        .get();
  }

  Stream<List<BibleHighlight>> watchHighlightsForChapter(
    String bookCode,
    int chapter,
  ) {
    return (select(bibleHighlights)
          ..where(
            (t) =>
                t.bookCode.equals(bookCode.toUpperCase()) &
                t.chapter.equals(chapter),
          ))
        .watch();
  }

  Future<void> saveHighlight(BibleHighlightsCompanion highlight) {
    return into(bibleHighlights).insertOnConflictUpdate(highlight);
  }

  Future<void> deleteHighlight(String id) {
    return (delete(bibleHighlights)..where((t) => t.id.equals(id))).go();
  }

  Future<List<BibleHighlight>> getUnsyncedHighlights(String userId) {
    return (select(bibleHighlights)
          ..where((t) => t.userId.equals(userId) & t.isSynced.equals(false)))
        .get();
  }

  Future<void> markHighlightSynced(String id) {
    return (update(bibleHighlights)..where((t) => t.id.equals(id))).write(
      const BibleHighlightsCompanion(isSynced: Value(true)),
    );
  }

  // ── Downloaded Translations Registry ────────────────────────

  Future<List<BibleDownloadedTranslation>> getDownloadedTranslations() {
    return select(bibleDownloadedTranslations).get();
  }

  Stream<List<BibleDownloadedTranslation>> watchDownloadedTranslations() {
    return select(bibleDownloadedTranslations).watch();
  }

  Future<void> registerDownloadedTranslation(
    BibleDownloadedTranslationsCompanion translation,
  ) {
    return into(bibleDownloadedTranslations).insertOnConflictUpdate(translation);
  }

  Future<void> removeDownloadedTranslation(String code) {
    return (delete(bibleDownloadedTranslations)
          ..where((t) => t.code.equals(code.toUpperCase())))
        .go();
  }

  // ── Transactional Account Claiming (Re-parenting) ───────────

  Future<void> reparentGuestData(String guestId, String newUserId) async {
    await transaction(() async {
      // 1. Re-parent reading position
      final guestPos = await (select(bibleReadingPositions)
            ..where((t) => t.userId.equals(guestId)))
          .getSingleOrNull();

      if (guestPos != null) {
        await (delete(bibleReadingPositions)
              ..where((t) => t.userId.equals(guestId)))
            .go();

        await into(bibleReadingPositions).insertOnConflictUpdate(
          BibleReadingPositionsCompanion(
            userId: Value(newUserId),
            bookCode: Value(guestPos.bookCode),
            chapter: Value(guestPos.chapter),
            verse: Value(guestPos.verse),
            preferredTranslation: Value(guestPos.preferredTranslation),
            updatedAt: Value(guestPos.updatedAt),
            isSynced: const Value(false),
          ),
        );
      }

      // 2. Re-parent highlights
      await (update(bibleHighlights)..where((t) => t.userId.equals(guestId)))
          .write(
        BibleHighlightsCompanion(
          userId: Value(newUserId),
          isSynced: const Value(false),
        ),
      );
    });
  }
}
