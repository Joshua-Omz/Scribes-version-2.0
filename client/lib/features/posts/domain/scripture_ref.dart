import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture_ref.freezed.dart';
part 'scripture_ref.g.dart';

@freezed
abstract class ScriptureRef with _$ScriptureRef {
  const factory ScriptureRef({
    required String book,
    required int chapter,
    @JsonKey(name: 'verse_start') required int verseStart,
    @JsonKey(name: 'verse_end') int? verseEnd,
  }) = _ScriptureRef;

  factory ScriptureRef.fromJson(Map<String, dynamic> json) => _$ScriptureRefFromJson(json);
}
