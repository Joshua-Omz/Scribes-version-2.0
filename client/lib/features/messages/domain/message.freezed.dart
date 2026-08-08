// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageRequest {

 String get id;@JsonKey(name: 'from_user_id') String get fromUserId;@JsonKey(name: 'to_user_id') String get toUserId; String get status;@JsonKey(name: 'first_message') String get firstMessage;@JsonKey(name: 'created_at') DateTime get createdAt;
/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageRequestCopyWith<MessageRequest> get copyWith => _$MessageRequestCopyWithImpl<MessageRequest>(this as MessageRequest, _$identity);

  /// Serializes this MessageRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.firstMessage, firstMessage) || other.firstMessage == firstMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,status,firstMessage,createdAt);

@override
String toString() {
  return 'MessageRequest(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, status: $status, firstMessage: $firstMessage, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessageRequestCopyWith<$Res>  {
  factory $MessageRequestCopyWith(MessageRequest value, $Res Function(MessageRequest) _then) = _$MessageRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'from_user_id') String fromUserId,@JsonKey(name: 'to_user_id') String toUserId, String status,@JsonKey(name: 'first_message') String firstMessage,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class _$MessageRequestCopyWithImpl<$Res>
    implements $MessageRequestCopyWith<$Res> {
  _$MessageRequestCopyWithImpl(this._self, this._then);

  final MessageRequest _self;
  final $Res Function(MessageRequest) _then;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? status = null,Object? firstMessage = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,firstMessage: null == firstMessage ? _self.firstMessage : firstMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageRequest].
extension MessageRequestPatterns on MessageRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageRequest value)  $default,){
final _that = this;
switch (_that) {
case _MessageRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'from_user_id')  String fromUserId, @JsonKey(name: 'to_user_id')  String toUserId,  String status, @JsonKey(name: 'first_message')  String firstMessage, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.status,_that.firstMessage,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'from_user_id')  String fromUserId, @JsonKey(name: 'to_user_id')  String toUserId,  String status, @JsonKey(name: 'first_message')  String firstMessage, @JsonKey(name: 'created_at')  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MessageRequest():
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.status,_that.firstMessage,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'from_user_id')  String fromUserId, @JsonKey(name: 'to_user_id')  String toUserId,  String status, @JsonKey(name: 'first_message')  String firstMessage, @JsonKey(name: 'created_at')  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageRequest() when $default != null:
return $default(_that.id,_that.fromUserId,_that.toUserId,_that.status,_that.firstMessage,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageRequest implements MessageRequest {
  const _MessageRequest({required this.id, @JsonKey(name: 'from_user_id') required this.fromUserId, @JsonKey(name: 'to_user_id') required this.toUserId, required this.status, @JsonKey(name: 'first_message') required this.firstMessage, @JsonKey(name: 'created_at') required this.createdAt});
  factory _MessageRequest.fromJson(Map<String, dynamic> json) => _$MessageRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'from_user_id') final  String fromUserId;
@override@JsonKey(name: 'to_user_id') final  String toUserId;
@override final  String status;
@override@JsonKey(name: 'first_message') final  String firstMessage;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageRequestCopyWith<_MessageRequest> get copyWith => __$MessageRequestCopyWithImpl<_MessageRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.toUserId, toUserId) || other.toUserId == toUserId)&&(identical(other.status, status) || other.status == status)&&(identical(other.firstMessage, firstMessage) || other.firstMessage == firstMessage)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fromUserId,toUserId,status,firstMessage,createdAt);

@override
String toString() {
  return 'MessageRequest(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, status: $status, firstMessage: $firstMessage, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessageRequestCopyWith<$Res> implements $MessageRequestCopyWith<$Res> {
  factory _$MessageRequestCopyWith(_MessageRequest value, $Res Function(_MessageRequest) _then) = __$MessageRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'from_user_id') String fromUserId,@JsonKey(name: 'to_user_id') String toUserId, String status,@JsonKey(name: 'first_message') String firstMessage,@JsonKey(name: 'created_at') DateTime createdAt
});




}
/// @nodoc
class __$MessageRequestCopyWithImpl<$Res>
    implements _$MessageRequestCopyWith<$Res> {
  __$MessageRequestCopyWithImpl(this._self, this._then);

  final _MessageRequest _self;
  final $Res Function(_MessageRequest) _then;

/// Create a copy of MessageRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fromUserId = null,Object? toUserId = null,Object? status = null,Object? firstMessage = null,Object? createdAt = null,}) {
  return _then(_MessageRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,toUserId: null == toUserId ? _self.toUserId : toUserId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,firstMessage: null == firstMessage ? _self.firstMessage : firstMessage // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Conversation {

 String get id;@JsonKey(name: 'user_a_id') String get userAId;@JsonKey(name: 'user_b_id') String get userBId; bool get blocked;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'last_active') DateTime get lastActive;@JsonKey(name: 'unread_count') int get unreadCount;@JsonKey(name: 'user_a_last_read_at') DateTime? get userALastReadAt;@JsonKey(name: 'user_b_last_read_at') DateTime? get userBLastReadAt;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.userAId, userAId) || other.userAId == userAId)&&(identical(other.userBId, userBId) || other.userBId == userBId)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.userALastReadAt, userALastReadAt) || other.userALastReadAt == userALastReadAt)&&(identical(other.userBLastReadAt, userBLastReadAt) || other.userBLastReadAt == userBLastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userAId,userBId,blocked,createdAt,lastActive,unreadCount,userALastReadAt,userBLastReadAt);

