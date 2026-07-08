import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_version.freezed.dart';
part 'post_version.g.dart';

@freezed
abstract class PostVersion with _$PostVersion {
  const factory PostVersion({
    required String id,
    @JsonKey(name: 'post_id') required String postId,
    @JsonKey(name: 'version_number') required int versionNumber,
    @JsonKey(name: 'content_snapshot') required Map<String, dynamic> contentSnapshot,
    @JsonKey(name: 'snapshotted_at') required DateTime snapshottedAt,
    @JsonKey(name: 'snapshotted_by') required String snapshottedBy,
  }) = _PostVersion;

  factory PostVersion.fromJson(Map<String, dynamic> json) => _$PostVersionFromJson(json);
}
