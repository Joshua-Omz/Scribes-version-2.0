// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passage_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoundTrack {

 String get id; String get title; String get category;@JsonKey(name: 'audio_url') String get audioUrl;@JsonKey(name: 'duration_seconds') int get durationSeconds;
/// Create a copy of SoundTrack
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoundTrackCopyWith<SoundTrack> get copyWith => _$SoundTrackCopyWithImpl<SoundTrack>(this as SoundTrack, _$identity);

  /// Serializes this SoundTrack to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoundTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,audioUrl,durationSeconds);

@override
String toString() {
  return 'SoundTrack(id: $id, title: $title, category: $category, audioUrl: $audioUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class $SoundTrackCopyWith<$Res>  {
  factory $SoundTrackCopyWith(SoundTrack value, $Res Function(SoundTrack) _then) = _$SoundTrackCopyWithImpl;
@useResult
$Res call({
 String id, String title, String category,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_seconds') int durationSeconds
});




}
/// @nodoc
class _$SoundTrackCopyWithImpl<$Res>
    implements $SoundTrackCopyWith<$Res> {
  _$SoundTrackCopyWithImpl(this._self, this._then);

  final SoundTrack _self;
  final $Res Function(SoundTrack) _then;

/// Create a copy of SoundTrack
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? category = null,Object? audioUrl = null,Object? durationSeconds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SoundTrack].
extension SoundTrackPatterns on SoundTrack {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoundTrack value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoundTrack() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoundTrack value)  $default,){
final _that = this;
switch (_that) {
case _SoundTrack():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoundTrack value)?  $default,){
final _that = this;
switch (_that) {
case _SoundTrack() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String category, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_seconds')  int durationSeconds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoundTrack() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.audioUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String category, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_seconds')  int durationSeconds)  $default,) {final _that = this;
switch (_that) {
case _SoundTrack():
return $default(_that.id,_that.title,_that.category,_that.audioUrl,_that.durationSeconds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String category, @JsonKey(name: 'audio_url')  String audioUrl, @JsonKey(name: 'duration_seconds')  int durationSeconds)?  $default,) {final _that = this;
switch (_that) {
case _SoundTrack() when $default != null:
return $default(_that.id,_that.title,_that.category,_that.audioUrl,_that.durationSeconds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoundTrack implements SoundTrack {
  const _SoundTrack({required this.id, required this.title, required this.category, @JsonKey(name: 'audio_url') required this.audioUrl, @JsonKey(name: 'duration_seconds') required this.durationSeconds});
  factory _SoundTrack.fromJson(Map<String, dynamic> json) => _$SoundTrackFromJson(json);

@override final  String id;
@override final  String title;
@override final  String category;
@override@JsonKey(name: 'audio_url') final  String audioUrl;
@override@JsonKey(name: 'duration_seconds') final  int durationSeconds;

/// Create a copy of SoundTrack
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoundTrackCopyWith<_SoundTrack> get copyWith => __$SoundTrackCopyWithImpl<_SoundTrack>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoundTrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoundTrack&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.category, category) || other.category == category)&&(identical(other.audioUrl, audioUrl) || other.audioUrl == audioUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,category,audioUrl,durationSeconds);

@override
String toString() {
  return 'SoundTrack(id: $id, title: $title, category: $category, audioUrl: $audioUrl, durationSeconds: $durationSeconds)';
}


}

/// @nodoc
abstract mixin class _$SoundTrackCopyWith<$Res> implements $SoundTrackCopyWith<$Res> {
  factory _$SoundTrackCopyWith(_SoundTrack value, $Res Function(_SoundTrack) _then) = __$SoundTrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String category,@JsonKey(name: 'audio_url') String audioUrl,@JsonKey(name: 'duration_seconds') int durationSeconds
});




}
/// @nodoc
class __$SoundTrackCopyWithImpl<$Res>
    implements _$SoundTrackCopyWith<$Res> {
  __$SoundTrackCopyWithImpl(this._self, this._then);

  final _SoundTrack _self;
  final $Res Function(_SoundTrack) _then;

/// Create a copy of SoundTrack
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? category = null,Object? audioUrl = null,Object? durationSeconds = null,}) {
  return _then(_SoundTrack(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,audioUrl: null == audioUrl ? _self.audioUrl : audioUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PassagePanel {

 String get id;@JsonKey(name: 'post_id') String get postId;@JsonKey(name: 'panel_order') int get panelOrder;@JsonKey(name: 'panel_type') String get panelType; Map<String, dynamic> get content;@JsonKey(name: 'background_image_url') String? get backgroundImageUrl;@JsonKey(name: 'scripture_ref') Map<String, dynamic>? get scriptureRef;
/// Create a copy of PassagePanel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassagePanelCopyWith<PassagePanel> get copyWith => _$PassagePanelCopyWithImpl<PassagePanel>(this as PassagePanel, _$identity);

  /// Serializes this PassagePanel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassagePanel&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.panelOrder, panelOrder) || other.panelOrder == panelOrder)&&(identical(other.panelType, panelType) || other.panelType == panelType)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.backgroundImageUrl, backgroundImageUrl) || other.backgroundImageUrl == backgroundImageUrl)&&const DeepCollectionEquality().equals(other.scriptureRef, scriptureRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,panelOrder,panelType,const DeepCollectionEquality().hash(content),backgroundImageUrl,const DeepCollectionEquality().hash(scriptureRef));

@override
String toString() {
  return 'PassagePanel(id: $id, postId: $postId, panelOrder: $panelOrder, panelType: $panelType, content: $content, backgroundImageUrl: $backgroundImageUrl, scriptureRef: $scriptureRef)';
}


}

/// @nodoc
abstract mixin class $PassagePanelCopyWith<$Res>  {
  factory $PassagePanelCopyWith(PassagePanel value, $Res Function(PassagePanel) _then) = _$PassagePanelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'panel_order') int panelOrder,@JsonKey(name: 'panel_type') String panelType, Map<String, dynamic> content,@JsonKey(name: 'background_image_url') String? backgroundImageUrl,@JsonKey(name: 'scripture_ref') Map<String, dynamic>? scriptureRef
});




}
/// @nodoc
class _$PassagePanelCopyWithImpl<$Res>
    implements $PassagePanelCopyWith<$Res> {
  _$PassagePanelCopyWithImpl(this._self, this._then);

  final PassagePanel _self;
  final $Res Function(PassagePanel) _then;

/// Create a copy of PassagePanel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? postId = null,Object? panelOrder = null,Object? panelType = null,Object? content = null,Object? backgroundImageUrl = freezed,Object? scriptureRef = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,panelOrder: null == panelOrder ? _self.panelOrder : panelOrder // ignore: cast_nullable_to_non_nullable
as int,panelType: null == panelType ? _self.panelType : panelType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,backgroundImageUrl: freezed == backgroundImageUrl ? _self.backgroundImageUrl : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
as String?,scriptureRef: freezed == scriptureRef ? _self.scriptureRef : scriptureRef // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PassagePanel].
extension PassagePanelPatterns on PassagePanel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassagePanel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassagePanel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassagePanel value)  $default,){
final _that = this;
switch (_that) {
case _PassagePanel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassagePanel value)?  $default,){
final _that = this;
switch (_that) {
case _PassagePanel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'panel_order')  int panelOrder, @JsonKey(name: 'panel_type')  String panelType,  Map<String, dynamic> content, @JsonKey(name: 'background_image_url')  String? backgroundImageUrl, @JsonKey(name: 'scripture_ref')  Map<String, dynamic>? scriptureRef)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassagePanel() when $default != null:
return $default(_that.id,_that.postId,_that.panelOrder,_that.panelType,_that.content,_that.backgroundImageUrl,_that.scriptureRef);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'panel_order')  int panelOrder, @JsonKey(name: 'panel_type')  String panelType,  Map<String, dynamic> content, @JsonKey(name: 'background_image_url')  String? backgroundImageUrl, @JsonKey(name: 'scripture_ref')  Map<String, dynamic>? scriptureRef)  $default,) {final _that = this;
switch (_that) {
case _PassagePanel():
return $default(_that.id,_that.postId,_that.panelOrder,_that.panelType,_that.content,_that.backgroundImageUrl,_that.scriptureRef);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'post_id')  String postId, @JsonKey(name: 'panel_order')  int panelOrder, @JsonKey(name: 'panel_type')  String panelType,  Map<String, dynamic> content, @JsonKey(name: 'background_image_url')  String? backgroundImageUrl, @JsonKey(name: 'scripture_ref')  Map<String, dynamic>? scriptureRef)?  $default,) {final _that = this;
switch (_that) {
case _PassagePanel() when $default != null:
return $default(_that.id,_that.postId,_that.panelOrder,_that.panelType,_that.content,_that.backgroundImageUrl,_that.scriptureRef);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassagePanel implements PassagePanel {
  const _PassagePanel({this.id = '', @JsonKey(name: 'post_id') this.postId = '', @JsonKey(name: 'panel_order') this.panelOrder = 0, @JsonKey(name: 'panel_type') required this.panelType, final  Map<String, dynamic> content = const {}, @JsonKey(name: 'background_image_url') this.backgroundImageUrl, @JsonKey(name: 'scripture_ref') final  Map<String, dynamic>? scriptureRef}): _content = content,_scriptureRef = scriptureRef;
  factory _PassagePanel.fromJson(Map<String, dynamic> json) => _$PassagePanelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey(name: 'post_id') final  String postId;
@override@JsonKey(name: 'panel_order') final  int panelOrder;
@override@JsonKey(name: 'panel_type') final  String panelType;
 final  Map<String, dynamic> _content;
@override@JsonKey() Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

@override@JsonKey(name: 'background_image_url') final  String? backgroundImageUrl;
 final  Map<String, dynamic>? _scriptureRef;
@override@JsonKey(name: 'scripture_ref') Map<String, dynamic>? get scriptureRef {
  final value = _scriptureRef;
  if (value == null) return null;
  if (_scriptureRef is EqualUnmodifiableMapView) return _scriptureRef;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PassagePanel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassagePanelCopyWith<_PassagePanel> get copyWith => __$PassagePanelCopyWithImpl<_PassagePanel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassagePanelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassagePanel&&(identical(other.id, id) || other.id == id)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.panelOrder, panelOrder) || other.panelOrder == panelOrder)&&(identical(other.panelType, panelType) || other.panelType == panelType)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.backgroundImageUrl, backgroundImageUrl) || other.backgroundImageUrl == backgroundImageUrl)&&const DeepCollectionEquality().equals(other._scriptureRef, _scriptureRef));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,postId,panelOrder,panelType,const DeepCollectionEquality().hash(_content),backgroundImageUrl,const DeepCollectionEquality().hash(_scriptureRef));