@override
String toString() {
  return 'Conversation(id: $id, userAId: $userAId, userBId: $userBId, blocked: $blocked, createdAt: $createdAt, lastActive: $lastActive, unreadCount: $unreadCount, userALastReadAt: $userALastReadAt, userBLastReadAt: $userBLastReadAt)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_a_id') String userAId,@JsonKey(name: 'user_b_id') String userBId, bool blocked,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'last_active') DateTime lastActive,@JsonKey(name: 'unread_count') int unreadCount,@JsonKey(name: 'user_a_last_read_at') DateTime? userALastReadAt,@JsonKey(name: 'user_b_last_read_at') DateTime? userBLastReadAt
});




}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userAId = null,Object? userBId = null,Object? blocked = null,Object? createdAt = null,Object? lastActive = null,Object? unreadCount = null,Object? userALastReadAt = freezed,Object? userBLastReadAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userAId: null == userAId ? _self.userAId : userAId // ignore: cast_nullable_to_non_nullable
as String,userBId: null == userBId ? _self.userBId : userBId // ignore: cast_nullable_to_non_nullable
as String,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActive: null == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,userALastReadAt: freezed == userALastReadAt ? _self.userALastReadAt : userALastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userBLastReadAt: freezed == userBLastReadAt ? _self.userBLastReadAt : userBLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_a_id')  String userAId, @JsonKey(name: 'user_b_id')  String userBId,  bool blocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'last_active')  DateTime lastActive, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'user_a_last_read_at')  DateTime? userALastReadAt, @JsonKey(name: 'user_b_last_read_at')  DateTime? userBLastReadAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.userAId,_that.userBId,_that.blocked,_that.createdAt,_that.lastActive,_that.unreadCount,_that.userALastReadAt,_that.userBLastReadAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_a_id')  String userAId, @JsonKey(name: 'user_b_id')  String userBId,  bool blocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'last_active')  DateTime lastActive, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'user_a_last_read_at')  DateTime? userALastReadAt, @JsonKey(name: 'user_b_last_read_at')  DateTime? userBLastReadAt)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.userAId,_that.userBId,_that.blocked,_that.createdAt,_that.lastActive,_that.unreadCount,_that.userALastReadAt,_that.userBLastReadAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_a_id')  String userAId, @JsonKey(name: 'user_b_id')  String userBId,  bool blocked, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'last_active')  DateTime lastActive, @JsonKey(name: 'unread_count')  int unreadCount, @JsonKey(name: 'user_a_last_read_at')  DateTime? userALastReadAt, @JsonKey(name: 'user_b_last_read_at')  DateTime? userBLastReadAt)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.userAId,_that.userBId,_that.blocked,_that.createdAt,_that.lastActive,_that.unreadCount,_that.userALastReadAt,_that.userBLastReadAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conversation implements Conversation {
  const _Conversation({required this.id, @JsonKey(name: 'user_a_id') required this.userAId, @JsonKey(name: 'user_b_id') required this.userBId, required this.blocked, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'last_active') required this.lastActive, @JsonKey(name: 'unread_count') this.unreadCount = 0, @JsonKey(name: 'user_a_last_read_at') this.userALastReadAt, @JsonKey(name: 'user_b_last_read_at') this.userBLastReadAt});
  factory _Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_a_id') final  String userAId;
@override@JsonKey(name: 'user_b_id') final  String userBId;
@override final  bool blocked;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'last_active') final  DateTime lastActive;
@override@JsonKey(name: 'unread_count') final  int unreadCount;
@override@JsonKey(name: 'user_a_last_read_at') final  DateTime? userALastReadAt;
@override@JsonKey(name: 'user_b_last_read_at') final  DateTime? userBLastReadAt;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.userAId, userAId) || other.userAId == userAId)&&(identical(other.userBId, userBId) || other.userBId == userBId)&&(identical(other.blocked, blocked) || other.blocked == blocked)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.userALastReadAt, userALastReadAt) || other.userALastReadAt == userALastReadAt)&&(identical(other.userBLastReadAt, userBLastReadAt) || other.userBLastReadAt == userBLastReadAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userAId,userBId,blocked,createdAt,lastActive,unreadCount,userALastReadAt,userBLastReadAt);

