// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Draft _$DraftFromJson(Map<String, dynamic> json) => _Draft(
  id: json['id'] as String,
  authorId: json['author_id'] as String,
  content: _contentFromJson(json['content']),
  caption: json['caption'] as String?,
  sermonSource: _sermonSourceFromJson(json['sermon_source']),
  scriptureTags:
      (json['scripture_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  postType: json['post_type'] as String? ?? 'standard',
  coverImageUrl: json['cover_image_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DraftToJson(_Draft instance) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'content': instance.content,
  'caption': instance.caption,
  'sermon_source': instance.sermonSource,
  'scripture_tags': instance.scriptureTags,
  'post_type': instance.postType,
  'cover_image_url': instance.coverImageUrl,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
