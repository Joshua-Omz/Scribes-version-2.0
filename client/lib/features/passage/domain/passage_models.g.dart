// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passage_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoundTrack _$SoundTrackFromJson(Map<String, dynamic> json) => _SoundTrack(
  id: json['id'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  audioUrl: json['audio_url'] as String,
  durationSeconds: (json['duration_seconds'] as num).toInt(),
);

Map<String, dynamic> _$SoundTrackToJson(_SoundTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'audio_url': instance.audioUrl,
      'duration_seconds': instance.durationSeconds,
    };

_PassagePanel _$PassagePanelFromJson(Map<String, dynamic> json) =>
    _PassagePanel(
      id: json['id'] as String? ?? '',
      postId: json['post_id'] as String? ?? '',
      panelOrder: (json['panel_order'] as num?)?.toInt() ?? 0,
      panelType: json['panel_type'] as String,
      content: _panelContentFromJson(json['content']),
      backgroundImageUrl: json['background_image_url'] as String?,
      scriptureRef: _panelScriptureRefFromJson(json['scripture_ref']),
    );

Map<String, dynamic> _$PassagePanelToJson(_PassagePanel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'post_id': instance.postId,
      'panel_order': instance.panelOrder,
      'panel_type': instance.panelType,
      'content': instance.content,
      'background_image_url': instance.backgroundImageUrl,
      'scripture_ref': instance.scriptureRef,
    };
