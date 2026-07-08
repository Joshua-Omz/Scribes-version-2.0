// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_version.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostVersion {

 String get id;@JsonKey(name: 'post_id') String get postId;@JsonKey(name: 'version_number') int get versionNumber;@JsonKey(name: 'content_snapshot') Map<String, dynamic> get contentSnapshot;@JsonKey(name: 'snapshotted_at') DateTime get snapshottedAt;@JsonKey(name: 'snapshotted_by') String get snapshottedBy;
/// Create a copy of PostVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostVersionCopyWith<PostVersion> get copyWith => _$PostVersionCopyWithImpl<PostVersion>(this as PostVersion, _$identity);

  /// Serializes this PostVersion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&const DeepCollectionEquality().equals(other.contentSnapshot, contentSnapshot)&&(identical(other.snapshottedAt, snapshottedAt) || other.snapshottedAt == snapshottedAt)&&(identical(other.snapshottedBy, snapshottedBy) || other.snapshottedBy == snapshottedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,versionNumber,const DeepCollectionEquality().hash(contentSnapshot),snapshottedAt,snapshottedBy);

@override
String toString() {
  return 'PostVersion(id: $id, postId: $postId, versionNumber: $versionNumber, contentSnapshot: $contentSnapshot, snapshottedAt: $snapshottedAt, snapshottedBy: $snapshottedBy)';
}


}

