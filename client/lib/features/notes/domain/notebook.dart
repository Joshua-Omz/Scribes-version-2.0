import 'package:freezed_annotation/freezed_annotation.dart';

part 'notebook.freezed.dart';
part 'notebook.g.dart';

@freezed
abstract class Notebook with _$Notebook {
  const factory Notebook({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Notebook;

  factory Notebook.fromJson(Map<String, dynamic> json) => _$NotebookFromJson(json);
}
