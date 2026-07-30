// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  pushEnabled: json['push_enabled'] as bool,
  emailEnabled: json['email_enabled'] as bool,
  dmAlerts: json['dm_alerts'] as bool,
  newFollowerAlerts: json['new_follower_alerts'] as bool,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'push_enabled': instance.pushEnabled,
  'email_enabled': instance.emailEnabled,
  'dm_alerts': instance.dmAlerts,
  'new_follower_alerts': instance.newFollowerAlerts,
};
