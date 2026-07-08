import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'author_id') required String authorId,
    required String body,
    List<String>? mentions,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_hidden') required bool isHidden,
    @JsonKey(name: 'is_deleted') required bool isDeleted,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}
