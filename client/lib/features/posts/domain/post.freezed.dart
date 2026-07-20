// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> get content; String? get caption; String get visibility;@JsonKey(name: 'current_version') int get currentVersion;@JsonKey(name: 'is_correction') bool get isCorrection;@JsonKey(name: 'corrects_post_id') String? get correctsPostId;@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? get sermonSource;@JsonKey(name: 'scripture_refs') List<ScriptureRef> get scriptureRefs;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'published_at') DateTime get publishedAt;@JsonKey(name: 'author_handle') String get authorHandle;@JsonKey(name: 'author_name') String get authorName;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.correctsPostId, correctsPostId) || other.correctsPostId == correctsPostId)&&(identical(other.sermonSource, sermonSource) || other.sermonSource == sermonSource)&&const DeepCollectionEquality().equals(other.scriptureRefs, scriptureRefs)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorHandle, authorHandle) || other.authorHandle == authorHandle)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,const DeepCollectionEquality().hash(content),caption,visibility,currentVersion,isCorrection,correctsPostId,sermonSource,const DeepCollectionEquality().hash(scriptureRefs),isDeleted,publishedAt,authorHandle,authorName);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, content: $content, caption: $caption, visibility: $visibility, currentVersion: $currentVersion, isCorrection: $isCorrection, correctsPostId: $correctsPostId, sermonSource: $sermonSource, scriptureRefs: $scriptureRefs, isDeleted: $isDeleted, publishedAt: $publishedAt, authorHandle: $authorHandle, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> content, String? caption, String visibility,@JsonKey(name: 'current_version') int currentVersion,@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'corrects_post_id') String? correctsPostId,@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,@JsonKey(name: 'scripture_refs') List<ScriptureRef> scriptureRefs,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'published_at') DateTime publishedAt,@JsonKey(name: 'author_handle') String authorHandle,@JsonKey(name: 'author_name') String authorName
});


$SermonSourceCopyWith<$Res>? get sermonSource;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? content = null,Object? caption = freezed,Object? visibility = null,Object? currentVersion = null,Object? isCorrection = null,Object? correctsPostId = freezed,Object? sermonSource = freezed,Object? scriptureRefs = null,Object? isDeleted = null,Object? publishedAt = null,Object? authorHandle = null,Object? authorName = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int,isCorrection: null == isCorrection ? _self.isCorrection : isCorrection // ignore: cast_nullable_to_non_nullable
as bool,correctsPostId: freezed == correctsPostId ? _self.correctsPostId : correctsPostId // ignore: cast_nullable_to_non_nullable
as String?,sermonSource: freezed == sermonSource ? _self.sermonSource : sermonSource // ignore: cast_nullable_to_non_nullable
as SermonSource?,scriptureRefs: null == scriptureRefs ? _self.scriptureRefs : scriptureRefs // ignore: cast_nullable_to_non_nullable
as List<ScriptureRef>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorHandle: null == authorHandle ? _self.authorHandle : authorHandle // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SermonSourceCopyWith<$Res>? get sermonSource {
    if (_self.sermonSource == null) {
    return null;
  }

  return $SermonSourceCopyWith<$Res>(_self.sermonSource!, (value) {
    return _then(_self.copyWith(sermonSource: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.isDeleted,_that.publishedAt,_that.authorHandle,_that.authorName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.isDeleted,_that.publishedAt,_that.authorHandle,_that.authorName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.isDeleted,_that.publishedAt,_that.authorHandle,_that.authorName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(fromJson: _contentFromJson) required final  Map<String, dynamic> content, this.caption, required this.visibility, @JsonKey(name: 'current_version') required this.currentVersion, @JsonKey(name: 'is_correction') required this.isCorrection, @JsonKey(name: 'corrects_post_id') this.correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) this.sermonSource, @JsonKey(name: 'scripture_refs') final  List<ScriptureRef> scriptureRefs = const [], @JsonKey(name: 'is_deleted') required this.isDeleted, @JsonKey(name: 'published_at') required this.publishedAt, @JsonKey(name: 'author_handle') required this.authorHandle, @JsonKey(name: 'author_name') required this.authorName}): _content = content,_scriptureRefs = scriptureRefs;
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override@JsonKey(name: 'author_id') final  String authorId;
 final  Map<String, dynamic> _content;
@override@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

@override final  String? caption;
@override final  String visibility;
@override@JsonKey(name: 'current_version') final  int currentVersion;
@override@JsonKey(name: 'is_correction') final  bool isCorrection;
@override@JsonKey(name: 'corrects_post_id') final  String? correctsPostId;
@override@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) final  SermonSource? sermonSource;
 final  List<ScriptureRef> _scriptureRefs;
