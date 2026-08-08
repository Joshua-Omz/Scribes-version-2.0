// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  authorId: json['author_id'] as String,
  content: _contentFromJson(json['content']),
  caption: json['caption'] as String?,
  visibility: json['visibility'] as String,
  currentVersion: (json['current_version'] as num).toInt(),
  isCorrection: json['is_correction'] as bool,
  correctsPostId: json['corrects_post_id'] as String?,
  sermonSource: _sermonSourceFromJson(json['sermon_source']),
  scriptureRefs:
      (json['scripture_refs'] as List<dynamic>?)
          ?.map((e) => ScriptureRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isDeleted: json['is_deleted'] as bool,
  coverImageUrl: json['cover_image_url'] as String?,
  postType: json['post_type'] as String? ?? 'standard',
  publishedAt: DateTime.parse(json['published_at'] as String),
  authorHandle: json['author_handle'] as String,
  authorName: json['author_name'] as String,
  authorAvatarUrl: json['author_avatar_url'] as String?,
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'content': instance.content,
  'caption': instance.caption,
  'visibility': instance.visibility,
  'current_version': instance.currentVersion,
  'is_correction': instance.isCorrection,
  'corrects_post_id': instance.correctsPostId,
  'sermon_source': instance.sermonSource,
  'scripture_refs': instance.scriptureRefs,
  'tags': instance.tags,
  'is_deleted': instance.isDeleted,
  'cover_image_url': instance.coverImageUrl,
  'post_type': instance.postType,
  'published_at': instance.publishedAt.toIso8601String(),
  'author_handle': instance.authorHandle,
  'author_name': instance.authorName,
  'author_avatar_url': instance.authorAvatarUrl,
};
