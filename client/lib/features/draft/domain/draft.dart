import 'package:freezed_annotation/freezed_annotation.dart';
import '../../posts/domain/sermon_source.dart';
import 'dart:convert';

part 'draft.freezed.dart';
part 'draft.g.dart';

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
abstract class Draft with _$Draft {
  const factory Draft({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(fromJson: _contentFromJson) required Map<String, dynamic> content,
    String? caption,
    @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,
    @JsonKey(name: 'scripture_tags') @Default([]) List<String> scriptureTags,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);
}
