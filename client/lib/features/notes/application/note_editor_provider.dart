import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../data/note_repository.dart';
import 'notes_list_provider.dart';
import '../../draft/application/drafts_list_provider.dart';
import '../../../core/theme/scribes_quill_scripture_helper.dart';

final noteEditorProvider =
    NotifierProvider<NoteEditorNotifier, NoteEditorState>(
      () => NoteEditorNotifier(),
    );

class NoteEditorState {
  final String noteId;
  final bool isSaving;
  final DateTime? lastSavedAt;
  final String title;
  final String? notebookId;
  final List<dynamic>? contentDelta;
  final List<String> scriptureRefs;

  NoteEditorState({
    required this.noteId,
    this.isSaving = false,
    this.lastSavedAt,
    this.title = '',
    this.notebookId,
    this.contentDelta,
    this.scriptureRefs = const [],
  });

  NoteEditorState copyWith({
    String? noteId,
    bool? isSaving,
    DateTime? lastSavedAt,
    String? title,
    String? notebookId,
    List<dynamic>? contentDelta,
    List<String>? scriptureRefs,
  }) {
    return NoteEditorState(
      noteId: noteId ?? this.noteId,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      title: title ?? this.title,
      notebookId: notebookId ?? this.notebookId,
      contentDelta: contentDelta ?? this.contentDelta,
      scriptureRefs: scriptureRefs ?? this.scriptureRefs,
    );
  }
}

class NoteEditorNotifier extends Notifier<NoteEditorState> {
  Timer? _debounce;
  QuillController? _lastController;

  @override
  NoteEditorState build() {
    return NoteEditorState(noteId: const Uuid().v4());
  }

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
    _triggerAutosave();
  }

  void setNotebook(String? notebookId) {
    state = state.copyWith(notebookId: notebookId);
    _triggerAutosave();
  }

  void addScripture(String reference) {
    final trimmed = reference.trim();
    if (trimmed.isNotEmpty && !state.scriptureRefs.contains(trimmed)) {
      state = state.copyWith(scriptureRefs: [...state.scriptureRefs, trimmed]);
      _triggerAutosave();
    }
  }

  void removeScripture(String reference) {
    state = state.copyWith(
      scriptureRefs: state.scriptureRefs.where((r) => r != reference).toList(),
    );
    _triggerAutosave();
  }

  void onDocumentChanged(QuillController controller) {
    _lastController = controller;

    final newDelta = controller.document.toDelta().toJson();
    final isContentDifferent =
        state.contentDelta == null ||
        jsonEncode(state.contentDelta) != jsonEncode(newDelta);

    if (isContentDifferent) {
      _triggerAutosave();
    }
  }

  void syncContent(QuillController controller) {
    _lastController = controller;
    state = state.copyWith(
      contentDelta: controller.document.toDelta().toJson(),
    );
  }

  void _triggerAutosave() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      if (_lastController != null) {
        _saveNoteLocally(_lastController!);
      }
    });
  }

  Future<void> forceSave() async {
    final wasDebounceActive = _debounce?.isActive ?? false;
    if (wasDebounceActive) _debounce?.cancel();

    if (_lastController != null) {
      final newDelta = _lastController!.document.toDelta().toJson();
      final isContentDifferent =
          state.contentDelta == null ||
          jsonEncode(state.contentDelta) != jsonEncode(newDelta);

      if (isContentDifferent || wasDebounceActive) {
        await _saveNoteLocally(_lastController!);
      }
    }
  }

  Future<void> _saveNoteLocally(QuillController controller) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(noteRepositoryProvider);
    final deltaJson = controller.document.toDelta().toJson();

    // Extract inline scripture references and merge with top-level tags
    final inlineRefs = ScribesQuillScriptureHelper.extractScriptureRefs(deltaJson);
    final allRefs = <String>{...state.scriptureRefs, ...inlineRefs}.toList();

    final contentMap = {
      'title': state.title,
      'body': deltaJson,
      'scripture_refs': allRefs,
    };

    final jsonContent = jsonEncode(contentMap);

    await repo.saveNoteLocally(
      state.noteId,
      jsonContent,
      title: state.title.trim().isEmpty ? null : state.title.trim(),
      notebookId: state.notebookId,
    );

    ref.read(notesListProvider.notifier).refresh();

    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      contentDelta: deltaJson,
      scriptureRefs: allRefs,
    );
  }

  Future<String> promoteToDraft() async {
    await forceSave();
    final repo = ref.read(noteRepositoryProvider);
    final draftData = await repo.promoteToDraft(state.noteId);
    ref.read(notesListProvider.notifier).refresh();
    ref.read(draftsListProvider.notifier).refresh();
    return draftData['id'] as String;
  }

  void reset({String? notebookId}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = NoteEditorState(noteId: const Uuid().v4(), notebookId: notebookId);
  }

  void loadNote(
    String noteId,
    Map<String, dynamic> content, {
    String? title,
    String? notebookId,
  }) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    final refs = content['scripture_refs'] != null
        ? List<String>.from(content['scripture_refs'])
        : <String>[];

    state = NoteEditorState(
      noteId: noteId,
      title: title ?? content['title'] ?? '',
      notebookId: notebookId,
      contentDelta: content['body'] != null
          ? List<dynamic>.from(content['body'])
          : null,
      scriptureRefs: refs,
    );
  }
}