@override
String toString() {
  return 'PassagePanel(id: $id, postId: $postId, panelOrder: $panelOrder, panelType: $panelType, content: $content, backgroundImageUrl: $backgroundImageUrl, scriptureRef: $scriptureRef)';
}


}

/// @nodoc
abstract mixin class _$PassagePanelCopyWith<$Res> implements $PassagePanelCopyWith<$Res> {
  factory _$PassagePanelCopyWith(_PassagePanel value, $Res Function(_PassagePanel) _then) = __$PassagePanelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'post_id') String postId,@JsonKey(name: 'panel_order') int panelOrder,@JsonKey(name: 'panel_type') String panelType, Map<String, dynamic> content,@JsonKey(name: 'background_image_url') String? backgroundImageUrl,@JsonKey(name: 'scripture_ref') Map<String, dynamic>? scriptureRef
});




}
/// @nodoc
class __$PassagePanelCopyWithImpl<$Res>
    implements _$PassagePanelCopyWith<$Res> {
  __$PassagePanelCopyWithImpl(this._self, this._then);

  final _PassagePanel _self;
  final $Res Function(_PassagePanel) _then;

/// Create a copy of PassagePanel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? postId = null,Object? panelOrder = null,Object? panelType = null,Object? content = null,Object? backgroundImageUrl = freezed,Object? scriptureRef = freezed,}) {
  return _then(_PassagePanel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,panelOrder: null == panelOrder ? _self.panelOrder : panelOrder // ignore: cast_nullable_to_non_nullable
as int,panelType: null == panelType ? _self.panelType : panelType // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,backgroundImageUrl: freezed == backgroundImageUrl ? _self.backgroundImageUrl : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
as String?,scriptureRef: freezed == scriptureRef ? _self._scriptureRef : scriptureRef // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
