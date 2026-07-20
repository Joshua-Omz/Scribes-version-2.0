// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scripture_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ScriptureRef {

 String get book; int get chapter;@JsonKey(name: 'verse_start') int get verseStart;@JsonKey(name: 'verse_end') int? get verseEnd;
/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScriptureRefCopyWith<ScriptureRef> get copyWith => _$ScriptureRefCopyWithImpl<ScriptureRef>(this as ScriptureRef, _$identity);

  /// Serializes this ScriptureRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScriptureRef&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verseStart, verseStart) || other.verseStart == verseStart)&&(identical(other.verseEnd, verseEnd) || other.verseEnd == verseEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,book,chapter,verseStart,verseEnd);

@override
String toString() {
  return 'ScriptureRef(book: $book, chapter: $chapter, verseStart: $verseStart, verseEnd: $verseEnd)';
}


}

/// @nodoc
abstract mixin class $ScriptureRefCopyWith<$Res>  {
  factory $ScriptureRefCopyWith(ScriptureRef value, $Res Function(ScriptureRef) _then) = _$ScriptureRefCopyWithImpl;
@useResult
$Res call({
 String book, int chapter,@JsonKey(name: 'verse_start') int verseStart,@JsonKey(name: 'verse_end') int? verseEnd
});




}
/// @nodoc
class _$ScriptureRefCopyWithImpl<$Res>
    implements $ScriptureRefCopyWith<$Res> {
  _$ScriptureRefCopyWithImpl(this._self, this._then);

  final ScriptureRef _self;
  final $Res Function(ScriptureRef) _then;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? book = null,Object? chapter = null,Object? verseStart = null,Object? verseEnd = freezed,}) {
  return _then(_self.copyWith(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verseStart: null == verseStart ? _self.verseStart : verseStart // ignore: cast_nullable_to_non_nullable
as int,verseEnd: freezed == verseEnd ? _self.verseEnd : verseEnd // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ScriptureRef].
extension ScriptureRefPatterns on ScriptureRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScriptureRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScriptureRef value)  $default,){
final _that = this;
switch (_that) {
case _ScriptureRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScriptureRef value)?  $default,){
final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String book,  int chapter, @JsonKey(name: 'verse_start')  int verseStart, @JsonKey(name: 'verse_end')  int? verseEnd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that.book,_that.chapter,_that.verseStart,_that.verseEnd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String book,  int chapter, @JsonKey(name: 'verse_start')  int verseStart, @JsonKey(name: 'verse_end')  int? verseEnd)  $default,) {final _that = this;
switch (_that) {
case _ScriptureRef():
return $default(_that.book,_that.chapter,_that.verseStart,_that.verseEnd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String book,  int chapter, @JsonKey(name: 'verse_start')  int verseStart, @JsonKey(name: 'verse_end')  int? verseEnd)?  $default,) {final _that = this;
switch (_that) {
case _ScriptureRef() when $default != null:
return $default(_that.book,_that.chapter,_that.verseStart,_that.verseEnd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScriptureRef implements ScriptureRef {
  const _ScriptureRef({required this.book, required this.chapter, @JsonKey(name: 'verse_start') required this.verseStart, @JsonKey(name: 'verse_end') this.verseEnd});
  factory _ScriptureRef.fromJson(Map<String, dynamic> json) => _$ScriptureRefFromJson(json);

@override final  String book;
@override final  int chapter;
@override@JsonKey(name: 'verse_start') final  int verseStart;
@override@JsonKey(name: 'verse_end') final  int? verseEnd;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScriptureRefCopyWith<_ScriptureRef> get copyWith => __$ScriptureRefCopyWithImpl<_ScriptureRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScriptureRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScriptureRef&&(identical(other.book, book) || other.book == book)&&(identical(other.chapter, chapter) || other.chapter == chapter)&&(identical(other.verseStart, verseStart) || other.verseStart == verseStart)&&(identical(other.verseEnd, verseEnd) || other.verseEnd == verseEnd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,book,chapter,verseStart,verseEnd);

@override
String toString() {
  return 'ScriptureRef(book: $book, chapter: $chapter, verseStart: $verseStart, verseEnd: $verseEnd)';
}


}

/// @nodoc
abstract mixin class _$ScriptureRefCopyWith<$Res> implements $ScriptureRefCopyWith<$Res> {
  factory _$ScriptureRefCopyWith(_ScriptureRef value, $Res Function(_ScriptureRef) _then) = __$ScriptureRefCopyWithImpl;
@override @useResult
$Res call({
 String book, int chapter,@JsonKey(name: 'verse_start') int verseStart,@JsonKey(name: 'verse_end') int? verseEnd
});




}
/// @nodoc
class __$ScriptureRefCopyWithImpl<$Res>
    implements _$ScriptureRefCopyWith<$Res> {
  __$ScriptureRefCopyWithImpl(this._self, this._then);

  final _ScriptureRef _self;
  final $Res Function(_ScriptureRef) _then;

/// Create a copy of ScriptureRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? book = null,Object? chapter = null,Object? verseStart = null,Object? verseEnd = freezed,}) {
  return _then(_ScriptureRef(
book: null == book ? _self.book : book // ignore: cast_nullable_to_non_nullable
as String,chapter: null == chapter ? _self.chapter : chapter // ignore: cast_nullable_to_non_nullable
as int,verseStart: null == verseStart ? _self.verseStart : verseStart // ignore: cast_nullable_to_non_nullable
as int,verseEnd: freezed == verseEnd ? _self.verseEnd : verseEnd // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
