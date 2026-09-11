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

  factory ScriptureRef.fromJson(Map<String, dynamic> json) =>
      _$ScriptureRefFromJson(json);

  static ScriptureRef? tryParse(String refStr) {
    try {
      final trimmed = refStr.trim();
      final lastSpace = trimmed.lastIndexOf(' ');
      if (lastSpace == -1) return null;
      final book = trimmed.substring(0, lastSpace).trim();
      final rest = trimmed.substring(lastSpace + 1).trim();
      final colonIdx = rest.indexOf(':');
      if (colonIdx == -1) return null;
      final chapter = int.tryParse(rest.substring(0, colonIdx));
      if (chapter == null) return null;
      final versePart = rest.substring(colonIdx + 1);
      if (versePart.contains('-')) {
        final parts = versePart.split('-');
        final vStart = int.tryParse(parts[0].trim());
        final vEnd = int.tryParse(parts[1].trim());
        if (vStart != null) {
          return ScriptureRef(
            book: book,
            chapter: chapter,
            verseStart: vStart,
            verseEnd: vEnd,
          );
        }
      } else {
        final vStart = int.tryParse(versePart.trim());
        if (vStart != null) {
          return ScriptureRef(
            book: book,
            chapter: chapter,
            verseStart: vStart,
          );
        }
      }
    } catch (_) {}
    return null;
  }
}
