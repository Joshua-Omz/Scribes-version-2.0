import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/posts/domain/post_version.dart';

part 'post_detail_state.freezed.dart';

@freezed
abstract class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    required Post post,
    @Default([]) List<PostVersion> versions,
  }) = _PostDetailState;
}
