// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_version.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostVersion _$PostVersionFromJson(Map<String, dynamic> json) => _PostVersion(
  id: json['id'] as String,
  postId: json['post_id'] as String,
  versionNumber: (json['version_number'] as num).toInt(),
  contentSnapshot: json['content_snapshot'] as Map<String, dynamic>,
  snapshottedAt: DateTime.parse(json['snapshotted_at'] as String),
  snapshottedBy: json['snapshotted_by'] as String,
);

Map<String, dynamic> _$PostVersionToJson(_PostVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'version_number': instance.versionNumber,
      'content_snapshot': instance.contentSnapshot,
      'snapshotted_at': instance.snapshottedAt.toIso8601String(),
      'snapshotted_by': instance.snapshottedBy,
    };
