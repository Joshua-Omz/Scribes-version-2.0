// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostDetailState {

 Post get post; List<PostVersion> get versions;
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailStateCopyWith<PostDetailState> get copyWith => _$PostDetailStateCopyWithImpl<PostDetailState>(this as PostDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailState&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other.versions, versions));
}


@override
int get hashCode => Object.hash(runtimeType,post,const DeepCollectionEquality().hash(versions));

@override
String toString() {
  return 'PostDetailState(post: $post, versions: $versions)';
}


}

/// @nodoc
abstract mixin class $PostDetailStateCopyWith<$Res>  {
  factory $PostDetailStateCopyWith(PostDetailState value, $Res Function(PostDetailState) _then) = _$PostDetailStateCopyWithImpl;
@useResult
$Res call({
 Post post, List<PostVersion> versions
});


$PostCopyWith<$Res> get post;

}
/// @nodoc
class _$PostDetailStateCopyWithImpl<$Res>
    implements $PostDetailStateCopyWith<$Res> {
  _$PostDetailStateCopyWithImpl(this._self, this._then);

  final PostDetailState _self;
  final $Res Function(PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = null,Object? versions = null,}) {
  return _then(_self.copyWith(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,versions: null == versions ? _self.versions : versions // ignore: cast_nullable_to_non_nullable
as List<PostVersion>,
  ));
}
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostDetailState].
extension PostDetailStatePatterns on PostDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostDetailState value)  $default,){
final _that = this;
switch (_that) {
case _PostDetailState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Post post,  List<PostVersion> versions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.versions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Post post,  List<PostVersion> versions)  $default,) {final _that = this;
switch (_that) {
case _PostDetailState():
return $default(_that.post,_that.versions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Post post,  List<PostVersion> versions)?  $default,) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.versions);case _:
  return null;

}
}

}

/// @nodoc


class _PostDetailState implements PostDetailState {
  const _PostDetailState({required this.post, final  List<PostVersion> versions = const []}): _versions = versions;
  

@override final  Post post;
 final  List<PostVersion> _versions;
@override@JsonKey() List<PostVersion> get versions {
  if (_versions is EqualUnmodifiableListView) return _versions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_versions);
}


/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostDetailStateCopyWith<_PostDetailState> get copyWith => __$PostDetailStateCopyWithImpl<_PostDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostDetailState&&(identical(other.post, post) || other.post == post)&&const DeepCollectionEquality().equals(other._versions, _versions));
}


@override
int get hashCode => Object.hash(runtimeType,post,const DeepCollectionEquality().hash(_versions));

@override
String toString() {
  return 'PostDetailState(post: $post, versions: $versions)';
}


}

/// @nodoc
abstract mixin class _$PostDetailStateCopyWith<$Res> implements $PostDetailStateCopyWith<$Res> {
  factory _$PostDetailStateCopyWith(_PostDetailState value, $Res Function(_PostDetailState) _then) = __$PostDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Post post, List<PostVersion> versions
});


@override $PostCopyWith<$Res> get post;

}
/// @nodoc
class __$PostDetailStateCopyWithImpl<$Res>
    implements _$PostDetailStateCopyWith<$Res> {
  __$PostDetailStateCopyWithImpl(this._self, this._then);

  final _PostDetailState _self;
  final $Res Function(_PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = null,Object? versions = null,}) {
  return _then(_PostDetailState(
post: null == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post,versions: null == versions ? _self._versions : versions // ignore: cast_nullable_to_non_nullable
as List<PostVersion>,
  ));
}

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res> get post {
  
  return $PostCopyWith<$Res>(_self.post, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}

// dart format on
