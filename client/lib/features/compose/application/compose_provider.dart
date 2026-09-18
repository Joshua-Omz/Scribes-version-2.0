import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../draft/data/draft_repository.dart';
import '../../draft/application/drafts_list_provider.dart';
import '../../feed/application/feed_notifier.dart';
import '../../../core/network/media_api.dart';
import '../../posts/domain/sermon_source.dart';
import '../../posts/domain/scripture_ref.dart';
import '../../../core/theme/scribes_quill_scripture_helper.dart';

final composeProvider = NotifierProvider<ComposeNotifier, ComposeState>(
  () => ComposeNotifier(),
);

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
  final List<ScriptureRef> publishScriptureRefs;
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
    this.publishScriptureRefs = const [],
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
    List<ScriptureRef>? publishScriptureRefs,
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
      publishScriptureRefs:
          publishScriptureRefs ?? this.publishScriptureRefs,
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
    final normalizedTag = tag.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
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
    if (state.scriptureRefs.contains(ref)) return;
    state = state.copyWith(scriptureRefs: [...state.scriptureRefs, ref]);
    _triggerAutosave();
  }

  void removeScriptureRef(ScriptureRef ref) {
    state = state.copyWith(
      scriptureRefs: state.scriptureRefs.where((r) => r != ref).toList(),
    );
    _triggerAutosave();
  }

  void setPublishScriptureRefs(List<ScriptureRef> refs) {
    state = state.copyWith(
      publishScriptureRefs: refs.take(3).toList(),
    );
    _triggerAutosave();
  }

  void addPublishScriptureRef(ScriptureRef ref) {
    if (state.publishScriptureRefs.length >= 3) return;
    if (state.publishScriptureRefs.contains(ref)) return;
    state = state.copyWith(
      publishScriptureRefs: [...state.publishScriptureRefs, ref],
    );
    _triggerAutosave();
  }

  void removePublishScriptureRef(ScriptureRef ref) {
    state = state.copyWith(
      publishScriptureRefs:
          state.publishScriptureRefs.where((r) => r != ref).toList(),
    );
    _triggerAutosave();
  }

  void onDocumentChanged(QuillController controller) {
    _lastController = controller;
    _triggerAutosave();
  }

  void syncContent(QuillController controller) {
    _lastController = controller;
    state = state.copyWith(
      contentDelta: controller.document.toDelta().toJson(),
    );
  }

  void _triggerAutosave() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 3), () {
      _saveDraftLocally(_lastController);
    });
  }

  Future<void> forceSave() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    await _saveDraftLocally(_lastController);
  }

  Future<void> _saveDraftLocally([QuillController? controller]) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(draftRepositoryProvider);

    List<dynamic>? deltaJson =
        controller?.document.toDelta().toJson() ?? state.contentDelta;
    deltaJson ??= [];

    String plainText = '';
    if (controller != null) {
      plainText = controller.document.toPlainText();
    } else {
      final buf = StringBuffer();
      for (final op in deltaJson) {
        if (op is Map && op['insert'] is String) {
          buf.write(op['insert']);
        }
      }
      plainText = buf.toString();
    }

    final excerptText = plainText.length > 100
        ? '${plainText.substring(0, 100)}...'
        : plainText;

    final contentMap = {
      'title': state.title,
      'excerpt': excerptText.trim(),
      'body': deltaJson,
      'cover_image_url': state.coverImageUrl,
      'post_type': state.postType,
      'caption': state.caption,
      'tags': state.tags,
      'scripture_refs':
          state.scriptureRefs.map((ref) => ref.toJson()).toList(),
      'publish_scripture_refs':
          state.publishScriptureRefs.take(3).map((ref) => ref.toJson()).toList(),
    };

    final jsonContent = jsonEncode(contentMap);

    String? sermonSourceJson;
    if (state.sermonSource != null) {
      sermonSourceJson = jsonEncode(state.sermonSource!.toJson());
    }

    // Extract inline scripture references and merge with top-level tags
    final inlineRefs =
        ScribesQuillScriptureHelper.extractScriptureRefs(deltaJson);
    final List<String> scriptureTags = state.scriptureRefs.map((r) {
      if (r.verseEnd != null && r.verseEnd != r.verseStart) {
        return '${r.book} ${r.chapter}:${r.verseStart}-${r.verseEnd}';
      }
      return '${r.book} ${r.chapter}:${r.verseStart}';
    }).toList();

    for (final inlineRef in inlineRefs) {
      if (!scriptureTags.contains(inlineRef)) {
        scriptureTags.add(inlineRef);
      }
    }

    await repo.saveDraftLocally(
      state.draftId,
      jsonContent,
      caption: state.caption.trim().isEmpty ? null : state.caption.trim(),
      sermonSource: sermonSourceJson,
      scriptureTags: scriptureTags,
    );

    ref.read(draftsListProvider.notifier).refresh();

    state = state.copyWith(
      isSaving: false,
      lastSavedAt: DateTime.now(),
      contentDelta: deltaJson,
    );
  }

  Future<void> publishToCloud() async {
    // 1. If cover image is a local file, upload it in background first
    if (state.coverImageUrl != null &&
        !state.coverImageUrl!.startsWith('http://') &&
        !state.coverImageUrl!.startsWith('https://')) {
      try {
        final filePath = state.coverImageUrl!.replaceFirst('file://', '');
        final file = File(filePath);
        if (file.existsSync()) {
          final mediaApi = ref.read(mediaApiProvider);
          String mimeType = 'image/jpeg';
          if (filePath.toLowerCase().endsWith('.png')) {
            mimeType = 'image/png';
          } else if (filePath.toLowerCase().endsWith('.webp')) {
            mimeType = 'image/webp';
          }
          final remoteUrl = await mediaApi.uploadImage(file, mimeType);
          state = state.copyWith(coverImageUrl: remoteUrl);
        }
      } catch (err) {
        debugPrint('[ComposeNotifier] Failed to upload local cover image: $err');
      }
    }

    await forceSave();
    final repo = ref.read(draftRepositoryProvider);
    final effectivePublishRefs = state.publishScriptureRefs.isNotEmpty
        ? state.publishScriptureRefs
        : state.scriptureRefs.take(3).toList();

    await repo.publishDraft(
      state.draftId,
      tags: state.tags,
      scriptureRefs: effectivePublishRefs.take(3).toList(),
    );

    ref.invalidate(feedProvider);
    ref.invalidate(followingFeedProvider);
    ref.read(draftsListProvider.notifier).refresh();
  }

  void clearCoverImage() {
    state = ComposeState(
      draftId: state.draftId,
      isSaving: state.isSaving,
      lastSavedAt: state.lastSavedAt,
      title: state.title,
      caption: state.caption,
      sermonSource: state.sermonSource,
      contentDelta: state.contentDelta,
      tags: state.tags,
      scriptureRefs: state.scriptureRefs,
      publishScriptureRefs: state.publishScriptureRefs,
      postType: state.postType,
      coverImageUrl: null,
    );
    _triggerAutosave();
  }

  void reset() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;
    state = ComposeState(draftId: const Uuid().v4());
  }

  void loadDraft(
    String draftId,
    Map<String, dynamic> content, {
    String? caption,
    SermonSource? sermonSource,
  }) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _lastController = null;

    final List<ScriptureRef> loadedRefs = [];
    if (content['scripture_refs'] is List) {
      for (final item in content['scripture_refs']) {
        if (item is Map) {
          try {
            loadedRefs.add(
              ScriptureRef.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {}
        }
      }
    }

    final List<ScriptureRef> loadedPublishRefs = [];
    if (content['publish_scripture_refs'] is List) {
      for (final item in content['publish_scripture_refs']) {
        if (item is Map) {
          try {
            loadedPublishRefs.add(
              ScriptureRef.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (_) {}
        }
      }
    }

    final bodyDelta = content['body'] != null
        ? List<dynamic>.from(content['body'])
        : null;

    // Auto-parse any inline scripture tags from editor level content
    if (bodyDelta != null) {
      final inlineRefs =
          ScribesQuillScriptureHelper.extractScriptureRefs(bodyDelta);
      for (final refStr in inlineRefs) {
        final parsed = ScriptureRef.tryParse(refStr);
        if (parsed != null &&
            !loadedRefs.any(
              (r) =>
                  r.book.toLowerCase() == parsed.book.toLowerCase() &&
                  r.chapter == parsed.chapter &&
                  r.verseStart == parsed.verseStart,
            )) {
          loadedRefs.add(parsed);
        }
      }
    }

    state = ComposeState(
      draftId: draftId,
      title: content['title'] ?? '',
      caption: caption ?? '',
      sermonSource: sermonSource,
      postType: (content['post_type'] ?? 'standard').toString(),
      coverImageUrl: content['cover_image_url'] as String?,
      tags: content['tags'] != null
          ? List<String>.from(content['tags'])
          : const [],
      scriptureRefs: loadedRefs,
      publishScriptureRefs: loadedPublishRefs.take(3).toList(),
      contentDelta: bodyDelta,
    );
  }
}
