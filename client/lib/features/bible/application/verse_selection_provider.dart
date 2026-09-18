import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/verse_selection.dart';

/// Manages ephemeral, contiguous verse selection state within the Bible Drawer.
///
/// This state is scoped to the lifetime of the Bible Drawer view. It never persists,
/// never syncs, and strictly enforces contiguous single-interval ranges.
class VerseSelectionNotifier extends Notifier<VerseSelection?> {
  @override
  VerseSelection? build() => null;

  /// Toggles or adjusts selection for a given verse in the currently viewed chapter.
  void toggleVerse(String book, int chapter, int verse) {
    final current = state;

    // 1. Fresh start if nothing selected or if navigated to another book/chapter
    if (current == null ||
        current.book.toLowerCase() != book.toLowerCase() ||
        current.chapter != chapter) {
      state = VerseSelection(
        book: book,
        chapter: chapter,
        verseStart: verse,
        verseEnd: verse,
      );
      return;
    }

    // 2. Tap-to-toggle off if tapping the only selected verse
    if (current.verseStart == current.verseEnd &&
        verse == current.verseStart) {
      state = null;
      return;
    }

    // 3. Extending the range forward
    if (verse == current.verseEnd + 1) {
      state = current.copyWith(verseEnd: verse);
      return;
    }

    // 4. Extending the range backward
    if (verse == current.verseStart - 1) {
      state = current.copyWith(verseStart: verse);
      return;
    }

    // 5. Shrinking range from the start
    if (verse == current.verseStart && current.verseStart != current.verseEnd) {
      state = current.copyWith(verseStart: verse + 1);
      return;
    }

    // 6. Shrinking range from the end
    if (verse == current.verseEnd && current.verseStart != current.verseEnd) {
      state = current.copyWith(verseEnd: verse - 1);
      return;
    }

    // 7. Non-adjacent or middle tap: resets to a fresh single-verse selection
    state = VerseSelection(
      book: book,
      chapter: chapter,
      verseStart: verse,
      verseEnd: verse,
    );
  }

  /// Explicitly clears any active selection.
  void clear() {
    state = null;
  }
}

/// Auto-disposed provider for scripture verse selection.
final verseSelectionProvider =
    NotifierProvider.autoDispose<VerseSelectionNotifier, VerseSelection?>(
  VerseSelectionNotifier.new,
);

/// Alias for contract compatibility.
final verseSelectionNotifierProvider = verseSelectionProvider;
