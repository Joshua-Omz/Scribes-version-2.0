import '../../core/storage/drift_database.dart';
import 'dart:convert';

class PendingRecord {
  final String localId;
  final String type; // "note" | "draft"
  final Map<String, dynamic> content;
  final DateTime updatedAt;

  PendingRecord({
    required this.localId,
    required this.type,
    required this.content,
    required this.updatedAt,
  });

  factory PendingRecord.fromNote(Note note) {
    // We assume the content column is a JSON string of the rich text or payload.
    // For syncing, we might also want to include the title, etc.
    final contentMap = {
      'content': note.content,
      'title': note.title,
      'notebook_id': note.notebookId,
      'created_at': note.createdAt.toIso8601String(),
    };
    return PendingRecord(
      localId: note.id,
      type: 'note',
      content: contentMap,
      updatedAt: note.updatedAt,
    );
  }

  factory PendingRecord.fromDraft(Draft draft) {
    final contentMap = {
      'content': draft.content,
      'caption': draft.caption,
      'sermon_source': draft.sermonSource,
      'scripture_tags': draft.scriptureTags,
      'created_at': draft.createdAt.toIso8601String(),
    };
    return PendingRecord(
      localId: draft.id,
      type: 'draft',
      content: contentMap,
      updatedAt: draft.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'local_id': localId,
      'type': type,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
