import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/drift_database.dart';
import '../data/bible_repository.dart';
import '../domain/bible_models.dart';
export 'bible_download_service.dart';

const _kBibleTranslationKey = 'scribes_bible_selected_translation';

class SelectedTranslationNotifier extends Notifier<String> {
  @override
  String build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getString(_kBibleTranslationKey);
      if (saved != null && saved.isNotEmpty && saved != state) {
        state = saved;
      }
    });
    return 'BSB';
  }

  void setTranslation(String translation) {
    state = translation;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_kBibleTranslationKey, translation);
    });
  }
}

final selectedTranslationProvider = NotifierProvider<SelectedTranslationNotifier, String>(SelectedTranslationNotifier.new);
final bibleTranslationsProvider = FutureProvider<List<BibleTranslation>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getTranslations();
});

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final translation = ref.watch(selectedTranslationProvider);
  return repo.getBooks(translation: translation);
});

final canonicalBibleBooksProvider = Provider<List<BibleBook>>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getStaticCanonicalBooks();
});

class BibleChapterQuery {
  final String book;
  final int chapter;

  const BibleChapterQuery({required this.book, required this.chapter});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleChapterQuery &&
          runtimeType == other.runtimeType &&
          book.toLowerCase() == other.book.toLowerCase() &&
          chapter == other.chapter;

  @override
  int get hashCode => book.toLowerCase().hashCode ^ chapter.hashCode;
}

final bibleChapterProvider =
    FutureProvider.family<BibleChapter, BibleChapterQuery>((ref, query) async {
      final repo = ref.watch(bibleRepositoryProvider);
      final translation = ref.watch(selectedTranslationProvider);
      return repo.getChapter(query.book, query.chapter, translation: translation);
    });

final verseLookupProvider = FutureProvider.family<VerseRangeResult, String>((
  ref,
  refStr,
) async {
  final repo = ref.watch(bibleRepositoryProvider);
  final translation = ref.watch(selectedTranslationProvider);

  // Parse ref string e.g. "Genesis 1:1-3" or "Romans 8:28" or "1 Corinthians 13:4-8"
  final match = RegExp(
    r'^(.+?)\s+(\d+):(\d+(?:-\d+)?)$',
  ).firstMatch(refStr.trim());
  if (match == null) {
    throw Exception('Invalid scripture reference format: $refStr');
  }

  final book = match.group(1)!;
  final chapter = int.parse(match.group(2)!);
  final range = match.group(3)!;

  return repo.getVerseRange(book, chapter, range, translation: translation);
});

final bibleReadingPositionProvider = FutureProvider<UserReadingPosition>((
  ref,
) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getReadingPosition();
});

final bibleReadingPositionStreamProvider =
    StreamProvider<UserReadingPosition?>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.watchReadingPosition();
});

final chapterHighlightsProvider =
    StreamProvider.family<List<BibleHighlight>, BibleChapterQuery>((
  ref,
  query,
) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.watchHighlightsForChapter(query.book, query.chapter);
});

/// Watches all verse notes for a given chapter. Returns a map of verse -> noteId
/// so the Bible Drawer can show note indicators without N+1 queries.
final chapterVerseNotesProvider =
    StreamProvider.family<Map<int, String>, BibleChapterQuery>((
  ref,
  query,
) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.watchNotesForChapter(query.book, query.chapter).map((notes) {
    final map = <int, String>{};
    for (final n in notes) {
      map[n.verse] = n.id;
    }
    return map;
  });
});

/// Watches all verse notes for the current user (for the Highlights & Notes page).
final allVerseNotesProvider = StreamProvider<List<VerseNote>>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.watchAllVerseNotes();
});

final downloadedTranslationsProvider =
    StreamProvider<List<BibleDownloadedTranslation>>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.watchDownloadedTranslations();
});

class BibleVerseQuery {
  final String book;
  final int chapter;
  final int verse;
  final List<String>? translations;

