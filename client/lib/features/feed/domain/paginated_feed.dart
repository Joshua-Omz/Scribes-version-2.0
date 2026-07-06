import 'package:freezed_annotation/freezed_annotation.dart';
import '../../posts/domain/post.dart';

part 'paginated_feed.freezed.dart';
part 'paginated_feed.g.dart';

@freezed
abstract class PaginatedFeed with _$PaginatedFeed {
  const factory PaginatedFeed({
    required List<Post> posts,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _PaginatedFeed;

  factory PaginatedFeed.fromJson(Map<String, dynamic> json) => _$PaginatedFeedFromJson(json);
}
