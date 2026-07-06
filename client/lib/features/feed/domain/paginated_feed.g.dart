// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedFeed _$PaginatedFeedFromJson(Map<String, dynamic> json) =>
    _PaginatedFeed(
      posts: (json['posts'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$PaginatedFeedToJson(_PaginatedFeed instance) =>
    <String, dynamic>{
      'posts': instance.posts,
      'next_cursor': instance.nextCursor,
    };
