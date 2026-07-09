import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';

import '../../draft/data/draft_repository.dart';

final composeProvider = NotifierProvider<ComposeNotifier, ComposeState>(ComposeNotifier.new);

class ComposeState {
  final String draftId;
  final bool isSaving;
  final DateTime? lastSavedAt;

  ComposeState({
    required this.draftId,
    this.isSaving = false,
    this.lastSavedAt,
  });

  ComposeState copyWith({
    String? draftId,
    bool? isSaving,
    DateTime? lastSavedAt,
  }) {
    return ComposeState(
      draftId: draftId ?? this.draftId,
      isSaving: isSaving ?? this.isSaving,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }
}

class ComposeNotifier extends Notifier<ComposeState> {
  Timer? _debounce;

  @override
  ComposeState build() {
    return ComposeState(draftId: const Uuid().v4());
  }

  void onDocumentChanged(QuillController controller) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _saveDraftLocally(controller);
    });
  }

  Future<void> _saveDraftLocally(QuillController controller) async {
    state = state.copyWith(isSaving: true);

    final repo = ref.read(draftRepositoryProvider);
    final jsonContent = jsonEncode(controller.document.toDelta().toJson());
    
    // We can extract a caption from plain text
    final plainText = controller.document.toPlainText();
    final caption = plainText.length > 50 ? '${plainText.substring(0, 50)}...' : plainText;

    await repo.saveDraftLocally(
      state.draftId,
      jsonContent,
      caption: caption.trim().isEmpty ? null : caption.trim(),
    );

    state = state.copyWith(isSaving: false, lastSavedAt: DateTime.now());
  }

  Future<void> publishToCloud() async {
    final repo = ref.read(draftRepositoryProvider);
    await repo.pushToCloud(state.draftId);
  }
}
