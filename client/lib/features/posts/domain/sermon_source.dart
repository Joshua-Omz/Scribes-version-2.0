import 'package:freezed_annotation/freezed_annotation.dart';

part 'sermon_source.freezed.dart';
part 'sermon_source.g.dart';

@freezed
abstract class SermonSource with _$SermonSource {
  const SermonSource._();

  const factory SermonSource({
    String? preacher,
    String? church,
    String? date,
    String? series,
  }) = _SermonSource;

  bool get isNotEmpty => (preacher?.isNotEmpty ?? false) || (church?.isNotEmpty ?? false) || (series?.isNotEmpty ?? false);
  
  String get displayTitle {
    if (preacher != null && church != null) return '$preacher at $church';
    return preacher ?? church ?? series ?? 'Sermon Note';
  }

  factory SermonSource.fromJson(Map<String, dynamic> json) => _$SermonSourceFromJson(json);
}
