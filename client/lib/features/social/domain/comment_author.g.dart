// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentAuthor _$CommentAuthorFromJson(Map<String, dynamic> json) =>
    _CommentAuthor(
      id: json['id'] as String,
      handle: json['handle'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
    );

Map<String, dynamic> _$CommentAuthorToJson(_CommentAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'handle': instance.handle,
      'display_name': instance.displayName,
      'bio': instance.bio,
    };
