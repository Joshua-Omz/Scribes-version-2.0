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

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> get content; String? get caption; String get visibility;@JsonKey(name: 'current_version') int get currentVersion;@JsonKey(name: 'is_correction') bool get isCorrection;@JsonKey(name: 'corrects_post_id') String? get correctsPostId;@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? get sermonSource;@JsonKey(name: 'scripture_refs') List<ScriptureRef> get scriptureRefs; List<String> get tags;@JsonKey(name: 'is_deleted') bool get isDeleted;@JsonKey(name: 'cover_image_url') String? get coverImageUrl;@JsonKey(name: 'reflection_image_url') String? get reflectionImageUrl;@JsonKey(name: 'sound_id') String? get soundId; SoundTrack? get sound; List<PassagePanel> get panels;@JsonKey(name: 'post_type') String get postType;@JsonKey(name: 'published_at') DateTime get publishedAt;@JsonKey(name: 'author_handle') String get authorHandle;@JsonKey(name: 'author_name') String get authorName;@JsonKey(name: 'author_avatar_url') String? get authorAvatarUrl;@JsonKey(name: 'amen_count') int get amenCount;@JsonKey(name: 'insight_count') int get insightCount;@JsonKey(name: 'thought_provoking_count') int get thoughtProvokingCount;@JsonKey(name: 'comment_count') int get commentCount;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.correctsPostId, correctsPostId) || other.correctsPostId == correctsPostId)&&(identical(other.sermonSource, sermonSource) || other.sermonSource == sermonSource)&&const DeepCollectionEquality().equals(other.scriptureRefs, scriptureRefs)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.reflectionImageUrl, reflectionImageUrl) || other.reflectionImageUrl == reflectionImageUrl)&&(identical(other.soundId, soundId) || other.soundId == soundId)&&(identical(other.sound, sound) || other.sound == sound)&&const DeepCollectionEquality().equals(other.panels, panels)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorHandle, authorHandle) || other.authorHandle == authorHandle)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.amenCount, amenCount) || other.amenCount == amenCount)&&(identical(other.insightCount, insightCount) || other.insightCount == insightCount)&&(identical(other.thoughtProvokingCount, thoughtProvokingCount) || other.thoughtProvokingCount == thoughtProvokingCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorId,const DeepCollectionEquality().hash(content),caption,visibility,currentVersion,isCorrection,correctsPostId,sermonSource,const DeepCollectionEquality().hash(scriptureRefs),const DeepCollectionEquality().hash(tags),isDeleted,coverImageUrl,reflectionImageUrl,soundId,sound,const DeepCollectionEquality().hash(panels),postType,publishedAt,authorHandle,authorName,authorAvatarUrl,amenCount,insightCount,thoughtProvokingCount,commentCount]);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, content: $content, caption: $caption, visibility: $visibility, currentVersion: $currentVersion, isCorrection: $isCorrection, correctsPostId: $correctsPostId, sermonSource: $sermonSource, scriptureRefs: $scriptureRefs, tags: $tags, isDeleted: $isDeleted, coverImageUrl: $coverImageUrl, reflectionImageUrl: $reflectionImageUrl, soundId: $soundId, sound: $sound, panels: $panels, postType: $postType, publishedAt: $publishedAt, authorHandle: $authorHandle, authorName: $authorName, authorAvatarUrl: $authorAvatarUrl, amenCount: $amenCount, insightCount: $insightCount, thoughtProvokingCount: $thoughtProvokingCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> content, String? caption, String visibility,@JsonKey(name: 'current_version') int currentVersion,@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'corrects_post_id') String? correctsPostId,@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,@JsonKey(name: 'scripture_refs') List<ScriptureRef> scriptureRefs, List<String> tags,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'reflection_image_url') String? reflectionImageUrl,@JsonKey(name: 'sound_id') String? soundId, SoundTrack? sound, List<PassagePanel> panels,@JsonKey(name: 'post_type') String postType,@JsonKey(name: 'published_at') DateTime publishedAt,@JsonKey(name: 'author_handle') String authorHandle,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'amen_count') int amenCount,@JsonKey(name: 'insight_count') int insightCount,@JsonKey(name: 'thought_provoking_count') int thoughtProvokingCount,@JsonKey(name: 'comment_count') int commentCount
});


