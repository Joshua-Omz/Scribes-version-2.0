import '../../auth/domain/user.dart';
import '../../draft/domain/draft.dart';
import '../../notes/domain/note.dart';
import '../../posts/domain/post.dart';
import '../../posts/domain/scripture_ref.dart';

/// Abstract domain interface for any document that can be compiled into an illuminated PDF manuscript.
abstract class ExportableDocument {
  String get id;
  String get title;
  String get authorDisplayName;
  String get authorHandle;
  DateTime get date;
  dynamic get bodyContent; // String, Map, or List of Delta ops
  String? get coverImageUrl; // Supports remote URL or local file://
  List<ScriptureRef> get scriptureRefs;
  String? get sermonSource;
  String get documentTypeBadge; // 'MANUSCRIPT', 'DRAFT', 'STUDY NOTE'
  bool get isExportable;
}

/// Adapter converting a published [Post] into an [ExportableDocument].
class PostExportAdapter implements ExportableDocument {
  final Post post;

  PostExportAdapter(this.post);

  @override
  String get id => post.id;

  @override
  String get title => (post.content['title'] as String?)?.trim().isNotEmpty == true
      ? (post.content['title'] as String).trim()
      : 'Untitled Manuscript';

  @override
  String get authorDisplayName =>
      post.authorName.isNotEmpty ? post.authorName : post.authorHandle;

  @override
  String get authorHandle => post.authorHandle;

  @override
  DateTime get date => post.publishedAt;

  @override
  dynamic get bodyContent => post.content;

  @override
  String? get coverImageUrl => post.coverImageUrl;

  @override
  List<ScriptureRef> get scriptureRefs => post.scriptureRefs;

  @override
  String? get sermonSource => post.sermonSource?.displayTitle;

  @override
  String get documentTypeBadge => 'MANUSCRIPT';

  @override
  bool get isExportable => post.postType == 'standard';
}

/// Adapter converting a [Draft] into an [ExportableDocument].
class DraftExportAdapter implements ExportableDocument {
  final Draft draft;
  final User? currentUser;

  DraftExportAdapter(this.draft, {this.currentUser});

  @override
  String get id => draft.id;

  @override
  String get title {
    final t = draft.content['title']?.toString().trim();
    return (t != null && t.isNotEmpty) ? t : 'Untitled Draft';
  }

  @override
  String get authorDisplayName {
    final user = currentUser;
    if (user != null && user.displayName.trim().isNotEmpty) {
      return user.displayName.trim();
    }
    if (user != null && user.handle.trim().isNotEmpty) {
      return user.handle.trim();
    }
    return 'Scribe';
  }

  @override
  String get authorHandle => currentUser?.handle ?? 'scribe';

  @override
  DateTime get date => draft.updatedAt;

  @override
  dynamic get bodyContent => draft.content;

  @override
  String? get coverImageUrl => draft.coverImageUrl;

  @override
  List<ScriptureRef> get scriptureRefs {
    final list = <ScriptureRef>[];
    // Check structured tags in draft
    for (final tag in draft.scriptureTags) {
      final parsed = _tryParseScriptureRef(tag);
      if (parsed != null) list.add(parsed);
    }
    // Check content scripture_refs if present
    if (draft.content['scripture_refs'] is List) {
      for (final item in draft.content['scripture_refs'] as List) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(ScriptureRef.fromJson(item));
          } catch (_) {}
        }
      }
    }
    return list;
  }

  @override
  String? get sermonSource => draft.sermonSource?.displayTitle;

  @override
  String get documentTypeBadge => 'DRAFT';

  @override
  bool get isExportable => draft.postType == 'standard';

  static ScriptureRef? _tryParseScriptureRef(String text) {
    // Basic parser for "John 3:16" or "Romans 8:28-30"
    final regex = RegExp(r'^([\d\s\w]+)\s+(\d+):(\d+)(?:-(\d+))?$');
    final match = regex.firstMatch(text.trim());
    if (match != null) {
      final book = match.group(1)!.trim();
      final chapter = int.tryParse(match.group(2)!) ?? 1;
      final start = int.tryParse(match.group(3)!) ?? 1;
      final end = match.group(4) != null ? int.tryParse(match.group(4)!) : null;
      return ScriptureRef(
        book: book,
        chapter: chapter,
        verseStart: start,
        verseEnd: end,
      );
    }
    return null;
  }
}

/// Adapter converting a [Note] into an [ExportableDocument].
class NoteExportAdapter implements ExportableDocument {
  final Note note;
  final User? currentUser;

  NoteExportAdapter(this.note, {this.currentUser});

  @override
  String get id => note.id;

  @override
  String get title => (note.title != null && note.title!.trim().isNotEmpty)
      ? note.title!.trim()
      : 'Study Note';

  @override
  String get authorDisplayName {
    final user = currentUser;
    if (user != null && user.displayName.trim().isNotEmpty) {
      return user.displayName.trim();
    }
    if (user != null && user.handle.trim().isNotEmpty) {
      return user.handle.trim();
    }
    return 'Scribe';
  }

  @override
  String get authorHandle => currentUser?.handle ?? 'scribe';

  @override
  DateTime get date => note.updatedAt;

  @override
  dynamic get bodyContent => note.content;

  @override
  String? get coverImageUrl => null;

  @override
  List<ScriptureRef> get scriptureRefs => const [];

  @override
  String? get sermonSource => null;

  @override
  String get documentTypeBadge => 'STUDY NOTE';

  @override
  bool get isExportable => true;
}
