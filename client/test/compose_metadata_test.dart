import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/features/compose/application/compose_provider.dart';
import 'package:scribes/features/posts/domain/scripture_ref.dart';

void main() {
  group('Compose Scripture References Decoupling', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('note-level scriptureRefs is unbounded and accepts more than 3 references', () {
      final notifier = container.read(composeProvider.notifier);

      final ref1 = ScriptureRef(book: 'John', chapter: 3, verseStart: 16);
      final ref2 = ScriptureRef(book: 'Romans', chapter: 8, verseStart: 28);
      final ref3 = ScriptureRef(book: 'Genesis', chapter: 1, verseStart: 1);
      final ref4 = ScriptureRef(book: 'Psalms', chapter: 23, verseStart: 1);
      final ref5 = ScriptureRef(book: 'Proverbs', chapter: 3, verseStart: 5);

      notifier.addScriptureRef(ref1);
      notifier.addScriptureRef(ref2);
      notifier.addScriptureRef(ref3);
      notifier.addScriptureRef(ref4);
      notifier.addScriptureRef(ref5);

      final state = container.read(composeProvider);
      expect(state.scriptureRefs.length, 5);
      expect(state.scriptureRefs, containsAll([ref1, ref2, ref3, ref4, ref5]));
    });

    test('publishScriptureRefs strictly caps at 3 metadata tags', () {
      final notifier = container.read(composeProvider.notifier);

      final ref1 = ScriptureRef(book: 'John', chapter: 3, verseStart: 16);
      final ref2 = ScriptureRef(book: 'Romans', chapter: 8, verseStart: 28);
      final ref3 = ScriptureRef(book: 'Genesis', chapter: 1, verseStart: 1);
      final ref4 = ScriptureRef(book: 'Psalms', chapter: 23, verseStart: 1);

      notifier.addPublishScriptureRef(ref1);
      notifier.addPublishScriptureRef(ref2);
      notifier.addPublishScriptureRef(ref3);
      // Attempt to add a 4th reference to the publish envelope
      notifier.addPublishScriptureRef(ref4);

      final state = container.read(composeProvider);
      expect(state.publishScriptureRefs.length, 3);
      expect(state.publishScriptureRefs, containsAll([ref1, ref2, ref3]));
      expect(state.publishScriptureRefs, isNot(contains(ref4)));
    });

    test('setPublishScriptureRefs automatically truncates to at most 3', () {
      final notifier = container.read(composeProvider.notifier);

      final refs = [
        ScriptureRef(book: 'John', chapter: 1, verseStart: 1),
        ScriptureRef(book: 'John', chapter: 1, verseStart: 2),
        ScriptureRef(book: 'John', chapter: 1, verseStart: 3),
        ScriptureRef(book: 'John', chapter: 1, verseStart: 4),
        ScriptureRef(book: 'John', chapter: 1, verseStart: 5),
      ];

      notifier.setPublishScriptureRefs(refs);

      final state = container.read(composeProvider);
      expect(state.publishScriptureRefs.length, 3);
    });

    test('deleting a publish metadata tag does not delete from note scriptureRefs', () {
      final notifier = container.read(composeProvider.notifier);

      final ref1 = ScriptureRef(book: 'John', chapter: 3, verseStart: 16);
      final ref2 = ScriptureRef(book: 'Romans', chapter: 8, verseStart: 28);

      // Add to note
      notifier.addScriptureRef(ref1);
      notifier.addScriptureRef(ref2);

      // Seed publish metadata
      notifier.setPublishScriptureRefs([ref1, ref2]);

      expect(container.read(composeProvider).scriptureRefs.length, 2);
      expect(container.read(composeProvider).publishScriptureRefs.length, 2);

      // Remove from publish metadata only
      notifier.removePublishScriptureRef(ref1);

      final state = container.read(composeProvider);
      // Publish metadata is updated
      expect(state.publishScriptureRefs.length, 1);
      expect(state.publishScriptureRefs, contains(ref2));
      expect(state.publishScriptureRefs, isNot(contains(ref1)));

      // Note body retains all its original citations!
      expect(state.scriptureRefs.length, 2);
      expect(state.scriptureRefs, containsAll([ref1, ref2]));
    });
  });
}
