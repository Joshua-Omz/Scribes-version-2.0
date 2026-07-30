import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences.freezed.dart';
part 'notification_preferences.g.dart';

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @JsonKey(name: 'push_enabled') required bool pushEnabled,
    @JsonKey(name: 'email_enabled') required bool emailEnabled,
    @JsonKey(name: 'dm_alerts') required bool dmAlerts,
    @JsonKey(name: 'new_follower_alerts') required bool newFollowerAlerts,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);
}
