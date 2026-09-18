import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/bible/domain/verse_selection.dart';
import 'package:scribes/features/bible/application/verse_selection_provider.dart';

void main() {
  group('VerseSelection Domain Model', () {
    test('creates valid single-verse selection', () {
      const sel = VerseSelection(
        book: 'John',
        chapter: 3,
        verseStart: 16,
        verseEnd: 16,
      );

      expect(sel.book, 'John');
      expect(sel.chapter, 3);
      expect(sel.verseStart, 16);
      expect(sel.verseEnd, 16);
      expect(sel.displayLabel, 'John 3:16');
      expect(sel.contains(16), isTrue);
      expect(sel.contains(15), isFalse);
      expect(sel.contains(17), isFalse);

      final ref = sel.toReference();
      expect(ref.book, 'John');
      expect(ref.chapter, 3);
      expect(ref.verseStart, 16);
      expect(ref.verseEnd, isNull);
    });

    test('creates valid multi-verse range selection', () {
      const sel = VerseSelection(
        book: 'Romans',
        chapter: 8,
        verseStart: 28,
        verseEnd: 30,
      );

      expect(sel.displayLabel, 'Romans 8:28-30');
      expect(sel.contains(28), isTrue);
      expect(sel.contains(29), isTrue);
      expect(sel.contains(30), isTrue);
      expect(sel.contains(27), isFalse);
      expect(sel.contains(31), isFalse);

      final ref = sel.toReference();
      expect(ref.book, 'Romans');
      expect(ref.chapter, 8);
      expect(ref.verseStart, 28);
      expect(ref.verseEnd, 30);
    });
  });

  group('VerseSelectionNotifier Selection Mechanics', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is null', () {
      final state = container.read(verseSelectionProvider);
      expect(state, isNull);
    });

    test('tapping a verse creates single-verse selection', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 16);

      final state = container.read(verseSelectionProvider);
      expect(state, isNotNull);
      expect(state!.book, 'John');
      expect(state.chapter, 3);
      expect(state.verseStart, 16);
      expect(state.verseEnd, 16);
    });

    test('tapping single selected verse toggles it off (clears)', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 16);
      expect(container.read(verseSelectionProvider), isNotNull);

      // Tap again
      notifier.toggleVerse('John', 3, 16);
      expect(container.read(verseSelectionProvider), isNull);
    });

    test('tapping adjacent forward verse extends the range forward', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 16);
      notifier.toggleVerse('John', 3, 17);

      final state1 = container.read(verseSelectionProvider);
      expect(state1!.verseStart, 16);
      expect(state1.verseEnd, 17);
      expect(state1.displayLabel, 'John 3:16-17');

      // Extend again
      notifier.toggleVerse('John', 3, 18);
      final state2 = container.read(verseSelectionProvider);
      expect(state2!.verseStart, 16);
      expect(state2.verseEnd, 18);
    });

    test('tapping adjacent backward verse extends the range backward', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 16);
      notifier.toggleVerse('John', 3, 15);

      final state = container.read(verseSelectionProvider);
      expect(state!.verseStart, 15);
      expect(state.verseEnd, 16);
      expect(state.displayLabel, 'John 3:15-16');
    });

    test('tapping verseStart of multi-verse range shrinks from start', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 15);
      notifier.toggleVerse('John', 3, 16);
      notifier.toggleVerse('John', 3, 17);

      expect(container.read(verseSelectionProvider)!.verseStart, 15);
      expect(container.read(verseSelectionProvider)!.verseEnd, 17);

      // Shrink from start
      notifier.toggleVerse('John', 3, 15);
      final state = container.read(verseSelectionProvider);
      expect(state!.verseStart, 16);
      expect(state.verseEnd, 17);
    });

    test('tapping verseEnd of multi-verse range shrinks from end', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 15);
      notifier.toggleVerse('John', 3, 16);
      notifier.toggleVerse('John', 3, 17);

      // Shrink from end
      notifier.toggleVerse('John', 3, 17);
      final state = container.read(verseSelectionProvider);
      expect(state!.verseStart, 15);
      expect(state.verseEnd, 16);
    });

    test('tapping non-adjacent verse resets to fresh single verse', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 15);
      notifier.toggleVerse('John', 3, 16);

      // Jump to verse 20
      notifier.toggleVerse('John', 3, 20);
      final state = container.read(verseSelectionProvider);
      expect(state!.verseStart, 20);
      expect(state.verseEnd, 20);
      expect(state.displayLabel, 'John 3:20');
    });

    test('tapping middle verse in range of 3+ verses restarts at that verse', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 14);
      notifier.toggleVerse('John', 3, 15);
      notifier.toggleVerse('John', 3, 16);

      expect(container.read(verseSelectionProvider)!.displayLabel, 'John 3:14-16');

      // Tap middle verse 15
      notifier.toggleVerse('John', 3, 15);
      final state = container.read(verseSelectionProvider);
      expect(state!.verseStart, 15);
      expect(state.verseEnd, 15);
      expect(state.displayLabel, 'John 3:15');
    });

    test('navigating to different book or chapter resets selection', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('John', 3, 16);

      // Same verse number but chapter 4
      notifier.toggleVerse('John', 4, 16);
      final state1 = container.read(verseSelectionProvider);
      expect(state1!.chapter, 4);
      expect(state1.verseStart, 16);
      expect(state1.verseEnd, 16);

      // Different book
      notifier.toggleVerse('Genesis', 1, 1);
      final state2 = container.read(verseSelectionProvider);
      expect(state2!.book, 'Genesis');
      expect(state2.chapter, 1);
      expect(state2.verseStart, 1);
      expect(state2.verseEnd, 1);
    });

    test('explicit clear resets state to null', () {
      final notifier = container.read(verseSelectionProvider.notifier);
      notifier.toggleVerse('Genesis', 1, 1);
      expect(container.read(verseSelectionProvider), isNotNull);

      notifier.clear();
      expect(container.read(verseSelectionProvider), isNull);
    });
  });
}
