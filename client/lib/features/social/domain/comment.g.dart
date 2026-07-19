// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  authorId: json['author_id'] as String,
  body: json['body'] as String,
  mentions:
      (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  isHidden: json['is_hidden'] as bool,
  isDeleted: json['is_deleted'] as bool,
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'post_id': instance.postId,
  'author_id': instance.authorId,
  'body': instance.body,
  'mentions': instance.mentions,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'is_hidden': instance.isHidden,
  'is_deleted': instance.isDeleted,
};
