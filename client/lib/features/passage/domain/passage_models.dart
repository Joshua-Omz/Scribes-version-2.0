import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'passage_models.freezed.dart';
part 'passage_models.g.dart';

Map<String, dynamic> _panelContentFromJson(dynamic value) {
  if (value == null) return const {};
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    if (value.trim().isEmpty) return const {};
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      if (decoded is String) {
        try {
          final doubleDecoded = jsonDecode(decoded);
          if (doubleDecoded is Map<String, dynamic>) return doubleDecoded;
          if (doubleDecoded is Map) return Map<String, dynamic>.from(doubleDecoded);
        } catch (_) {}
      }
    } catch (_) {}
    return {'text': value};
  }
  return const {};
}

Map<String, dynamic>? _panelScriptureRefFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    if (value.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

@freezed
abstract class SoundTrack with _$SoundTrack {
  const factory SoundTrack({
    required String id,
    required String title,
    required String category,
    @JsonKey(name: 'audio_url') required String audioUrl,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
  }) = _SoundTrack;

  factory SoundTrack.fromJson(Map<String, dynamic> json) =>
      _$SoundTrackFromJson(json);
}

@freezed
abstract class PassagePanel with _$PassagePanel {
  const factory PassagePanel({
    @Default('') String id,
    @JsonKey(name: 'post_id') @Default('') String postId,
    @JsonKey(name: 'panel_order') @Default(0) int panelOrder,
    @JsonKey(name: 'panel_type') required String panelType,
    @JsonKey(fromJson: _panelContentFromJson)
    @Default({})
    Map<String, dynamic> content,
    @JsonKey(name: 'background_image_url') String? backgroundImageUrl,
    @JsonKey(name: 'scripture_ref', fromJson: _panelScriptureRefFromJson)
    Map<String, dynamic>? scriptureRef,
  }) = _PassagePanel;

  factory PassagePanel.fromJson(Map<String, dynamic> json) =>
      _$PassagePanelFromJson(json);
}

