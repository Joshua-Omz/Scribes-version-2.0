// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncEvent {

 String get type; String get id; Map<String, dynamic> get content;@JsonKey(name: 'title_or_caption') String? get titleOrCaption;@JsonKey(name: 'parent_id') String? get parentId;@JsonKey(name: 'server_sequence') int get serverSequence;@JsonKey(name: 'ts') DateTime get timestamp;
/// Create a copy of SyncEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncEventCopyWith<SyncEvent> get copyWith => _$SyncEventCopyWithImpl<SyncEvent>(this as SyncEvent, _$identity);

  /// Serializes this SyncEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.titleOrCaption, titleOrCaption) || other.titleOrCaption == titleOrCaption)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.serverSequence, serverSequence) || other.serverSequence == serverSequence)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(content),titleOrCaption,parentId,serverSequence,timestamp);

@override
String toString() {
  return 'SyncEvent(type: $type, id: $id, content: $content, titleOrCaption: $titleOrCaption, parentId: $parentId, serverSequence: $serverSequence, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SyncEventCopyWith<$Res>  {
  factory $SyncEventCopyWith(SyncEvent value, $Res Function(SyncEvent) _then) = _$SyncEventCopyWithImpl;
@useResult
$Res call({
 String type, String id, Map<String, dynamic> content,@JsonKey(name: 'title_or_caption') String? titleOrCaption,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'server_sequence') int serverSequence,@JsonKey(name: 'ts') DateTime timestamp
});




}
/// @nodoc
class _$SyncEventCopyWithImpl<$Res>
    implements $SyncEventCopyWith<$Res> {
  _$SyncEventCopyWithImpl(this._self, this._then);

  final SyncEvent _self;
  final $Res Function(SyncEvent) _then;

/// Create a copy of SyncEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? id = null,Object? content = null,Object? titleOrCaption = freezed,Object? parentId = freezed,Object? serverSequence = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,titleOrCaption: freezed == titleOrCaption ? _self.titleOrCaption : titleOrCaption // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,serverSequence: null == serverSequence ? _self.serverSequence : serverSequence // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncEvent].
extension SyncEventPatterns on SyncEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncEvent value)  $default,){
final _that = this;
switch (_that) {
case _SyncEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncEvent value)?  $default,){
final _that = this;
switch (_that) {
case _SyncEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String id,  Map<String, dynamic> content, @JsonKey(name: 'title_or_caption')  String? titleOrCaption, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'server_sequence')  int serverSequence, @JsonKey(name: 'ts')  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncEvent() when $default != null:
return $default(_that.type,_that.id,_that.content,_that.titleOrCaption,_that.parentId,_that.serverSequence,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String id,  Map<String, dynamic> content, @JsonKey(name: 'title_or_caption')  String? titleOrCaption, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'server_sequence')  int serverSequence, @JsonKey(name: 'ts')  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _SyncEvent():
return $default(_that.type,_that.id,_that.content,_that.titleOrCaption,_that.parentId,_that.serverSequence,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String id,  Map<String, dynamic> content, @JsonKey(name: 'title_or_caption')  String? titleOrCaption, @JsonKey(name: 'parent_id')  String? parentId, @JsonKey(name: 'server_sequence')  int serverSequence, @JsonKey(name: 'ts')  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SyncEvent() when $default != null:
return $default(_that.type,_that.id,_that.content,_that.titleOrCaption,_that.parentId,_that.serverSequence,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncEvent implements SyncEvent {
  const _SyncEvent({required this.type, required this.id, required final  Map<String, dynamic> content, @JsonKey(name: 'title_or_caption') this.titleOrCaption, @JsonKey(name: 'parent_id') this.parentId, @JsonKey(name: 'server_sequence') required this.serverSequence, @JsonKey(name: 'ts') required this.timestamp}): _content = content;
  factory _SyncEvent.fromJson(Map<String, dynamic> json) => _$SyncEventFromJson(json);

@override final  String type;
@override final  String id;
 final  Map<String, dynamic> _content;
@override Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

@override@JsonKey(name: 'title_or_caption') final  String? titleOrCaption;
@override@JsonKey(name: 'parent_id') final  String? parentId;
@override@JsonKey(name: 'server_sequence') final  int serverSequence;
@override@JsonKey(name: 'ts') final  DateTime timestamp;

/// Create a copy of SyncEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncEventCopyWith<_SyncEvent> get copyWith => __$SyncEventCopyWithImpl<_SyncEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncEvent&&(identical(other.type, type) || other.type == type)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.titleOrCaption, titleOrCaption) || other.titleOrCaption == titleOrCaption)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.serverSequence, serverSequence) || other.serverSequence == serverSequence)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,id,const DeepCollectionEquality().hash(_content),titleOrCaption,parentId,serverSequence,timestamp);

@override
String toString() {
  return 'SyncEvent(type: $type, id: $id, content: $content, titleOrCaption: $titleOrCaption, parentId: $parentId, serverSequence: $serverSequence, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SyncEventCopyWith<$Res> implements $SyncEventCopyWith<$Res> {
  factory _$SyncEventCopyWith(_SyncEvent value, $Res Function(_SyncEvent) _then) = __$SyncEventCopyWithImpl;
@override @useResult
$Res call({
 String type, String id, Map<String, dynamic> content,@JsonKey(name: 'title_or_caption') String? titleOrCaption,@JsonKey(name: 'parent_id') String? parentId,@JsonKey(name: 'server_sequence') int serverSequence,@JsonKey(name: 'ts') DateTime timestamp
});




}
/// @nodoc
class __$SyncEventCopyWithImpl<$Res>
    implements _$SyncEventCopyWith<$Res> {
  __$SyncEventCopyWithImpl(this._self, this._then);

  final _SyncEvent _self;
  final $Res Function(_SyncEvent) _then;

/// Create a copy of SyncEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? id = null,Object? content = null,Object? titleOrCaption = freezed,Object? parentId = freezed,Object? serverSequence = null,Object? timestamp = null,}) {
  return _then(_SyncEvent(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,titleOrCaption: freezed == titleOrCaption ? _self.titleOrCaption : titleOrCaption // ignore: cast_nullable_to_non_nullable
as String?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,serverSequence: null == serverSequence ? _self.serverSequence : serverSequence // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
