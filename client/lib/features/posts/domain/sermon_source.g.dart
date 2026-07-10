// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sermon_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SermonSource _$SermonSourceFromJson(Map<String, dynamic> json) =>
    _SermonSource(
      preacher: json['preacher'] as String?,
      church: json['church'] as String?,
      date: json['date'] as String?,
      series: json['series'] as String?,
    );

Map<String, dynamic> _$SermonSourceToJson(_SermonSource instance) =>
    <String, dynamic>{
      'preacher': instance.preacher,
      'church': instance.church,
      'date': instance.date,
      'series': instance.series,
    };
