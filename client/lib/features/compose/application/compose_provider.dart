import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../../draft/data/draft_repository.dart';
import '../../draft/application/drafts_list_provider.dart';
import '../../posts/domain/sermon_source.dart';
import '../../posts/domain/scripture_ref.dart';

final composeProvider = NotifierProvider<ComposeNotifier, ComposeState>(() => ComposeNotifier());

class ComposeState {
  final String draftId;
  final bool isSaving;
  final DateTime? lastSavedAt;
  final String title;
  final String caption;
  final SermonSource? sermonSource;
  final List<dynamic>? contentDelta;
  final List<String> tags;
  final List<ScriptureRef> scriptureRefs;
  final String postType;
  final String? coverImageUrl;

  ComposeState({
    required this.draftId,
    this.isSaving = false,
    this.lastSavedAt,
    this.title = '',
    this.caption = '',
    this.sermonSource,
    this.contentDelta,
    this.tags = const [],
    this.scriptureRefs = const [],
    this.postType = 'standard',
    this.coverImageUrl,
  });

  ComposeState copyWith({
    String? draftId,
    bool? isSaving,
    DateTime? lastSavedAt,
    String? title,
    String? caption,
    SermonSource? sermonSource,
    List<dynamic>? contentDelta,
    List<String>? tags,
    List<ScriptureRef>? scriptureRefs,
    String? postType,
    String? coverImageUrl,
  }) {
    return ComposeState(
      draftId: draftId ?? this.draftId,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      sermonSource: sermonSource ?? this.sermonSource,
      contentDelta: contentDelta ?? this.contentDelta,
      tags: tags ?? this.tags,
      scriptureRefs: scriptureRefs ?? this.scriptureRefs,
      postType: postType ?? this.postType,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
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

  void updateMetadata({
    String? caption,
    SermonSource? sermonSource,
    String? postType,
    String? coverImageUrl,
  }) {
    state = state.copyWith(
      caption: caption ?? state.caption,
      sermonSource: sermonSource ?? state.sermonSource,
      postType: postType ?? state.postType,
      coverImageUrl: coverImageUrl ?? state.coverImageUrl,
    );
    _triggerAutosave();
  }

  void addTag(String tag) {
    final current = List<String>.from(state.tags);
    final normalizedTag = tag.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalizedTag.isEmpty) return;
    // Keep the original casing for display when adding
    final tagToAdd = tag.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    if (!current.map((t) => t.toLowerCase()).contains(normalizedTag)) {
      if (current.length >= 8) return; // Enforce max 8 tags
      current.add(tagToAdd);
      state = state.copyWith(tags: current);
      _triggerAutosave();
    }
  }

  void removeTag(String tag) {
    final current = List<String>.from(state.tags);
    current.remove(tag);
    state = state.copyWith(tags: current);
    _triggerAutosave();
  }

  void addScriptureRef(ScriptureRef ref) {
    if (state.scriptureRefs.length >= 3) return;
    state = state.copyWith(scriptureRefs: [...state.scriptureRefs, ref]);
    _triggerAutosave();
  }

  void removeScriptureRef(ScriptureRef ref) {
    state = state.copyWith(
      scriptureRefs: state.scriptureRefs.where((r) => r != ref).toList()
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

    // For compatibility with any legacy fields if necessary
    final List<String> scriptureTags = state.scriptureRefs.map((r) {
      if (r.verseEnd != null) return '${r.book} ${r.chapter}:${r.verseStart}-${r.verseEnd}';
      return '${r.book} ${r.chapter}:${r.verseStart}';
    }).toList();

    await repo.saveDraftLocally(
      state.draftId,
      jsonContent,
      caption: state.caption.trim().isEmpty ? null : state.caption.trim(),
      sermonSource: sermonSourceJson,
      scriptureTags: scriptureTags,

      // Note: we might need to serialize scriptureRefs natively to Drafts later, 
      // but for v1 it might be handled in Draft Repository.
    );

    ref.read(draftsListProvider.notifier).refresh();

    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      contentDelta: controller.document.toDelta().toJson(),
    );

    // Show a small global toast for autosave
    try {
      final themeColors = ref.read(themeProvider);
      ScribesToast.show(
        null, // Use global scaffold key
        'Draft saved',
        themeColors,
        icon: HugeIcons.strokeRoundedCloudSavingDone01,
      );
    } catch (_) {}
  }

  Future<void> publishToCloud() async {
    await forceSave();
    final repo = ref.read(draftRepositoryProvider);
    await repo.publishDraft(state.draftId, tags: state.tags, scriptureRefs: state.scriptureRefs);
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
