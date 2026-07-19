// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  authorId: json['author_id'] as String,
  content: _contentFromJson(json['content']),
  title: json['title'] as String?,
  notebookId: json['notebook_id'] as String?,
  updatedAt: DateTime.parse(json['updated_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'content': instance.content,
  'title': instance.title,
  'notebook_id': instance.notebookId,
  'updated_at': instance.updatedAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};
