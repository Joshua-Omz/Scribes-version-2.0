// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_feed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedFeed {

 List<Post> get posts;@JsonKey(name: 'next_cursor') String? get nextCursor;
/// Create a copy of PaginatedFeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedFeedCopyWith<PaginatedFeed> get copyWith => _$PaginatedFeedCopyWithImpl<PaginatedFeed>(this as PaginatedFeed, _$identity);

  /// Serializes this PaginatedFeed to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedFeed&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(posts),nextCursor);

@override
String toString() {
  return 'PaginatedFeed(posts: $posts, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class $PaginatedFeedCopyWith<$Res>  {
  factory $PaginatedFeedCopyWith(PaginatedFeed value, $Res Function(PaginatedFeed) _then) = _$PaginatedFeedCopyWithImpl;
@useResult
$Res call({
 List<Post> posts,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class _$PaginatedFeedCopyWithImpl<$Res>
    implements $PaginatedFeedCopyWith<$Res> {
  _$PaginatedFeedCopyWithImpl(this._self, this._then);

  final PaginatedFeed _self;
  final $Res Function(PaginatedFeed) _then;

/// Create a copy of PaginatedFeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? posts = null,Object? nextCursor = freezed,}) {
  return _then(_self.copyWith(
posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedFeed].
extension PaginatedFeedPatterns on PaginatedFeed {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedFeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedFeed() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedFeed value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedFeed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedFeed value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedFeed() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Post> posts, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedFeed() when $default != null:
return $default(_that.posts,_that.nextCursor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Post> posts, @JsonKey(name: 'next_cursor')  String? nextCursor)  $default,) {final _that = this;
switch (_that) {
case _PaginatedFeed():
return $default(_that.posts,_that.nextCursor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Post> posts, @JsonKey(name: 'next_cursor')  String? nextCursor)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedFeed() when $default != null:
return $default(_that.posts,_that.nextCursor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedFeed implements PaginatedFeed {
  const _PaginatedFeed({required final  List<Post> posts, @JsonKey(name: 'next_cursor') this.nextCursor}): _posts = posts;
  factory _PaginatedFeed.fromJson(Map<String, dynamic> json) => _$PaginatedFeedFromJson(json);

 final  List<Post> _posts;
@override List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override@JsonKey(name: 'next_cursor') final  String? nextCursor;

/// Create a copy of PaginatedFeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedFeedCopyWith<_PaginatedFeed> get copyWith => __$PaginatedFeedCopyWithImpl<_PaginatedFeed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedFeedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedFeed&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_posts),nextCursor);

@override
String toString() {
  return 'PaginatedFeed(posts: $posts, nextCursor: $nextCursor)';
}


}

/// @nodoc
abstract mixin class _$PaginatedFeedCopyWith<$Res> implements $PaginatedFeedCopyWith<$Res> {
  factory _$PaginatedFeedCopyWith(_PaginatedFeed value, $Res Function(_PaginatedFeed) _then) = __$PaginatedFeedCopyWithImpl;
@override @useResult
$Res call({
 List<Post> posts,@JsonKey(name: 'next_cursor') String? nextCursor
});




}
/// @nodoc
class __$PaginatedFeedCopyWithImpl<$Res>
    implements _$PaginatedFeedCopyWith<$Res> {
  __$PaginatedFeedCopyWithImpl(this._self, this._then);

  final _PaginatedFeed _self;
  final $Res Function(_PaginatedFeed) _then;

/// Create a copy of PaginatedFeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? posts = null,Object? nextCursor = freezed,}) {
  return _then(_PaginatedFeed(
posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
