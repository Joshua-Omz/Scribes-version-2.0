import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotifType {
  @JsonValue('mention')
  mention,
  @JsonValue('reaction')
  reaction,
  @JsonValue('comment')
  comment,
  @JsonValue('follow')
  follow,
  @JsonValue('admin_alert')
  adminAlert,
}

@freezed
abstract class NotificationItem with _$NotificationItem {
  const NotificationItem._();

  const factory NotificationItem({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'type') required NotifType type,
    @JsonKey(name: 'is_realtime') required bool isRealtime,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'body') required String body,
    @JsonKey(name: 'ref_id') required String refId,
    @JsonKey(name: 'actor_handle') String? actorHandle,
    @JsonKey(name: 'actor_avatar') String? actorAvatar,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  bool get showRealtimeAccent => isRealtime;
}

@freezed
abstract class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required List<NotificationItem> notifications,
    @JsonKey(name: 'has_unread') required bool hasUnread,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
