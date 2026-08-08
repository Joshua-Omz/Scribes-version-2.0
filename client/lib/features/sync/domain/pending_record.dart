import '../../../core/storage/drift_database.dart';
import 'dart:convert';

class PendingRecord {
  final String id;
  final String type; // "note" | "draft"
  final Map<String, dynamic> content;
  final String? titleOrCaption;
  final String? parentId; // notebook_id for notes
  final String? sermonSource; // for drafts
  final String? sourceType;
  final String? sourceLabel;
  final DateTime updatedAt;

  PendingRecord({
    required this.id,
    required this.type,
    required this.content,
    this.titleOrCaption,
    this.parentId,
    this.sermonSource,
    this.sourceType,
    this.sourceLabel,
    required this.updatedAt,
  });

  factory PendingRecord.fromNote(Note note) {
    Map<String, dynamic> contentMap = {};
    try {
      if (note.content.isNotEmpty) {
         contentMap = jsonDecode(note.content);
      }
    } catch (_) {
      contentMap = {'text': note.content};
    }
    
    return PendingRecord(
      id: note.id,
      type: 'note',
      content: contentMap,
      titleOrCaption: note.title,
      parentId: note.notebookId,
      updatedAt: note.updatedAt,
    );
  }

  factory PendingRecord.fromDraft(Draft draft) {
    Map<String, dynamic> contentMap = {};
    try {
      if (draft.content.isNotEmpty) {
         contentMap = jsonDecode(draft.content);
      }
    } catch (_) {
      contentMap = {'text': draft.content};
    }

    return PendingRecord(
      id: draft.id,
      type: 'draft',
      content: contentMap,
      titleOrCaption: draft.caption,
      sermonSource: draft.sermonSource,
      updatedAt: draft.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'type': type,
      'content': content,
    };
    if (titleOrCaption != null) map['title_or_caption'] = titleOrCaption;
    if (parentId != null) map['parent_id'] = parentId;
    if (sermonSource != null) map['sermon_source'] = sermonSource;
    if (sourceType != null) map['source_type'] = sourceType;
    if (sourceLabel != null) map['source_label'] = sourceLabel;
    
    return map;
  }
}
