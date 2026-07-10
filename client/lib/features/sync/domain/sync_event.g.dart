// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncEvent _$SyncEventFromJson(Map<String, dynamic> json) => _SyncEvent(
  type: json['type'] as String,
  id: json['id'] as String,
  content: json['content'] as Map<String, dynamic>,
  titleOrCaption: json['title_or_caption'] as String?,
  parentId: json['parent_id'] as String?,
  serverSequence: (json['server_sequence'] as num).toInt(),
  timestamp: DateTime.parse(json['ts'] as String),
);

Map<String, dynamic> _$SyncEventToJson(_SyncEvent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'id': instance.id,
      'content': instance.content,
      'title_or_caption': instance.titleOrCaption,
      'parent_id': instance.parentId,
      'server_sequence': instance.serverSequence,
      'ts': instance.timestamp.toIso8601String(),
    };