$SermonSourceCopyWith<$Res>? get sermonSource;$SoundTrackCopyWith<$Res>? get sound;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? content = null,Object? caption = freezed,Object? visibility = null,Object? currentVersion = null,Object? isCorrection = null,Object? correctsPostId = freezed,Object? sermonSource = freezed,Object? scriptureRefs = null,Object? tags = null,Object? isDeleted = null,Object? coverImageUrl = freezed,Object? reflectionImageUrl = freezed,Object? soundId = freezed,Object? sound = freezed,Object? panels = null,Object? postType = null,Object? publishedAt = null,Object? authorHandle = null,Object? authorName = null,Object? authorAvatarUrl = freezed,Object? amenCount = null,Object? insightCount = null,Object? thoughtProvokingCount = null,Object? commentCount = null,}) {
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
as List<ScriptureRef>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,reflectionImageUrl: freezed == reflectionImageUrl ? _self.reflectionImageUrl : reflectionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundTrack?,panels: null == panels ? _self.panels : panels // ignore: cast_nullable_to_non_nullable
as List<PassagePanel>,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorHandle: null == authorHandle ? _self.authorHandle : authorHandle // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,amenCount: null == amenCount ? _self.amenCount : amenCount // ignore: cast_nullable_to_non_nullable
as int,insightCount: null == insightCount ? _self.insightCount : insightCount // ignore: cast_nullable_to_non_nullable
as int,thoughtProvokingCount: null == thoughtProvokingCount ? _self.thoughtProvokingCount : thoughtProvokingCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
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
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundTrackCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $SoundTrackCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs,  List<String> tags, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'reflection_image_url')  String? reflectionImageUrl, @JsonKey(name: 'sound_id')  String? soundId,  SoundTrack? sound,  List<PassagePanel> panels, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'amen_count')  int amenCount, @JsonKey(name: 'insight_count')  int insightCount, @JsonKey(name: 'thought_provoking_count')  int thoughtProvokingCount, @JsonKey(name: 'comment_count')  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.tags,_that.isDeleted,_that.coverImageUrl,_that.reflectionImageUrl,_that.soundId,_that.sound,_that.panels,_that.postType,_that.publishedAt,_that.authorHandle,_that.authorName,_that.authorAvatarUrl,_that.amenCount,_that.insightCount,_that.thoughtProvokingCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs,  List<String> tags, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'reflection_image_url')  String? reflectionImageUrl, @JsonKey(name: 'sound_id')  String? soundId,  SoundTrack? sound,  List<PassagePanel> panels, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'amen_count')  int amenCount, @JsonKey(name: 'insight_count')  int insightCount, @JsonKey(name: 'thought_provoking_count')  int thoughtProvokingCount, @JsonKey(name: 'comment_count')  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.tags,_that.isDeleted,_that.coverImageUrl,_that.reflectionImageUrl,_that.soundId,_that.sound,_that.panels,_that.postType,_that.publishedAt,_that.authorHandle,_that.authorName,_that.authorAvatarUrl,_that.amenCount,_that.insightCount,_that.thoughtProvokingCount,_that.commentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(fromJson: _contentFromJson)  Map<String, dynamic> content,  String? caption,  String visibility, @JsonKey(name: 'current_version')  int currentVersion, @JsonKey(name: 'is_correction')  bool isCorrection, @JsonKey(name: 'corrects_post_id')  String? correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson)  SermonSource? sermonSource, @JsonKey(name: 'scripture_refs')  List<ScriptureRef> scriptureRefs,  List<String> tags, @JsonKey(name: 'is_deleted')  bool isDeleted, @JsonKey(name: 'cover_image_url')  String? coverImageUrl, @JsonKey(name: 'reflection_image_url')  String? reflectionImageUrl, @JsonKey(name: 'sound_id')  String? soundId,  SoundTrack? sound,  List<PassagePanel> panels, @JsonKey(name: 'post_type')  String postType, @JsonKey(name: 'published_at')  DateTime publishedAt, @JsonKey(name: 'author_handle')  String authorHandle, @JsonKey(name: 'author_name')  String authorName, @JsonKey(name: 'author_avatar_url')  String? authorAvatarUrl, @JsonKey(name: 'amen_count')  int amenCount, @JsonKey(name: 'insight_count')  int insightCount, @JsonKey(name: 'thought_provoking_count')  int thoughtProvokingCount, @JsonKey(name: 'comment_count')  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.content,_that.caption,_that.visibility,_that.currentVersion,_that.isCorrection,_that.correctsPostId,_that.sermonSource,_that.scriptureRefs,_that.tags,_that.isDeleted,_that.coverImageUrl,_that.reflectionImageUrl,_that.soundId,_that.sound,_that.panels,_that.postType,_that.publishedAt,_that.authorHandle,_that.authorName,_that.authorAvatarUrl,_that.amenCount,_that.insightCount,_that.thoughtProvokingCount,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post implements Post {
  const _Post({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(fromJson: _contentFromJson) required final  Map<String, dynamic> content, this.caption, required this.visibility, @JsonKey(name: 'current_version') required this.currentVersion, @JsonKey(name: 'is_correction') required this.isCorrection, @JsonKey(name: 'corrects_post_id') this.correctsPostId, @JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) this.sermonSource, @JsonKey(name: 'scripture_refs') final  List<ScriptureRef> scriptureRefs = const [], final  List<String> tags = const [], @JsonKey(name: 'is_deleted') required this.isDeleted, @JsonKey(name: 'cover_image_url') this.coverImageUrl, @JsonKey(name: 'reflection_image_url') this.reflectionImageUrl, @JsonKey(name: 'sound_id') this.soundId, this.sound, final  List<PassagePanel> panels = const [], @JsonKey(name: 'post_type') this.postType = 'standard', @JsonKey(name: 'published_at') required this.publishedAt, @JsonKey(name: 'author_handle') required this.authorHandle, @JsonKey(name: 'author_name') required this.authorName, @JsonKey(name: 'author_avatar_url') this.authorAvatarUrl, @JsonKey(name: 'amen_count') this.amenCount = 0, @JsonKey(name: 'insight_count') this.insightCount = 0, @JsonKey(name: 'thought_provoking_count') this.thoughtProvokingCount = 0, @JsonKey(name: 'comment_count') this.commentCount = 0}): _content = content,_scriptureRefs = scriptureRefs,_tags = tags,_panels = panels;
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

 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(name: 'is_deleted') final  bool isDeleted;
