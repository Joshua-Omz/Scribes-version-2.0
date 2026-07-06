import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required Map<String, dynamic> content,
    String? caption,
    required String visibility,
    @JsonKey(name: 'current_version') required int currentVersion,
    @JsonKey(name: 'is_correction') required bool isCorrection,
    @JsonKey(name: 'corrects_post_id') String? correctsPostId,
    @JsonKey(name: 'sermon_source') String? sermonSource,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
    @JsonKey(name: 'published_at') required DateTime publishedAt,
    
    // Joined author fields
    @JsonKey(name: 'author_handle') required String authorHandle,
    @JsonKey(name: 'author_name') required String authorName,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
