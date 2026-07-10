import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../draft/data/draft_repository.dart';
import '../../posts/domain/sermon_source.dart';

final composeProvider = NotifierProvider<ComposeNotifier, ComposeState>(ComposeNotifier.new);

class ComposeState {
  final String draftId;
  final bool isSaving;
  final DateTime? lastSavedAt;
  final String title;
  final String caption;
  final SermonSource? sermonSource;
  final List<dynamic>? contentDelta;

  ComposeState({
    required this.draftId,
    this.isSaving = false,
    this.lastSavedAt,
    this.title = '',
    this.caption = '',
    this.sermonSource,
    this.contentDelta,
  });

  ComposeState copyWith({
    String? draftId,
    bool? isSaving,
    DateTime? lastSavedAt,
    String? title,
    String? caption,
    SermonSource? sermonSource,
    List<dynamic>? contentDelta,
  }) {
    return ComposeState(
      draftId: draftId ?? this.draftId,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      sermonSource: sermonSource ?? this.sermonSource,
      contentDelta: contentDelta ?? this.contentDelta,
    );
  }
}

class ComposeNotifier extends Notifier<ComposeState> {
  Timer? _debounce;
  QuillController? _lastController;

  @override
  ComposeState build() {
    return ComposeState(draftId: const Uuid().v4());
  }

  void updateTitle(String newTitle) {
    state = state.copyWith(title: newTitle);
    _triggerAutosave();
  }

  void updateMetadata({String? caption, SermonSource? sermonSource}) {
    state = state.copyWith(
      caption: caption ?? state.caption,
      sermonSource: sermonSource ?? state.sermonSource,
    );
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
    _debounce = Timer(const Duration(seconds: 3), () {
      if (_lastController != null) {
        _saveDraftLocally(_lastController!);
      }
    });
  }

  Future<void> forceSave() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    if (_lastController != null) {
      await _saveDraftLocally(_lastController!);
    }
  }

  Future<void> _saveDraftLocally(QuillController controller) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(draftRepositoryProvider);
    
    // Construct Sprint 5 standard JSON format
    final plainText = controller.document.toPlainText();
    final excerptText = plainText.length > 100 ? '${plainText.substring(0, 100)}...' : plainText;
    
    final contentMap = {
      'title': state.title,
      'excerpt': excerptText.trim(),
      'body': controller.document.toDelta().toJson(),
    };

    final jsonContent = jsonEncode(contentMap);
    
    String? sermonSourceJson;
    if (state.sermonSource != null) {
      sermonSourceJson = jsonEncode(state.sermonSource!.toJson());
    }

    final deltaJson = controller.document.toDelta().toJson();
    final List<String> scriptureTags = [];
    for (final op in deltaJson) {
      if (op is Map<String, dynamic> && op.containsKey('attributes')) {
        final attrs = op['attributes'];
        if (attrs is Map && attrs.containsKey('scripture')) {
          final tag = attrs['scripture'].toString();
          if (!scriptureTags.contains(tag)) {
            scriptureTags.add(tag);
          }
        }
      }
    }

    await repo.saveDraftLocally(
      state.draftId,
      jsonContent,
      caption: state.caption.trim().isEmpty ? null : state.caption.trim(),
      sermonSource: sermonSourceJson,
      scriptureTags: scriptureTags,
    );

    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      contentDelta: controller.document.toDelta().toJson(),
    );
  }

  Future<void> publishToCloud() async {
    final repo = ref.read(draftRepositoryProvider);
    await repo.publishDraft(state.draftId);
  }

  void reset() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = ComposeState(draftId: const Uuid().v4());
  }

  void loadDraft(String draftId, Map<String, dynamic> content, {String? caption, SermonSource? sermonSource}) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = ComposeState(
      draftId: draftId,
      title: content['title'] ?? '',
      caption: caption ?? '',
      sermonSource: sermonSource,
      contentDelta: content['body'] != null ? List<dynamic>.from(content['body']) : null,
    );
  }
}

