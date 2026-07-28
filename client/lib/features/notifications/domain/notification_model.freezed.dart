// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationItem {

@JsonKey(name: 'id') String? get id;@JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) NotifType? get type;@JsonKey(name: 'is_realtime') bool? get isRealtime;@JsonKey(name: 'is_read') bool? get isRead;@JsonKey(name: 'body') String? get body;@JsonKey(name: 'ref_id') String? get refId;@JsonKey(name: 'actor_handle') String? get actorHandle;@JsonKey(name: 'actor_avatar') String? get actorAvatar;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRealtime, isRealtime) || other.isRealtime == isRealtime)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.body, body) || other.body == body)&&(identical(other.refId, refId) || other.refId == refId)&&(identical(other.actorHandle, actorHandle) || other.actorHandle == actorHandle)&&(identical(other.actorAvatar, actorAvatar) || other.actorAvatar == actorAvatar)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,isRealtime,isRead,body,refId,actorHandle,actorAvatar,createdAt);

@override
String toString() {
  return 'NotificationItem(id: $id, type: $type, isRealtime: $isRealtime, isRead: $isRead, body: $body, refId: $refId, actorHandle: $actorHandle, actorAvatar: $actorAvatar, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) NotifType? type,@JsonKey(name: 'is_realtime') bool? isRealtime,@JsonKey(name: 'is_read') bool? isRead,@JsonKey(name: 'body') String? body,@JsonKey(name: 'ref_id') String? refId,@JsonKey(name: 'actor_handle') String? actorHandle,@JsonKey(name: 'actor_avatar') String? actorAvatar,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? type = freezed,Object? isRealtime = freezed,Object? isRead = freezed,Object? body = freezed,Object? refId = freezed,Object? actorHandle = freezed,Object? actorAvatar = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotifType?,isRealtime: freezed == isRealtime ? _self.isRealtime : isRealtime // ignore: cast_nullable_to_non_nullable
as bool?,isRead: freezed == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,actorHandle: freezed == actorHandle ? _self.actorHandle : actorHandle // ignore: cast_nullable_to_non_nullable
as String?,actorAvatar: freezed == actorAvatar ? _self.actorAvatar : actorAvatar // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert)  NotifType? type, @JsonKey(name: 'is_realtime')  bool? isRealtime, @JsonKey(name: 'is_read')  bool? isRead, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'actor_handle')  String? actorHandle, @JsonKey(name: 'actor_avatar')  String? actorAvatar, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.type,_that.isRealtime,_that.isRead,_that.body,_that.refId,_that.actorHandle,_that.actorAvatar,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert)  NotifType? type, @JsonKey(name: 'is_realtime')  bool? isRealtime, @JsonKey(name: 'is_read')  bool? isRead, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'actor_handle')  String? actorHandle, @JsonKey(name: 'actor_avatar')  String? actorAvatar, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.type,_that.isRealtime,_that.isRead,_that.body,_that.refId,_that.actorHandle,_that.actorAvatar,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String? id, @JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert)  NotifType? type, @JsonKey(name: 'is_realtime')  bool? isRealtime, @JsonKey(name: 'is_read')  bool? isRead, @JsonKey(name: 'body')  String? body, @JsonKey(name: 'ref_id')  String? refId, @JsonKey(name: 'actor_handle')  String? actorHandle, @JsonKey(name: 'actor_avatar')  String? actorAvatar, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.type,_that.isRealtime,_that.isRead,_that.body,_that.refId,_that.actorHandle,_that.actorAvatar,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationItem extends NotificationItem {
  const _NotificationItem({@JsonKey(name: 'id') this.id, @JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) this.type, @JsonKey(name: 'is_realtime') this.isRealtime, @JsonKey(name: 'is_read') this.isRead, @JsonKey(name: 'body') this.body, @JsonKey(name: 'ref_id') this.refId, @JsonKey(name: 'actor_handle') this.actorHandle, @JsonKey(name: 'actor_avatar') this.actorAvatar, @JsonKey(name: 'created_at') this.createdAt}): super._();
  factory _NotificationItem.fromJson(Map<String, dynamic> json) => _$NotificationItemFromJson(json);

@override@JsonKey(name: 'id') final  String? id;
@override@JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) final  NotifType? type;
@override@JsonKey(name: 'is_realtime') final  bool? isRealtime;
@override@JsonKey(name: 'is_read') final  bool? isRead;
@override@JsonKey(name: 'body') final  String? body;
@override@JsonKey(name: 'ref_id') final  String? refId;
@override@JsonKey(name: 'actor_handle') final  String? actorHandle;
@override@JsonKey(name: 'actor_avatar') final  String? actorAvatar;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRealtime, isRealtime) || other.isRealtime == isRealtime)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.body, body) || other.body == body)&&(identical(other.refId, refId) || other.refId == refId)&&(identical(other.actorHandle, actorHandle) || other.actorHandle == actorHandle)&&(identical(other.actorAvatar, actorAvatar) || other.actorAvatar == actorAvatar)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,isRealtime,isRead,body,refId,actorHandle,actorAvatar,createdAt);

