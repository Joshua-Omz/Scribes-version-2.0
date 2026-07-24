import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture_ref.freezed.dart';
part 'scripture_ref.g.dart';

int? _verseEndFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is Map<String, dynamic>) {
    if (value['Valid'] == true) {
      return value['Int32'] as int?;
    }
    return null;
  }
  return null;
}

@freezed
abstract class ScriptureRef with _$ScriptureRef {
  const factory ScriptureRef({
    required String book,
    required int chapter,
    @JsonKey(name: 'verse_start') required int verseStart,
    @JsonKey(name: 'verse_end', fromJson: _verseEndFromJson) int? verseEnd,
  }) = _ScriptureRef;

  factory ScriptureRef.fromJson(Map<String, dynamic> json) => _$ScriptureRefFromJson(json);
}
