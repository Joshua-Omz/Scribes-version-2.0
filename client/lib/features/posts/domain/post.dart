import 'package:freezed_annotation/freezed_annotation.dart';
import 'sermon_source.dart';
import 'scripture_ref.dart';
import 'dart:convert';

import '../../passage/domain/passage_models.dart';

part 'post.freezed.dart';
part 'post.g.dart';

Map<String, dynamic> _contentFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is String) {
        try {
          final doubleDecoded = jsonDecode(decoded);
          if (doubleDecoded is Map<String, dynamic>) return doubleDecoded;
        } catch (_) {}
      }
    } catch (_) {}
  }
  return {'title': 'Untitled', 'body': value, 'excerpt': ''};
}

SermonSource? _sermonSourceFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return SermonSource.fromJson(value);
  if (value is String) {
    if (value.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return SermonSource.fromJson(decoded);
      }
      if (decoded is String) {
        try {
          final doubleDecoded = jsonDecode(decoded);
          if (doubleDecoded is Map<String, dynamic>) {
            return SermonSource.fromJson(doubleDecoded);
          }
        } catch (_) {}
      }
    } catch (_) {}
    return SermonSource(preacher: value);
  }
  return null;
}

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(fromJson: _contentFromJson) required Map<String, dynamic> content,
    String? caption,
    required String visibility,
    @JsonKey(name: 'current_version') required int currentVersion,
    @JsonKey(name: 'is_correction') required bool isCorrection,
    @JsonKey(name: 'corrects_post_id') String? correctsPostId,
    @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)
    SermonSource? sermonSource,
    @JsonKey(name: 'scripture_refs')
    @Default([])
    List<ScriptureRef> scriptureRefs,
    @Default([]) List<String> tags,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'reflection_image_url') String? reflectionImageUrl,
    @JsonKey(name: 'sound_id') String? soundId,
    SoundTrack? sound,
    @Default([]) List<PassagePanel> panels,
    @JsonKey(name: 'post_type') @Default('standard') String postType,
    @JsonKey(name: 'published_at') required DateTime publishedAt,

    // Joined author fields
    @JsonKey(name: 'author_handle') required String authorHandle,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,

    // Aggregations from feed SQL
    @JsonKey(name: 'amen_count') @Default(0) int amenCount,
    @JsonKey(name: 'insight_count') @Default(0) int insightCount,
    @JsonKey(name: 'thought_provoking_count')
    @Default(0)
    int thoughtProvokingCount,
    @JsonKey(name: 'comment_count') @Default(0) int commentCount,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}

extension PostX on Post {
  /// Safely extracts the plain text body from Delta ops, JSON strings, or excerpts.
  String get plainTextBody {
    if (content['excerpt'] != null &&
        content['excerpt'].toString().trim().isNotEmpty) {
      return content['excerpt'].toString().trim();
    }
    final bodyData = content['body'];
    if (bodyData is String) {
      if (bodyData.trim().isNotEmpty) {
        try {
          final decoded = jsonDecode(bodyData);
          if (decoded is List) {
            final text = _extractTextFromDeltaList(decoded);
            if (text.isNotEmpty) return text;
          }
        } catch (_) {}
        return bodyData.trim();
      }
    } else if (bodyData is List) {
      final text = _extractTextFromDeltaList(bodyData);
      if (text.isNotEmpty) return text;
    } else if (bodyData is Map && bodyData['ops'] is List) {
      final text = _extractTextFromDeltaList(bodyData['ops'] as List);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _extractTextFromDeltaList(List<dynamic> ops) {
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) {
          buffer.write(insert);
        }
      }
    }
    return buffer.toString().trim();
  }
}
