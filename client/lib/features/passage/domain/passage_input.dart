import '../../posts/domain/scripture_ref.dart';
import 'passage_models.dart';

/// Value object representing input for an individual passage deck panel.
class CreatePassagePanelInput {
  final String panelType;
  final Map<String, dynamic> content;
  final String? backgroundImageUrl;
  final ScriptureRef? scriptureRef;

  const CreatePassagePanelInput({
    required this.panelType,
    required this.content,
    this.backgroundImageUrl,
    this.scriptureRef,
  });

  Map<String, dynamic> toPayload() {
    Map<String, dynamic>? scriptureMap;
    if (scriptureRef != null) {
      scriptureMap = {
        'book': scriptureRef!.book,
        'chapter': scriptureRef!.chapter,
        'verse_start': scriptureRef!.verseStart,
        if (scriptureRef!.verseEnd != null)
          'verse_end': scriptureRef!.verseEnd,
      };
    }

    final payload = <String, dynamic>{
      'panel_type': panelType,
      'content': content,
    };
    if (backgroundImageUrl != null && backgroundImageUrl!.isNotEmpty) {
      payload['background_image_url'] = backgroundImageUrl;
    }
    if (scriptureMap != null) {
      payload['scripture_ref'] = scriptureMap;
    }
    return payload;
  }
}

/// Value object representing input required to publish an immutable multi-panel Passage deck.
class CreatePassageInput {
  final String title;
  final List<CreatePassagePanelInput> panels;
  final SoundTrack? sound;

  const CreatePassageInput({
    required this.title,
    required this.panels,
    this.sound,
  });

  bool get isValid => panels.length >= 2 && panels.length <= 12;

  Map<String, dynamic> toPayload() {
    final resolvedTitle =
        title.trim().isNotEmpty ? title.trim() : 'Devotional Passage';

    String excerpt = resolvedTitle;
    if (panels.isNotEmpty) {
      final firstContent = panels.first.content;
      if (firstContent['text'] != null &&
          firstContent['text'].toString().trim().isNotEmpty) {
        excerpt = firstContent['text'].toString().trim();
      } else if (firstContent['caption'] != null &&
          firstContent['caption'].toString().trim().isNotEmpty) {
        excerpt = firstContent['caption'].toString().trim();
      }
    }

    String? firstImageUrl;
    for (final p in panels) {
      if (p.backgroundImageUrl != null && p.backgroundImageUrl!.trim().isNotEmpty) {
        firstImageUrl = p.backgroundImageUrl!.trim();
        break;
      }
      final img = p.content['image_url'] ?? p.content['imageUrl'] ?? p.content['url'];
      if (img != null && img.toString().trim().isNotEmpty) {
        firstImageUrl = img.toString().trim();
        break;
      }
    }

    final panelPayloads = panels.map((p) => p.toPayload()).toList();

    return {
      'post_type': 'passage',
      'content': {
        'title': resolvedTitle,
        'body': [
          {'insert': '$resolvedTitle\n'}
        ],
        'excerpt': excerpt,
        'image_url': ?firstImageUrl,
        'cover_image_url': ?firstImageUrl,
        'panels': panelPayloads,
      },
      'panels': panelPayloads,
      if (sound != null) 'sound_id': sound!.id,
      'visibility': 'public',
    };
  }
}