  const BibleVerseQuery({
    required this.book,
    required this.chapter,
    required this.verse,
    this.translations,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleVerseQuery &&
          runtimeType == other.runtimeType &&
          book.toLowerCase() == other.book.toLowerCase() &&
          chapter == other.chapter &&
          verse == other.verse &&
          listEquals(translations, other.translations);

  @override
  int get hashCode =>
      book.toLowerCase().hashCode ^
      chapter.hashCode ^
      verse.hashCode ^
      (translations != null ? Object.hashAll(translations!) : 0);
}

const _kBibleCompareTranslationsKey = 'scribes_bible_compare_translations';

class ComparisonSelectedTranslationsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    SharedPreferences.getInstance().then((prefs) {
      final saved = prefs.getStringList(_kBibleCompareTranslationsKey);
      if (saved != null && saved.isNotEmpty) {
        state = saved;
      } else {
        final current = ref.read(selectedTranslationProvider);
        state = current == 'BSB' ? ['BSB'] : [current, 'BSB'];
      }
    });

    final current = ref.read(selectedTranslationProvider);
    return current == 'BSB' ? ['BSB'] : [current, 'BSB'];
  }

  void toggleTranslation(String code) {
    final upper = code.toUpperCase().trim();
    final current = List<String>.from(state);
    if (current.contains(upper)) {
      if (current.length > 1) {
        current.remove(upper);
        state = current;
        _persist();
      }
    } else {
      current.add(upper);
      state = current;
      _persist();
    }
  }

  void addTranslation(String code) {
    final upper = code.toUpperCase().trim();
    if (!state.contains(upper)) {
      state = [...state, upper];
      _persist();
    }
  }

  void setTranslations(List<String> translations) {
    if (translations.isNotEmpty) {
      state = translations.map((e) => e.toUpperCase().trim()).toList();
      _persist();
    }
  }

  void _persist() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(_kBibleCompareTranslationsKey, state);
    });
  }
}

final comparisonSelectedTranslationsProvider =
    NotifierProvider<ComparisonSelectedTranslationsNotifier, List<String>>(
  ComparisonSelectedTranslationsNotifier.new,
);

final verseComparisonProvider = FutureProvider.family<
    List<BibleComparisonResult>, BibleVerseQuery>((ref, query) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.compareVerse(
    query.book,
    query.chapter,
    query.verse,
    translations: query.translations,
  );
});

final bibleSearchProvider =
    FutureProvider.family<List<BibleSearchResult>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];
  final repo = ref.watch(bibleRepositoryProvider);
  final translation = ref.watch(selectedTranslationProvider);
  return repo.search(query, translation: translation);
});

class BibleNavigationState {
  final String currentBook;
  final int currentChapter;
  final int totalChapters;
  final bool isBookPickerOpen;

  const BibleNavigationState({
    required this.currentBook,
    required this.currentChapter,
    required this.totalChapters,
    this.isBookPickerOpen = false,
  });

  BibleNavigationState copyWith({
    String? currentBook,
    int? currentChapter,
    int? totalChapters,
    bool? isBookPickerOpen,
  }) {
    return BibleNavigationState(
      currentBook: currentBook ?? this.currentBook,
      currentChapter: currentChapter ?? this.currentChapter,
      totalChapters: totalChapters ?? this.totalChapters,
      isBookPickerOpen: isBookPickerOpen ?? this.isBookPickerOpen,
    );
  }
}

class BibleNavigationNotifier extends Notifier<BibleNavigationState> {
  @override
  BibleNavigationState build() {
    Future.microtask(_initPosition);
    return const BibleNavigationState(
      currentBook: 'Genesis',
      currentChapter: 1,
      totalChapters: 50,
    );
  }

  Future<void> _initPosition() async {
    final repo = ref.read(bibleRepositoryProvider);
    final pos = await repo.getReadingPosition();
    final books = await repo.getBooks();
    final matchedBook = books.firstWhere(
      (b) =>
          (pos.bookCode.isNotEmpty &&
              b.code.toLowerCase() == pos.bookCode.toLowerCase()) ||
          b.name.toLowerCase() == pos.book.toLowerCase(),
      orElse: () => books.first,
    );
    state = state.copyWith(
      currentBook: matchedBook.name,
      currentChapter: pos.chapter,
      totalChapters: matchedBook.chapterCount,
    );
  }

  void selectBook(BibleBook book) {
    state = state.copyWith(
      currentBook: book.name,
      currentChapter: 1,
      totalChapters: book.chapterCount,
      isBookPickerOpen: false,
    );
    _persist();
  }

