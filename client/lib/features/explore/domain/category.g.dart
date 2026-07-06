// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PostCategory _$PostCategoryFromJson(Map<String, dynamic> json) =>
    _PostCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      isDeprecated: json['is_deprecated'] as bool,
    );

Map<String, dynamic> _$PostCategoryToJson(_PostCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_deprecated': instance.isDeprecated,
    };
