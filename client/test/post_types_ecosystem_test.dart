import 'package:flutter_test/flutter_test.dart';
import 'package:scribes/features/passage/domain/passage_models.dart';
import 'package:scribes/features/passage/domain/passage_input.dart';
import 'package:scribes/features/reflection/domain/reflection_models.dart';
import 'package:scribes/features/posts/domain/scripture_ref.dart';

void main() {
  group('PassagePanel JSON Deserialization Hardening', () {
    test('parses normal Map content successfully', () {
      final json = {
        'id': 'panel-1',
        'post_id': 'post-1',
        'panel_order': 0,
        'panel_type': 'text',
        'content': {'text': 'Devotional teaching', 'ops': []},
      };

      final panel = PassagePanel.fromJson(json);
      expect(panel.id, 'panel-1');
      expect(panel.panelType, 'text');
      expect(panel.content['text'], 'Devotional teaching');
    });

    test('defensively parses serialized JSON string content without TypeError', () {
      final json = {
        'id': 'panel-2',
        'post_id': 'post-1',
        'panel_order': 1,
        'panel_type': 'scripture',
        'content': '{"text": "In the beginning was the Word", "translation": "BSB"}',
      };

      final panel = PassagePanel.fromJson(json);
      expect(panel.id, 'panel-2');
      expect(panel.panelType, 'scripture');
      expect(panel.content['text'], 'In the beginning was the Word');
      expect(panel.content['translation'], 'BSB');
    });

    test('defensively handles raw string content gracefully', () {
      final json = {
        'id': 'panel-3',
        'post_id': 'post-1',
        'panel_order': 2,
        'panel_type': 'text',
        'content': 'Plain unformatted text string',
      };

      final panel = PassagePanel.fromJson(json);
      expect(panel.content['text'], 'Plain unformatted text string');
    });

    test('defensively parses serialized scripture_ref string', () {
      final json = {
        'id': 'panel-4',
        'post_id': 'post-1',
        'panel_order': 3,
        'panel_type': 'scripture',
        'content': {},
        'scripture_ref': '{"book": "John", "chapter": 1, "verse_start": 1}',
      };

      final panel = PassagePanel.fromJson(json);
      expect(panel.scriptureRef, isNotNull);
      expect(panel.scriptureRef!['book'], 'John');
      expect(panel.scriptureRef!['chapter'], 1);
    });

    test('defaults empty or null content to empty Map', () {
      final json = {
        'id': 'panel-5',
        'post_id': 'post-1',
        'panel_order': 4,
        'panel_type': 'reflection',
        'content': null,
      };

      final panel = PassagePanel.fromJson(json);
      expect(panel.content, isEmpty);
    });
  });

  group('CreateReflectionInput Value Object', () {
    test('validates 500-character constraint strictly', () {
      const valid500 = CreateReflectionInput(
        body: 'A short, focused contemplation on grace and restoration.',
      );
      expect(valid500.isValid, isTrue);

      const empty = CreateReflectionInput(body: '   ');
      expect(empty.isValid, isFalse);

      final over500 = CreateReflectionInput(
        body: 'a' * 501,
      );
      expect(over500.isValid, isFalse);
    });

    test('builds compliant reflection payload with Quill Delta body', () {
      const input = CreateReflectionInput(
        body: 'Be still and know that I am God.',
        scriptureRef: ScriptureRef(
          book: 'Psalm',
          chapter: 46,
          verseStart: 10,
        ),
        uploadedImageUrl: 'https://cdn.scribes.app/reflections/photo1.jpg',
      );

      final payload = input.toPayload();
      expect(payload['post_type'], 'reflection');
      expect(payload['visibility'], 'public');
      expect(payload['reflection_image_url'], 'https://cdn.scribes.app/reflections/photo1.jpg');

      final content = payload['content'] as Map<String, dynamic>;
      expect(content['excerpt'], 'Be still and know that I am God.');
      final body = content['body'] as List<dynamic>;
      expect(body.first['insert'], 'Be still and know that I am God.\n');

      final scriptureRefs = payload['scripture_refs'] as List<dynamic>;
      expect(scriptureRefs.length, 1);
      expect(scriptureRefs.first['book'], 'Psalm');
      expect(scriptureRefs.first['chapter'], 46);
      expect(scriptureRefs.first['verse_start'], 10);
    });
  });

  group('CreatePassageInput Value Object', () {
    test('validates 2 to 12 panel boundary conditions', () {
      final panel = CreatePassagePanelInput(
        panelType: 'text',
        content: {'text': 'Panel 1'},
      );

      final singlePanel = CreatePassageInput(
        title: 'Too Short',
        panels: [panel],
      );
      expect(singlePanel.isValid, isFalse);

      final validDeck = CreatePassageInput(
        title: 'Valid Devotional Deck',
        panels: [panel, panel],
      );
      expect(validDeck.isValid, isTrue);

      final tooManyDeck = CreatePassageInput(
        title: 'Too Many',
        panels: List.generate(13, (_) => panel),
      );
      expect(tooManyDeck.isValid, isFalse);
    });

    test('toPayload correctly sets post_type: passage and panel items', () {
      final input = CreatePassageInput(
        title: 'Creation Meditation',
        panels: [
          const CreatePassagePanelInput(
            panelType: 'scripture',
            content: {
              'text': 'In the beginning God created the heavens and the earth.',
              'translation': 'BSB',
              'reference': 'Genesis 1:1',
              'attribution': 'Berean Standard Bible, public domain',
            },
            scriptureRef: ScriptureRef(
              book: 'Genesis',
              chapter: 1,
              verseStart: 1,
            ),
          ),
          const CreatePassagePanelInput(
            panelType: 'reflection',
            content: {
              'text': 'Notice how stillness preceded the spoken Word.',
            },
          ),
        ],
      );

      final payload = input.toPayload();
      expect(payload['post_type'], 'passage');
      expect(payload['visibility'], 'public');

      final panels = payload['panels'] as List<dynamic>;
      expect(panels.length, 2);
      expect(panels[0]['panel_type'], 'scripture');
      expect(panels[0]['content']['text'], 'In the beginning God created the heavens and the earth.');
      expect(panels[0]['content']['translation'], 'BSB');
      expect(panels[1]['panel_type'], 'reflection');
    });
  });
}
