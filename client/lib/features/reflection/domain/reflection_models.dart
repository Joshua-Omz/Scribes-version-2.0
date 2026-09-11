import '../../posts/domain/scripture_ref.dart';

/// Value object representing input required to create an immutable Reflection post.
class CreateReflectionInput {
  final String body;
  final ScriptureRef? scriptureRef;
  final String? uploadedImageUrl;

  const CreateReflectionInput({
    required this.body,
    this.scriptureRef,
    this.uploadedImageUrl,
  });

  /// Maximum character limit for reflection contemplation text per Scribes spec.
  static const int maxCharacters = 500;

  bool get isValid {
    final len = body.trim().length;
    return len > 0 && len <= maxCharacters;
  }

  Map<String, dynamic> toPayload() {
    final trimmedBody = body.trim();
    final contentPayload = {
      'title': '',
      'excerpt': trimmedBody,
      'body': [
        {'insert': '$trimmedBody\n'}
      ],
    };

    final List<Map<String, dynamic>> scripturePayload = [];
    if (scriptureRef != null) {
      scripturePayload.add({
        'book': scriptureRef!.book,
        'chapter': scriptureRef!.chapter,
        'verse_start': scriptureRef!.verseStart,
        if (scriptureRef!.verseEnd != null)
          'verse_end': scriptureRef!.verseEnd,
      });
    }

    return {
      'post_type': 'reflection',
      'content': contentPayload,
      'visibility': 'public',
      if (uploadedImageUrl != null && uploadedImageUrl!.trim().isNotEmpty)
        'reflection_image_url': uploadedImageUrl,
      if (scripturePayload.isNotEmpty) 'scripture_refs': scripturePayload,
    };
  }
}
