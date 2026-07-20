import 'package:freezed_annotation/freezed_annotation.dart';
import 'sermon_source.dart';
import 'scripture_ref.dart';
import 'dart:convert';

part 'post.freezed.dart';
part 'post.g.dart';

Map<String, dynamic> _contentFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
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
      if (decoded is Map<String, dynamic>) return SermonSource.fromJson(decoded);
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
    @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,
    @JsonKey(name: 'scripture_refs') @Default([]) List<ScriptureRef> scriptureRefs,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    
    // Joined author fields
    @JsonKey(name: 'author_handle') required String authorHandle,
    @JsonKey(name: 'author_name') required String authorName,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
