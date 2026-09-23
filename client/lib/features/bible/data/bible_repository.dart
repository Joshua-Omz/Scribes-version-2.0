import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/bible_data.dart';
import '../../../core/storage/daos/bible_dao.dart';
import '../../../core/storage/database_provider.dart';
import '../../../core/storage/drift_database.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/application/auth_notifier.dart';
import 'bible_api.dart';
import 'local/bible_local_datasource.dart';
import '../domain/bible_models.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  final api = ref.watch(bibleApiProvider);
  final local = ref.watch(bibleLocalDatasourceProvider);
  final bibleDao = ref.watch(bibleDaoProvider);
  final storage = ref.watch(secureStorageProvider);
  final authState = ref.watch(authProvider);

  final currentUserId = authState.value?.id;

  return BibleRepository(
    api,
    local,
    bibleDao,
    storage,
    currentUserId,
  );
});

class BibleRepository {
  final BibleApi _api;
  final BibleLocalDatasource _local;
  final BibleDao _bibleDao;
  final SecureStorage _storage;
  final String? _currentUserId;

  final Map<String, List<BibleBook>> _booksCache = {};
  final Map<String, BibleChapter> _chapterCache = {};
  final Map<String, VerseRangeResult> _rangeCache = {};

  BibleRepository(
    this._api,
    this._local,
    this._bibleDao,
    this._storage,
    this._currentUserId,
  );

