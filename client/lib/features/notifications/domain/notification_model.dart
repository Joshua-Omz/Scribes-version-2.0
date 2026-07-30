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
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'ids') List<String>? ids,
    @JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) NotifType? type,
    @JsonKey(name: 'is_realtime') bool? isRealtime,
    @JsonKey(name: 'is_read') bool? isRead,
    @JsonKey(name: 'body') String? body,
    @JsonKey(name: 'ref_id') String? refId,
    @JsonKey(name: 'actor_handle') String? actorHandle,
    @JsonKey(name: 'actor_avatar') String? actorAvatar,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  bool get showRealtimeAccent => isRealtime ?? false;
  bool get safeIsRead => isRead ?? false;
  String get safeBody => body ?? '';
  String get safeRefId => refId ?? '';
  DateTime get safeCreatedAt => createdAt ?? DateTime.now();
  String get safeId => id ?? '';
  List<String> get safeIds => ids ?? (id != null ? [id!] : []);
  NotifType get safeType => type ?? NotifType.adminAlert;
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
