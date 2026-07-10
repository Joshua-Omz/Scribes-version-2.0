// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sermon_source.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SermonSource {

 String? get preacher; String? get church; String? get date; String? get series;
/// Create a copy of SermonSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SermonSourceCopyWith<SermonSource> get copyWith => _$SermonSourceCopyWithImpl<SermonSource>(this as SermonSource, _$identity);

  /// Serializes this SermonSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SermonSource&&(identical(other.preacher, preacher) || other.preacher == preacher)&&(identical(other.church, church) || other.church == church)&&(identical(other.date, date) || other.date == date)&&(identical(other.series, series) || other.series == series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preacher,church,date,series);

@override
String toString() {
  return 'SermonSource(preacher: $preacher, church: $church, date: $date, series: $series)';
}


}

/// @nodoc
abstract mixin class $SermonSourceCopyWith<$Res>  {
  factory $SermonSourceCopyWith(SermonSource value, $Res Function(SermonSource) _then) = _$SermonSourceCopyWithImpl;
@useResult
$Res call({
 String? preacher, String? church, String? date, String? series
});




}
/// @nodoc
class _$SermonSourceCopyWithImpl<$Res>
    implements $SermonSourceCopyWith<$Res> {
  _$SermonSourceCopyWithImpl(this._self, this._then);

  final SermonSource _self;
  final $Res Function(SermonSource) _then;

/// Create a copy of SermonSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? preacher = freezed,Object? church = freezed,Object? date = freezed,Object? series = freezed,}) {
  return _then(_self.copyWith(
preacher: freezed == preacher ? _self.preacher : preacher // ignore: cast_nullable_to_non_nullable
as String?,church: freezed == church ? _self.church : church // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SermonSource].
extension SermonSourcePatterns on SermonSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SermonSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SermonSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SermonSource value)  $default,){
final _that = this;
switch (_that) {
case _SermonSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SermonSource value)?  $default,){
final _that = this;
switch (_that) {
case _SermonSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? preacher,  String? church,  String? date,  String? series)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SermonSource() when $default != null:
return $default(_that.preacher,_that.church,_that.date,_that.series);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? preacher,  String? church,  String? date,  String? series)  $default,) {final _that = this;
switch (_that) {
case _SermonSource():
return $default(_that.preacher,_that.church,_that.date,_that.series);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? preacher,  String? church,  String? date,  String? series)?  $default,) {final _that = this;
switch (_that) {
case _SermonSource() when $default != null:
return $default(_that.preacher,_that.church,_that.date,_that.series);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SermonSource extends SermonSource {
  const _SermonSource({this.preacher, this.church, this.date, this.series}): super._();
  factory _SermonSource.fromJson(Map<String, dynamic> json) => _$SermonSourceFromJson(json);

@override final  String? preacher;
@override final  String? church;
@override final  String? date;
@override final  String? series;

/// Create a copy of SermonSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SermonSourceCopyWith<_SermonSource> get copyWith => __$SermonSourceCopyWithImpl<_SermonSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SermonSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SermonSource&&(identical(other.preacher, preacher) || other.preacher == preacher)&&(identical(other.church, church) || other.church == church)&&(identical(other.date, date) || other.date == date)&&(identical(other.series, series) || other.series == series));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,preacher,church,date,series);

@override
String toString() {
  return 'SermonSource(preacher: $preacher, church: $church, date: $date, series: $series)';
}


}

/// @nodoc
abstract mixin class _$SermonSourceCopyWith<$Res> implements $SermonSourceCopyWith<$Res> {
  factory _$SermonSourceCopyWith(_SermonSource value, $Res Function(_SermonSource) _then) = __$SermonSourceCopyWithImpl;
@override @useResult
$Res call({
 String? preacher, String? church, String? date, String? series
});




}
/// @nodoc
class __$SermonSourceCopyWithImpl<$Res>
    implements _$SermonSourceCopyWith<$Res> {
  __$SermonSourceCopyWithImpl(this._self, this._then);

  final _SermonSource _self;
  final $Res Function(_SermonSource) _then;

/// Create a copy of SermonSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? preacher = freezed,Object? church = freezed,Object? date = freezed,Object? series = freezed,}) {
  return _then(_SermonSource(
preacher: freezed == preacher ? _self.preacher : preacher // ignore: cast_nullable_to_non_nullable
as String?,church: freezed == church ? _self.church : church // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