  void selectChapter(int chapter) {
    if (chapter >= 1 && chapter <= state.totalChapters) {
      state = state.copyWith(currentChapter: chapter);
      _persist();
    }
  }

  void navigateTo(String bookName, int chapter, {int? totalChapters}) {
    state = state.copyWith(
      currentBook: bookName,
      currentChapter: chapter,
      totalChapters: totalChapters ?? state.totalChapters,
      isBookPickerOpen: false,
    );
    _persist();
  }

  void nextChapter() {
    if (state.currentChapter < state.totalChapters) {
      state = state.copyWith(currentChapter: state.currentChapter + 1);
      _persist();
    }
  }

  void previousChapter() {
    if (state.currentChapter > 1) {
      state = state.copyWith(currentChapter: state.currentChapter - 1);
      _persist();
    }
  }

  void toggleBookPicker() {
    state = state.copyWith(isBookPickerOpen: !state.isBookPickerOpen);
  }

  void _persist() {
    final repo = ref.read(bibleRepositoryProvider);
    repo.saveReadingPosition(state.currentBook, state.currentChapter);
  }
}

final bibleNavigationProvider =
    NotifierProvider<BibleNavigationNotifier, BibleNavigationState>(
      BibleNavigationNotifier.new,
    );

class BibleReaderSettings {
  final double fontSize;
  final bool isSerif;
  final bool isVerseByVerse;
  final double lineSpacing;

  const BibleReaderSettings({
    this.fontSize = 22.0,
    this.isSerif = true,
    this.isVerseByVerse = false,
    this.lineSpacing = 1.9,
  });

  BibleReaderSettings copyWith({
    double? fontSize,
    bool? isSerif,
    bool? isVerseByVerse,
    double? lineSpacing,
  }) {
    return BibleReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      isSerif: isSerif ?? this.isSerif,
      isVerseByVerse: isVerseByVerse ?? this.isVerseByVerse,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }
}

const _kBibleFontSizeKey = 'scribes_bible_font_size';
const _kBibleIsSerifKey = 'scribes_bible_is_serif';
const _kBibleIsVerseByVerseKey = 'scribes_bible_is_verse_by_verse';
const _kBibleLineSpacingKey = 'scribes_bible_line_spacing';

class BibleReaderSettingsNotifier extends Notifier<BibleReaderSettings> {
  @override
  BibleReaderSettings build() {
    SharedPreferences.getInstance().then((prefs) {
      final fontSize = prefs.getDouble(_kBibleFontSizeKey) ?? 22.0;
      final isSerif = prefs.getBool(_kBibleIsSerifKey) ?? true;
      final isVerseByVerse = prefs.getBool(_kBibleIsVerseByVerseKey) ?? false;
      final lineSpacing = prefs.getDouble(_kBibleLineSpacingKey) ?? 1.9;

      state = BibleReaderSettings(
        fontSize: fontSize,
        isSerif: isSerif,
        isVerseByVerse: isVerseByVerse,
        lineSpacing: lineSpacing,
      );
    });

    return const BibleReaderSettings(
      fontSize: 22.0,
      isSerif: true,
      isVerseByVerse: false,
      lineSpacing: 1.9,
    );
  }

  void setFontSize(double size) {
    final clamped = size.clamp(18.0, 32.0);
    state = state.copyWith(fontSize: clamped);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_kBibleFontSizeKey, clamped);
    });
  }

  void toggleFontFamily() {
    final next = !state.isSerif;
    state = state.copyWith(isSerif: next);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_kBibleIsSerifKey, next);
    });
  }

  void toggleLayout() {
    final next = !state.isVerseByVerse;
    state = state.copyWith(isVerseByVerse: next);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_kBibleIsVerseByVerseKey, next);
    });
  }

  void setLineSpacing(double spacing) {
    state = state.copyWith(lineSpacing: spacing);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setDouble(_kBibleLineSpacingKey, spacing);
    });
  }
}

final bibleReaderSettingsProvider =
    NotifierProvider<BibleReaderSettingsNotifier, BibleReaderSettings>(
      BibleReaderSettingsNotifier.new,
    );
