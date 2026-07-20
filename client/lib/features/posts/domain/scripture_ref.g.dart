// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scripture_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScriptureRef _$ScriptureRefFromJson(Map<String, dynamic> json) =>
    _ScriptureRef(
      book: json['book'] as String,
      chapter: (json['chapter'] as num).toInt(),
      verseStart: (json['verse_start'] as num).toInt(),
      verseEnd: (json['verse_end'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScriptureRefToJson(_ScriptureRef instance) =>
    <String, dynamic>{
      'book': instance.book,
      'chapter': instance.chapter,
      'verse_start': instance.verseStart,
      'verse_end': instance.verseEnd,
    };