@override@JsonKey(name: 'cover_image_url') final  String? coverImageUrl;
@override@JsonKey(name: 'reflection_image_url') final  String? reflectionImageUrl;
@override@JsonKey(name: 'sound_id') final  String? soundId;
@override final  SoundTrack? sound;
 final  List<PassagePanel> _panels;
@override@JsonKey() List<PassagePanel> get panels {
  if (_panels is EqualUnmodifiableListView) return _panels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_panels);
}

@override@JsonKey(name: 'post_type') final  String postType;
@override@JsonKey(name: 'published_at') final  DateTime publishedAt;
@override@JsonKey(name: 'author_handle') final  String authorHandle;
@override@JsonKey(name: 'author_name') final  String authorName;
@override@JsonKey(name: 'author_avatar_url') final  String? authorAvatarUrl;
@override@JsonKey(name: 'amen_count') final  int amenCount;
@override@JsonKey(name: 'insight_count') final  int insightCount;
@override@JsonKey(name: 'thought_provoking_count') final  int thoughtProvokingCount;
@override@JsonKey(name: 'comment_count') final  int commentCount;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.currentVersion, currentVersion) || other.currentVersion == currentVersion)&&(identical(other.isCorrection, isCorrection) || other.isCorrection == isCorrection)&&(identical(other.correctsPostId, correctsPostId) || other.correctsPostId == correctsPostId)&&(identical(other.sermonSource, sermonSource) || other.sermonSource == sermonSource)&&const DeepCollectionEquality().equals(other._scriptureRefs, _scriptureRefs)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.reflectionImageUrl, reflectionImageUrl) || other.reflectionImageUrl == reflectionImageUrl)&&(identical(other.soundId, soundId) || other.soundId == soundId)&&(identical(other.sound, sound) || other.sound == sound)&&const DeepCollectionEquality().equals(other._panels, _panels)&&(identical(other.postType, postType) || other.postType == postType)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.authorHandle, authorHandle) || other.authorHandle == authorHandle)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.amenCount, amenCount) || other.amenCount == amenCount)&&(identical(other.insightCount, insightCount) || other.insightCount == insightCount)&&(identical(other.thoughtProvokingCount, thoughtProvokingCount) || other.thoughtProvokingCount == thoughtProvokingCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,authorId,const DeepCollectionEquality().hash(_content),caption,visibility,currentVersion,isCorrection,correctsPostId,sermonSource,const DeepCollectionEquality().hash(_scriptureRefs),const DeepCollectionEquality().hash(_tags),isDeleted,coverImageUrl,reflectionImageUrl,soundId,sound,const DeepCollectionEquality().hash(_panels),postType,publishedAt,authorHandle,authorName,authorAvatarUrl,amenCount,insightCount,thoughtProvokingCount,commentCount]);

