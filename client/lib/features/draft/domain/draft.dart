import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft.freezed.dart';
part 'draft.g.dart';

@freezed
abstract class Draft with _$Draft {
  const factory Draft({
    required String id,
    @JsonKey(name: 'author_id') required String authorId,
    required Map<String, dynamic> content,
    String? caption,
    @JsonKey(name: 'sermon_source') String? sermonSource,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Draft;

  factory Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);
}
