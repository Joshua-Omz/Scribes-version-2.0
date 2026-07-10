import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_event.freezed.dart';
part 'sync_event.g.dart';

@freezed
abstract class SyncEvent with _$SyncEvent {
  const factory SyncEvent({
    required String type,
    required String id,
    required Map<String, dynamic> content,
    @JsonKey(name: 'title_or_caption') String? titleOrCaption,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'server_sequence') required int serverSequence,
    @JsonKey(name: 'ts') required DateTime timestamp,
  }) = _SyncEvent;

  factory SyncEvent.fromJson(Map<String, dynamic> json) => _$SyncEventFromJson(json);
}
