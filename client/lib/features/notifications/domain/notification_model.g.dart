// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String?,
      type: $enumDecodeNullable(
        _$NotifTypeEnumMap,
        json['type'],
        unknownValue: NotifType.adminAlert,
      ),
      isRealtime: json['is_realtime'] as bool?,
      isRead: json['is_read'] as bool?,
      body: json['body'] as String?,
      refId: json['ref_id'] as String?,
      actorHandle: json['actor_handle'] as String?,
      actorAvatar: json['actor_avatar'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$NotifTypeEnumMap[instance.type],
      'is_realtime': instance.isRealtime,
      'is_read': instance.isRead,
      'body': instance.body,
      'ref_id': instance.refId,
      'actor_handle': instance.actorHandle,
      'actor_avatar': instance.actorAvatar,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$NotifTypeEnumMap = {
  NotifType.mention: 'mention',
  NotifType.reaction: 'reaction',
  NotifType.comment: 'comment',
  NotifType.follow: 'follow',
  NotifType.adminAlert: 'admin_alert',
};

_NotificationResponse _$NotificationResponseFromJson(
  Map<String, dynamic> json,
) => _NotificationResponse(
  notifications: (json['notifications'] as List<dynamic>)
      .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  hasUnread: json['has_unread'] as bool,
);

Map<String, dynamic> _$NotificationResponseToJson(
  _NotificationResponse instance,
) => <String, dynamic>{
  'notifications': instance.notifications,
  'has_unread': instance.hasUnread,
};
