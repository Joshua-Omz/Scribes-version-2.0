import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/bible_repository.dart';
import '../domain/bible_models.dart';

final bibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getBooks();
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
      return repo.getChapter(query.book, query.chapter);
    });

final verseLookupProvider = FutureProvider.family<VerseRangeResult, String>((
  ref,
  refStr,
) async {
  final repo = ref.watch(bibleRepositoryProvider);

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

  return repo.getVerseRange(book, chapter, range);
});

final bibleReadingPositionProvider = FutureProvider<BibleReadingPosition?>((
  ref,
) async {
  final repo = ref.watch(bibleRepositoryProvider);
  return repo.getReadingPosition();
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
    if (pos != null) {
      final books = await repo.getBooks();
      final matchedBook = books.firstWhere(
        (b) => b.name.toLowerCase() == pos.book.toLowerCase(),
        orElse: () => books.first,
      );
      state = state.copyWith(
        currentBook: matchedBook.name,
        currentChapter: pos.chapter,
        totalChapters: matchedBook.chapterCount,
      );
    }
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
