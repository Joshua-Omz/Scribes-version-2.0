import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../data/note_repository.dart';

final noteEditorProvider = NotifierProvider<NoteEditorNotifier, NoteEditorState>(() => NoteEditorNotifier());

class NoteEditorState {
  final String noteId;
  final bool isSaving;
  final DateTime? lastSavedAt;
  final String title;
  final String? notebookId;
  final List<dynamic>? contentDelta;

  NoteEditorState({
    required this.noteId,
    this.isSaving = false,
    this.lastSavedAt,
    this.title = '',
    this.notebookId,
    this.contentDelta,
  });

  NoteEditorState copyWith({
    String? noteId,
    bool? isSaving,
    DateTime? lastSavedAt,
    String? title,
    String? notebookId,
    List<dynamic>? contentDelta,
  }) {
    return NoteEditorState(
      noteId: noteId ?? this.noteId,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      title: title ?? this.title,
      notebookId: notebookId ?? this.notebookId,
      contentDelta: contentDelta ?? this.contentDelta,
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

  void onDocumentChanged(QuillController controller) {
    _lastController = controller;
    _triggerAutosave();
  }

  void syncContent(QuillController controller) {
    _lastController = controller;
    state = state.copyWith(contentDelta: controller.document.toDelta().toJson());
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
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (_lastController != null) {
      await _saveNoteLocally(_lastController!);
    }
  }

  Future<void> _saveNoteLocally(QuillController controller) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(noteRepositoryProvider);
    
    final contentMap = {
      'title': state.title,
      'body': controller.document.toDelta().toJson(),
    };

    final jsonContent = jsonEncode(contentMap);
    
    await repo.saveNoteLocally(
      state.noteId,
      jsonContent,
      title: state.title.trim().isEmpty ? null : state.title.trim(),
      notebookId: state.notebookId,
    );

    // Trigger cloud sync in background
    () async {
      try {
        await repo.pushToCloud(state.noteId);
      } catch (_) {}
    }();

    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      contentDelta: controller.document.toDelta().toJson(),
    );
  }

  Future<void> promoteToDraft() async {
    await forceSave();
    final repo = ref.read(noteRepositoryProvider);
    await repo.promoteToDraft(state.noteId);
  }

  void reset({String? notebookId}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = NoteEditorState(noteId: const Uuid().v4(), notebookId: notebookId);
  }

  void loadNote(String noteId, Map<String, dynamic> content, {String? title, String? notebookId}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = NoteEditorState(
      noteId: noteId,
      title: title ?? content['title'] ?? '',
      notebookId: notebookId,
      contentDelta: content['body'] != null ? List<dynamic>.from(content['body']) : null,
    );
  }
}
