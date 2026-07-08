// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReactionCount _$ReactionCountFromJson(Map<String, dynamic> json) =>
    _ReactionCount(
      type: json['type'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$ReactionCountToJson(_ReactionCount instance) =>
    <String, dynamic>{'type': instance.type, 'count': instance.count};