  Future<String> _resolveUserId() async {
    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      return _currentUserId;
    }
    return await _storage.getOrCreateGuestId();
  }

  // ── Scripture Text Engine (100% Local Multi-Database SQLite) ──────

  /// Translations catalog — resolves from local manifest and storage
  Future<List<BibleTranslation>> getTranslations() async {
    return _local.getTranslations();
  }

  /// Reading — always local and instant, zero network dependency
  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) async {
    final trans = translation.toUpperCase();
    if (_booksCache.containsKey(trans)) {
      return _booksCache[trans]!;
    }
    final books = await _local.getBooks(translation: trans);
    _booksCache[trans] = books;
    return books;
  }

  /// Reading chapter — always local
  Future<BibleChapter> getChapter(
    String book,
    int chapter, {
    String translation = 'BSB',
  }) async {
    final trans = translation.toUpperCase();
    final key = '$trans:$book:$chapter';
    if (_chapterCache.containsKey(key)) {
      return _chapterCache[key]!;
    }
    final ch = await _local.getChapter(book, chapter, translation: trans);
    _chapterCache[key] = ch;
    return ch;
  }

  /// Reading verse range — always local
  Future<VerseRangeResult> getVerseRange(
    String book,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) async {
    final trans = translation.toUpperCase();
    final key = '$trans:$book:$chapter:$range';
    if (_rangeCache.containsKey(key)) {
      return _rangeCache[key]!;
    }
    final res = await _local.getVerseRange(
      book,
      chapter,
      range,
      translation: trans,
    );
    _rangeCache[key] = res;
    return res;
  }

  /// Search — 100% local sub-millisecond FTS5 BM25 search
  Future<List<BibleSearchResult>> search(
    String query, {
    int limit = 20,
    String translation = 'BSB',
  }) {
    return _local.search(
      query,
      translation: translation.toUpperCase(),
      limit: limit,
    );
  }

  /// Compare verse across multiple local translations in O(1)
  Future<List<BibleComparisonResult>> compareVerse(
    String book,
    int chapter,
    int verse, {
    List<String>? translations,
  }) {
    return _local.compareVerse(
      book,
      chapter,
      verse,
      translations: translations,
    );
  }

  // ── Decoupled User Data: Reading Position ──────────────────────────

  /// Reading position — Cache-first read path: Drift immediate, server in background
  Future<UserReadingPosition> getReadingPosition() async {
    final userId = await _resolveUserId();
    final localPos = await _bibleDao.getReadingPosition(userId);

    if (localPos != null) {
      if (_currentUserId != null && _currentUserId.isNotEmpty) {
        _syncReadingPositionInBackground(userId, localPos);
      }
      return UserReadingPosition(
        book: localPos.bookCode,
        bookCode: localPos.bookCode,
        chapter: localPos.chapter,
        verse: localPos.verse,
        preferredTranslation: localPos.preferredTranslation,
        updatedAt: localPos.updatedAt,
      );
    }

    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      final remotePos = await _api.getReadingPosition();
      if (remotePos != null) {
        await _bibleDao.saveReadingPosition(
          BibleReadingPositionsCompanion(
            userId: Value(userId),
            bookCode: Value(remotePos.bookCode.isNotEmpty ? remotePos.bookCode : remotePos.book),
            chapter: Value(remotePos.chapter),
            verse: Value(remotePos.verse),
            preferredTranslation: Value(remotePos.preferredTranslation),
            updatedAt: Value(remotePos.updatedAt ?? DateTime.now().toUtc()),
            isSynced: const Value(true),
          ),
        );
        return remotePos;
      }
    }

    return const UserReadingPosition(
      book: 'Genesis',
      bookCode: 'GEN',
      chapter: 1,
      verse: 1,
      preferredTranslation: 'BSB',
    );
  }

  void _syncReadingPositionInBackground(
    String userId,
    BibleReadingPosition localPos,
  ) async {
    try {
      final remotePos = await _api.getReadingPosition();
      if (remotePos != null && remotePos.updatedAt != null) {
        if (remotePos.updatedAt!.isAfter(localPos.updatedAt)) {
          await _bibleDao.saveReadingPosition(
            BibleReadingPositionsCompanion(
              userId: Value(userId),
              bookCode: Value(remotePos.bookCode.isNotEmpty ? remotePos.bookCode : remotePos.book),
              chapter: Value(remotePos.chapter),
              verse: Value(remotePos.verse),
              preferredTranslation: Value(remotePos.preferredTranslation),
              updatedAt: Value(remotePos.updatedAt!),
              isSynced: const Value(true),
            ),
          );
        } else if (!localPos.isSynced) {
          await _api.saveReadingPosition(
            book: localPos.bookCode,
            bookCode: localPos.bookCode,
            chapter: localPos.chapter,
            verse: localPos.verse,
            translation: localPos.preferredTranslation,
          );
          await _bibleDao.markReadingPositionSynced(userId);
        }
      }
    } catch (_) {
      // Ignore background sync errors
    }
  }

  /// Watch local reading position as a reactive stream
  Stream<UserReadingPosition?> watchReadingPosition() async* {
    final userId = await _resolveUserId();
    yield* _bibleDao.watchReadingPosition(userId).map((data) {
      if (data == null) return null;
      return UserReadingPosition(
        book: data.bookCode,
        bookCode: data.bookCode,
        chapter: data.chapter,
        verse: data.verse,
        preferredTranslation: data.preferredTranslation,
        updatedAt: data.updatedAt,
      );
    });
  }

  /// Save reading position — Local Drift immediate write (optimistic), sync in background
  Future<void> saveReadingPosition(
    String book,
    int chapter, {
    String? bookCode,
    int verse = 1,
    String translation = 'BSB',
  }) async {
    final userId = await _resolveUserId();
    final canonicalCode = (bookCode != null && bookCode.isNotEmpty)
        ? bookCode.toUpperCase()
        : book.toUpperCase();
    final now = DateTime.now().toUtc();

    await _bibleDao.saveReadingPosition(
      BibleReadingPositionsCompanion(
        userId: Value(userId),
        bookCode: Value(canonicalCode),
        chapter: Value(chapter),
        verse: Value(verse),
        preferredTranslation: Value(translation.toUpperCase()),
        updatedAt: Value(now),
        isSynced: const Value(false),
      ),
    );

    if (_currentUserId != null && _currentUserId.isNotEmpty) {
      try {
        await _api.saveReadingPosition(
          book: book,
          bookCode: canonicalCode,
          chapter: chapter,
          verse: verse,
          translation: translation,
        );
        await _bibleDao.markReadingPositionSynced(userId);
      } catch (_) {
        // Offline or network error: remains isSynced = false
      }
    }
  }

  // ── Decoupled User Data: Highlights ────────────────────────────────

  Future<List<BibleHighlight>> getHighlightsForChapter(
    String bookCode,
    int chapter,
  ) {
    return _bibleDao.getHighlightsForChapter(bookCode, chapter);
  }

  Stream<List<BibleHighlight>> watchHighlightsForChapter(
    String bookCode,
    int chapter,
  ) {
    return _bibleDao.watchHighlightsForChapter(bookCode, chapter);
  }

  Future<void> saveHighlight({
    String? id,
    required String bookCode,
    required int chapter,
    required int verse,
    String colorHex = '#F5A623',
    String? note,
  }) async {
    final userId = await _resolveUserId();
    final highlightId = id ?? const Uuid().v4();
    final now = DateTime.now().toUtc();
    final canonicalBookId = resolveCanonicalBookId(bookCode);
    final verseId = canonicalBookId * 1000000 + chapter * 1000 + verse;

    await _bibleDao.saveHighlight(
      BibleHighlightsCompanion(
        id: Value(highlightId),
        userId: Value(userId),
        verseId: Value(verseId),
        bookCode: Value(bookCode.toUpperCase()),
        chapter: Value(chapter),
        verse: Value(verse),
        colorHex: Value(colorHex),
        createdAt: Value(now),
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> deleteHighlight(String id) {
    return _bibleDao.deleteHighlight(id);
  }

  // ── Downloaded Translations Registry ───────────────────────────────

  Future<List<BibleDownloadedTranslation>> getDownloadedTranslations() {
    return _bibleDao.getDownloadedTranslations();
  }

  Stream<List<BibleDownloadedTranslation>> watchDownloadedTranslations() {
    return _bibleDao.watchDownloadedTranslations();
  }

  Future<void> registerDownloadedTranslation({
    required String code,
    required String name,
    required int version,
    required int fileSizeBytes,
    required String localPath,
  }) {
    return _bibleDao.registerDownloadedTranslation(
      BibleDownloadedTranslationsCompanion(
        code: Value(code.toUpperCase()),
        name: Value(name),
        version: Value(version),
        sizeBytes: Value(fileSizeBytes),
        localPath: Value(localPath),
        installedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> removeDownloadedTranslation(String code) {
    return _bibleDao.removeDownloadedTranslation(code);
  }
}