@override@JsonKey(name: 'scripture_refs') List<ScriptureRef> get scriptureRefs {
  if (_scriptureRefs is EqualUnmodifiableListView) return _scriptureRefs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scriptureRefs);
}

@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'published_at') final  DateTime publishedAt;
@override@JsonKey(name: 'author_handle') final  String authorHandle;
@override@JsonKey(name: 'author_name') final  String authorName;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.correctsPostId, correctsPostId) || other.correctsPostId == correctsPostId)&&(identical(other.sermonSource, sermonSource) || other.sermonSource == sermonSource)&&const DeepCollectionEquality().equals(other._scriptureRefs, _scriptureRefs)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorHandle, authorHandle) || other.authorHandle == authorHandle)&&(identical(other.authorName, authorName) || other.authorName == authorName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,authorId,const DeepCollectionEquality().hash(_content),caption,visibility,currentVersion,isCorrection,correctsPostId,sermonSource,const DeepCollectionEquality().hash(_scriptureRefs),isDeleted,publishedAt,authorHandle,authorName);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, content: $content, caption: $caption, visibility: $visibility, currentVersion: $currentVersion, isCorrection: $isCorrection, correctsPostId: $correctsPostId, sermonSource: $sermonSource, scriptureRefs: $scriptureRefs, isDeleted: $isDeleted, publishedAt: $publishedAt, authorHandle: $authorHandle, authorName: $authorName)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> content, String? caption, String visibility,@JsonKey(name: 'current_version') int currentVersion,@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'corrects_post_id') String? correctsPostId,@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,@JsonKey(name: 'scripture_refs') List<ScriptureRef> scriptureRefs,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'published_at') DateTime publishedAt,@JsonKey(name: 'author_handle') String authorHandle,@JsonKey(name: 'author_name') String authorName
});


@override $SermonSourceCopyWith<$Res>? get sermonSource;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? content = null,Object? caption = freezed,Object? visibility = null,Object? currentVersion = null,Object? isCorrection = null,Object? correctsPostId = freezed,Object? sermonSource = freezed,Object? scriptureRefs = null,Object? isDeleted = null,Object? publishedAt = null,Object? authorHandle = null,Object? authorName = null,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,currentVersion: null == currentVersion ? _self.currentVersion : currentVersion // ignore: cast_nullable_to_non_nullable
as int,isCorrection: null == isCorrection ? _self.isCorrection : isCorrection // ignore: cast_nullable_to_non_nullable
as bool,correctsPostId: freezed == correctsPostId ? _self.correctsPostId : correctsPostId // ignore: cast_nullable_to_non_nullable
as String?,sermonSource: freezed == sermonSource ? _self.sermonSource : sermonSource // ignore: cast_nullable_to_non_nullable
as SermonSource?,scriptureRefs: null == scriptureRefs ? _self._scriptureRefs : scriptureRefs // ignore: cast_nullable_to_non_nullable
as List<ScriptureRef>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorHandle: null == authorHandle ? _self.authorHandle : authorHandle // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SermonSourceCopyWith<$Res>? get sermonSource {
    if (_self.sermonSource == null) {
    return null;
  }

  return $SermonSourceCopyWith<$Res>(_self.sermonSource!, (value) {
    return _then(_self.copyWith(sermonSource: value));
  });
}
}

// dart format on
