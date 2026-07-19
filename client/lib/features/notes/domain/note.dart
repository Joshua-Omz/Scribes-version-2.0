import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'note.freezed.dart';
part 'note.g.dart';

Map<String, dynamic> _contentFromJson(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
  }
  return {'body': value};
}

@freezed
abstract class Note with _$Note {
  const factory Note({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    @JsonKey(fromJson: _contentFromJson) required Map<String, dynamic> content,
    String? title,
    @JsonKey(name: 'notebook_id') String? notebookId,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