/// @nodoc
abstract mixin class $PostVersionCopyWith<$Res>  {
  factory $PostVersionCopyWith(PostVersion value, $Res Function(PostVersion) _then) = _$PostVersionCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'version_number') int versionNumber,@JsonKey(name: 'content_snapshot') Map<String, dynamic> contentSnapshot,@JsonKey(name: 'snapshotted_at') DateTime snapshottedAt,@JsonKey(name: 'snapshotted_by') String snapshottedBy
});




}
/// @nodoc
class _$PostVersionCopyWithImpl<$Res>
    implements $PostVersionCopyWith<$Res> {
  _$PostVersionCopyWithImpl(this._self, this._then);

  final PostVersion _self;
  final $Res Function(PostVersion) _then;

/// Create a copy of PostVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? versionNumber = null,Object? contentSnapshot = null,Object? snapshottedAt = null,Object? snapshottedBy = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,contentSnapshot: null == contentSnapshot ? _self.contentSnapshot : contentSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,snapshottedAt: null == snapshottedAt ? _self.snapshottedAt : snapshottedAt // ignore: cast_nullable_to_non_nullable
as DateTime,snapshottedBy: null == snapshottedBy ? _self.snapshottedBy : snapshottedBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostVersion].
extension PostVersionPatterns on PostVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostVersion value)  $default,){
final _that = this;
switch (_that) {
case _PostVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostVersion value)?  $default,){
final _that = this;
switch (_that) {
case _PostVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'version_number')  int versionNumber, @JsonKey(name: 'content_snapshot')  Map<String, dynamic> contentSnapshot, @JsonKey(name: 'snapshotted_at')  DateTime snapshottedAt, @JsonKey(name: 'snapshotted_by')  String snapshottedBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostVersion() when $default != null:
return $default(_that.id,_that.postId,_that.versionNumber,_that.contentSnapshot,_that.snapshottedAt,_that.snapshottedBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'version_number')  int versionNumber, @JsonKey(name: 'content_snapshot')  Map<String, dynamic> contentSnapshot, @JsonKey(name: 'snapshotted_at')  DateTime snapshottedAt, @JsonKey(name: 'snapshotted_by')  String snapshottedBy)  $default,) {final _that = this;
switch (_that) {
case _PostVersion():
return $default(_that.id,_that.postId,_that.versionNumber,_that.contentSnapshot,_that.snapshottedAt,_that.snapshottedBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'version_number')  int versionNumber, @JsonKey(name: 'content_snapshot')  Map<String, dynamic> contentSnapshot, @JsonKey(name: 'snapshotted_at')  DateTime snapshottedAt, @JsonKey(name: 'snapshotted_by')  String snapshottedBy)?  $default,) {final _that = this;
switch (_that) {
case _PostVersion() when $default != null:
return $default(_that.id,_that.postId,_that.versionNumber,_that.contentSnapshot,_that.snapshottedAt,_that.snapshottedBy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostVersion implements PostVersion {
  const _PostVersion({required this.id, @JsonKey(name: 'post_id') required this.postId, @JsonKey(name: 'version_number') required this.versionNumber, @JsonKey(name: 'content_snapshot') required final  Map<String, dynamic> contentSnapshot, @JsonKey(name: 'snapshotted_at') required this.snapshottedAt, @JsonKey(name: 'snapshotted_by') required this.snapshottedBy}): _contentSnapshot = contentSnapshot;
  factory _PostVersion.fromJson(Map<String, dynamic> json) => _$PostVersionFromJson(json);

@override final  String id;
@override@JsonKey(name: 'post_id') final  String postId;
@override@JsonKey(name: 'version_number') final  int versionNumber;
 final  Map<String, dynamic> _contentSnapshot;
@override@JsonKey(name: 'content_snapshot') Map<String, dynamic> get contentSnapshot {
  if (_contentSnapshot is EqualUnmodifiableMapView) return _contentSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_contentSnapshot);
}

@override@JsonKey(name: 'snapshotted_at') final  DateTime snapshottedAt;
@override@JsonKey(name: 'snapshotted_by') final  String snapshottedBy;

/// Create a copy of PostVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostVersionCopyWith<_PostVersion> get copyWith => __$PostVersionCopyWithImpl<_PostVersion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostVersionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&const DeepCollectionEquality().equals(other._contentSnapshot, _contentSnapshot)&&(identical(other.snapshottedAt, snapshottedAt) || other.snapshottedAt == snapshottedAt)&&(identical(other.snapshottedBy, snapshottedBy) || other.snapshottedBy == snapshottedBy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,versionNumber,const DeepCollectionEquality().hash(_contentSnapshot),snapshottedAt,snapshottedBy);

@override
String toString() {
  return 'PostVersion(id: $id, postId: $postId, versionNumber: $versionNumber, contentSnapshot: $contentSnapshot, snapshottedAt: $snapshottedAt, snapshottedBy: $snapshottedBy)';
}


}

/// @nodoc
abstract mixin class _$PostVersionCopyWith<$Res> implements $PostVersionCopyWith<$Res> {
  factory _$PostVersionCopyWith(_PostVersion value, $Res Function(_PostVersion) _then) = __$PostVersionCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'version_number') int versionNumber,@JsonKey(name: 'content_snapshot') Map<String, dynamic> contentSnapshot,@JsonKey(name: 'snapshotted_at') DateTime snapshottedAt,@JsonKey(name: 'snapshotted_by') String snapshottedBy
});




}
/// @nodoc
class __$PostVersionCopyWithImpl<$Res>
    implements _$PostVersionCopyWith<$Res> {
  __$PostVersionCopyWithImpl(this._self, this._then);

  final _PostVersion _self;
  final $Res Function(_PostVersion) _then;

/// Create a copy of PostVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? versionNumber = null,Object? contentSnapshot = null,Object? snapshottedAt = null,Object? snapshottedBy = null,}) {
  return _then(_PostVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,versionNumber: null == versionNumber ? _self.versionNumber : versionNumber // ignore: cast_nullable_to_non_nullable
as int,contentSnapshot: null == contentSnapshot ? _self._contentSnapshot : contentSnapshot // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,snapshottedAt: null == snapshottedAt ? _self.snapshottedAt : snapshottedAt // ignore: cast_nullable_to_non_nullable
as DateTime,snapshottedBy: null == snapshottedBy ? _self.snapshottedBy : snapshottedBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