@override
String toString() {
  return 'Post(id: $id, authorId: $authorId, content: $content, caption: $caption, visibility: $visibility, currentVersion: $currentVersion, isCorrection: $isCorrection, correctsPostId: $correctsPostId, sermonSource: $sermonSource, scriptureRefs: $scriptureRefs, tags: $tags, isDeleted: $isDeleted, coverImageUrl: $coverImageUrl, reflectionImageUrl: $reflectionImageUrl, soundId: $soundId, sound: $sound, panels: $panels, postType: $postType, publishedAt: $publishedAt, authorHandle: $authorHandle, authorName: $authorName, authorAvatarUrl: $authorAvatarUrl, amenCount: $amenCount, insightCount: $insightCount, thoughtProvokingCount: $thoughtProvokingCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(fromJson: _contentFromJson) Map<String, dynamic> content, String? caption, String visibility,@JsonKey(name: 'current_version') int currentVersion,@JsonKey(name: 'is_correction') bool isCorrection,@JsonKey(name: 'corrects_post_id') String? correctsPostId,@JsonKey(name: 'sermon_source', fromJson: _sermonSourceFromJson) SermonSource? sermonSource,@JsonKey(name: 'scripture_refs') List<ScriptureRef> scriptureRefs, List<String> tags,@JsonKey(name: 'is_deleted') bool isDeleted,@JsonKey(name: 'cover_image_url') String? coverImageUrl,@JsonKey(name: 'reflection_image_url') String? reflectionImageUrl,@JsonKey(name: 'sound_id') String? soundId, SoundTrack? sound, List<PassagePanel> panels,@JsonKey(name: 'post_type') String postType,@JsonKey(name: 'published_at') DateTime publishedAt,@JsonKey(name: 'author_handle') String authorHandle,@JsonKey(name: 'author_name') String authorName,@JsonKey(name: 'author_avatar_url') String? authorAvatarUrl,@JsonKey(name: 'amen_count') int amenCount,@JsonKey(name: 'insight_count') int insightCount,@JsonKey(name: 'thought_provoking_count') int thoughtProvokingCount,@JsonKey(name: 'comment_count') int commentCount
});


@override $SermonSourceCopyWith<$Res>? get sermonSource;@override $SoundTrackCopyWith<$Res>? get sound;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? content = null,Object? caption = freezed,Object? visibility = null,Object? currentVersion = null,Object? isCorrection = null,Object? correctsPostId = freezed,Object? sermonSource = freezed,Object? scriptureRefs = null,Object? tags = null,Object? isDeleted = null,Object? coverImageUrl = freezed,Object? reflectionImageUrl = freezed,Object? soundId = freezed,Object? sound = freezed,Object? panels = null,Object? postType = null,Object? publishedAt = null,Object? authorHandle = null,Object? authorName = null,Object? authorAvatarUrl = freezed,Object? amenCount = null,Object? insightCount = null,Object? thoughtProvokingCount = null,Object? commentCount = null,}) {
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
as List<ScriptureRef>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,reflectionImageUrl: freezed == reflectionImageUrl ? _self.reflectionImageUrl : reflectionImageUrl // ignore: cast_nullable_to_non_nullable
as String?,soundId: freezed == soundId ? _self.soundId : soundId // ignore: cast_nullable_to_non_nullable
as String?,sound: freezed == sound ? _self.sound : sound // ignore: cast_nullable_to_non_nullable
as SoundTrack?,panels: null == panels ? _self._panels : panels // ignore: cast_nullable_to_non_nullable
as List<PassagePanel>,postType: null == postType ? _self.postType : postType // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorHandle: null == authorHandle ? _self.authorHandle : authorHandle // ignore: cast_nullable_to_non_nullable
as String,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,amenCount: null == amenCount ? _self.amenCount : amenCount // ignore: cast_nullable_to_non_nullable
as int,insightCount: null == insightCount ? _self.insightCount : insightCount // ignore: cast_nullable_to_non_nullable
as int,thoughtProvokingCount: null == thoughtProvokingCount ? _self.thoughtProvokingCount : thoughtProvokingCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
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
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoundTrackCopyWith<$Res>? get sound {
    if (_self.sound == null) {
    return null;
  }

  return $SoundTrackCopyWith<$Res>(_self.sound!, (value) {
    return _then(_self.copyWith(sound: value));
  });
}
}

// dart format on
