import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
abstract class PostCategory with _$PostCategory {
  const factory PostCategory({
    required String id,
    required String name,
    @JsonKey(name: 'is_deprecated') required bool isDeprecated,
  }) = _PostCategory;

  factory PostCategory.fromJson(Map<String, dynamic> json) => _$PostCategoryFromJson(json);
}