@override
String toString() {
  return 'NotificationItem(id: $id, type: $type, isRealtime: $isRealtime, isRead: $isRead, body: $body, refId: $refId, actorHandle: $actorHandle, actorAvatar: $actorAvatar, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String? id,@JsonKey(name: 'type', unknownEnumValue: NotifType.adminAlert) NotifType? type,@JsonKey(name: 'is_realtime') bool? isRealtime,@JsonKey(name: 'is_read') bool? isRead,@JsonKey(name: 'body') String? body,@JsonKey(name: 'ref_id') String? refId,@JsonKey(name: 'actor_handle') String? actorHandle,@JsonKey(name: 'actor_avatar') String? actorAvatar,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? type = freezed,Object? isRealtime = freezed,Object? isRead = freezed,Object? body = freezed,Object? refId = freezed,Object? actorHandle = freezed,Object? actorAvatar = freezed,Object? createdAt = freezed,}) {
  return _then(_NotificationItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotifType?,isRealtime: freezed == isRealtime ? _self.isRealtime : isRealtime // ignore: cast_nullable_to_non_nullable
as bool?,isRead: freezed == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,actorHandle: freezed == actorHandle ? _self.actorHandle : actorHandle // ignore: cast_nullable_to_non_nullable
as String?,actorAvatar: freezed == actorAvatar ? _self.actorAvatar : actorAvatar // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$NotificationResponse {

 List<NotificationItem> get notifications;@JsonKey(name: 'has_unread') bool get hasUnread;
/// Create a copy of NotificationResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationResponseCopyWith<NotificationResponse> get copyWith => _$NotificationResponseCopyWithImpl<NotificationResponse>(this as NotificationResponse, _$identity);

  /// Serializes this NotificationResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationResponse&&const DeepCollectionEquality().equals(other.notifications, notifications)&&(identical(other.hasUnread, hasUnread) || other.hasUnread == hasUnread));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(notifications),hasUnread);

@override
String toString() {
  return 'NotificationResponse(notifications: $notifications, hasUnread: $hasUnread)';
}


}

/// @nodoc
abstract mixin class $NotificationResponseCopyWith<$Res>  {
  factory $NotificationResponseCopyWith(NotificationResponse value, $Res Function(NotificationResponse) _then) = _$NotificationResponseCopyWithImpl;
@useResult
$Res call({
 List<NotificationItem> notifications,@JsonKey(name: 'has_unread') bool hasUnread
});




}
/// @nodoc
class _$NotificationResponseCopyWithImpl<$Res>
    implements $NotificationResponseCopyWith<$Res> {
  _$NotificationResponseCopyWithImpl(this._self, this._then);

  final NotificationResponse _self;
  final $Res Function(NotificationResponse) _then;

/// Create a copy of NotificationResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? notifications = null,Object? hasUnread = null,}) {
  return _then(_self.copyWith(
notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationItem>,hasUnread: null == hasUnread ? _self.hasUnread : hasUnread // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationResponse].
extension NotificationResponsePatterns on NotificationResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationResponse value)  $default,){
final _that = this;
switch (_that) {
case _NotificationResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationResponse value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<NotificationItem> notifications, @JsonKey(name: 'has_unread')  bool hasUnread)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationResponse() when $default != null:
return $default(_that.notifications,_that.hasUnread);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<NotificationItem> notifications, @JsonKey(name: 'has_unread')  bool hasUnread)  $default,) {final _that = this;
switch (_that) {
case _NotificationResponse():
return $default(_that.notifications,_that.hasUnread);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<NotificationItem> notifications, @JsonKey(name: 'has_unread')  bool hasUnread)?  $default,) {final _that = this;
switch (_that) {
case _NotificationResponse() when $default != null:
return $default(_that.notifications,_that.hasUnread);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationResponse implements NotificationResponse {
  const _NotificationResponse({required final  List<NotificationItem> notifications, @JsonKey(name: 'has_unread') required this.hasUnread}): _notifications = notifications;
  factory _NotificationResponse.fromJson(Map<String, dynamic> json) => _$NotificationResponseFromJson(json);

 final  List<NotificationItem> _notifications;
@override List<NotificationItem> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override@JsonKey(name: 'has_unread') final  bool hasUnread;

/// Create a copy of NotificationResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationResponseCopyWith<_NotificationResponse> get copyWith => __$NotificationResponseCopyWithImpl<_NotificationResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationResponse&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&(identical(other.hasUnread, hasUnread) || other.hasUnread == hasUnread));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notifications),hasUnread);

@override
String toString() {
  return 'NotificationResponse(notifications: $notifications, hasUnread: $hasUnread)';
}


}

/// @nodoc
abstract mixin class _$NotificationResponseCopyWith<$Res> implements $NotificationResponseCopyWith<$Res> {
  factory _$NotificationResponseCopyWith(_NotificationResponse value, $Res Function(_NotificationResponse) _then) = __$NotificationResponseCopyWithImpl;
@override @useResult
$Res call({
 List<NotificationItem> notifications,@JsonKey(name: 'has_unread') bool hasUnread
});




}
/// @nodoc
class __$NotificationResponseCopyWithImpl<$Res>
    implements _$NotificationResponseCopyWith<$Res> {
  __$NotificationResponseCopyWithImpl(this._self, this._then);

  final _NotificationResponse _self;
  final $Res Function(_NotificationResponse) _then;

/// Create a copy of NotificationResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? notifications = null,Object? hasUnread = null,}) {
  return _then(_NotificationResponse(
notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationItem>,hasUnread: null == hasUnread ? _self.hasUnread : hasUnread // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
