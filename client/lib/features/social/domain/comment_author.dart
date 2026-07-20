import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_author.freezed.dart';
part 'comment_author.g.dart';

/// Lightweight user profile for comment author display and @mention search.
/// Matches the shape returned by GET /users/:id and GET /users/search.
@freezed
abstract class CommentAuthor with _$CommentAuthor {
  const factory CommentAuthor({
    required String id,
    required String handle,
    @JsonKey(name: 'display_name') required String displayName,
    String? bio,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
  }) = _CommentAuthor;

  factory CommentAuthor.fromJson(Map<String, dynamic> json) =>
      _$CommentAuthorFromJson(json);
}
