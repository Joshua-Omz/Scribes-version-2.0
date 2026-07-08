import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_count.freezed.dart';
part 'reaction_count.g.dart';

@freezed
abstract class ReactionCount with _$ReactionCount {
  const factory ReactionCount({
    required String type,
    required int count,
  }) = _ReactionCount;

  factory ReactionCount.fromJson(Map<String, dynamic> json) => _$ReactionCountFromJson(json);
}