@override
String toString() {
  return 'Conversation(id: $id, userAId: $userAId, userBId: $userBId, blocked: $blocked, createdAt: $createdAt, lastActive: $lastActive, unreadCount: $unreadCount, userALastReadAt: $userALastReadAt, userBLastReadAt: $userBLastReadAt)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_a_id') String userAId,@JsonKey(name: 'user_b_id') String userBId, bool blocked,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'last_active') DateTime lastActive,@JsonKey(name: 'unread_count') int unreadCount,@JsonKey(name: 'user_a_last_read_at') DateTime? userALastReadAt,@JsonKey(name: 'user_b_last_read_at') DateTime? userBLastReadAt
});




}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userAId = null,Object? userBId = null,Object? blocked = null,Object? createdAt = null,Object? lastActive = null,Object? unreadCount = null,Object? userALastReadAt = freezed,Object? userBLastReadAt = freezed,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userAId: null == userAId ? _self.userAId : userAId // ignore: cast_nullable_to_non_nullable
as String,userBId: null == userBId ? _self.userBId : userBId // ignore: cast_nullable_to_non_nullable
as String,blocked: null == blocked ? _self.blocked : blocked // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastActive: null == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,userALastReadAt: freezed == userALastReadAt ? _self.userALastReadAt : userALastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,userBLastReadAt: freezed == userBLastReadAt ? _self.userBLastReadAt : userBLastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Message {

 String get id;@JsonKey(name: 'conversation_id') String get conversationId;@JsonKey(name: 'sender_id') String get senderId; String get body;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'sent_at') DateTime get sentAt;@JsonKey(name: 'reply_to_id') String? get replyToId;@JsonKey(name: 'edited_at') DateTime? get editedAt; String get status;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.body, body) || other.body == body)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,body,isDeleted,sentAt,replyToId,editedAt,status);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, body: $body, isDeleted: $isDeleted, sentAt: $sentAt, replyToId: $replyToId, editedAt: $editedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'sender_id') String senderId, String body,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'reply_to_id') String? replyToId,@JsonKey(name: 'edited_at') DateTime? editedAt, String status
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? body = null,Object? isDeleted = null,Object? sentAt = null,Object? replyToId = freezed,Object? editedAt = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String body, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'reply_to_id')  String? replyToId, @JsonKey(name: 'edited_at')  DateTime? editedAt,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.body,_that.isDeleted,_that.sentAt,_that.replyToId,_that.editedAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String body, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'reply_to_id')  String? replyToId, @JsonKey(name: 'edited_at')  DateTime? editedAt,  String status)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.senderId,_that.body,_that.isDeleted,_that.sentAt,_that.replyToId,_that.editedAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'conversation_id')  String conversationId, @JsonKey(name: 'sender_id')  String senderId,  String body, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'sent_at')  DateTime sentAt, @JsonKey(name: 'reply_to_id')  String? replyToId, @JsonKey(name: 'edited_at')  DateTime? editedAt,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.body,_that.isDeleted,_that.sentAt,_that.replyToId,_that.editedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, @JsonKey(name: 'conversation_id') required this.conversationId, @JsonKey(name: 'sender_id') required this.senderId, required this.body, @JsonKey(name: 'is_deleted') required this.isDeleted, @JsonKey(name: 'sent_at') required this.sentAt, @JsonKey(name: 'reply_to_id') this.replyToId, @JsonKey(name: 'edited_at') this.editedAt, this.status = 'sent'});
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  String id;
@override@JsonKey(name: 'conversation_id') final  String conversationId;
@override@JsonKey(name: 'sender_id') final  String senderId;
@override final  String body;
@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'sent_at') final  DateTime sentAt;
@override@JsonKey(name: 'reply_to_id') final  String? replyToId;
@override@JsonKey(name: 'edited_at') final  DateTime? editedAt;
@override@JsonKey() final  String status;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.body, body) || other.body == body)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt)&&(identical(other.replyToId, replyToId) || other.replyToId == replyToId)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,senderId,body,isDeleted,sentAt,replyToId,editedAt,status);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, body: $body, isDeleted: $isDeleted, sentAt: $sentAt, replyToId: $replyToId, editedAt: $editedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'conversation_id') String conversationId,@JsonKey(name: 'sender_id') String senderId, String body,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'sent_at') DateTime sentAt,@JsonKey(name: 'reply_to_id') String? replyToId,@JsonKey(name: 'edited_at') DateTime? editedAt, String status
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? body = null,Object? isDeleted = null,Object? sentAt = null,Object? replyToId = freezed,Object? editedAt = freezed,Object? status = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,replyToId: freezed == replyToId ? _self.replyToId : replyToId // ignore: cast_nullable_to_non_nullable
as String?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
