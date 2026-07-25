import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../data/note_repository.dart';
import '../../auth/application/auth_notifier.dart';
import '../../sync/application/sync_service.dart';

final notesListProvider = AsyncNotifierProvider<NotesListNotifier, List<Note>>(() {
  return NotesListNotifier();
});

class NotesListNotifier extends AsyncNotifier<List<Note>> {
  String? _currentNotebookId;
  bool _isSyncInFlight = false;

  @override
  FutureOr<List<Note>> build() async {
    return _fetchNotes();
  }

  void setNotebookFilter(String? notebookId) {
    _currentNotebookId = notebookId;
    refresh();
  }

  Future<List<Note>> _fetchNotes() async {
    final repo = ref.watch(noteRepositoryProvider);
    
    // In background, sync from API could be triggered here
    // For now we prioritize fast local read
    return repo.getAllLocalNotes(notebookId: _currentNotebookId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotes());
    unawaited(_syncThenRefresh());
  }

  Future<void> deleteNote(String id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNoteLocally(id);
    refresh();
  }

  Future<void> _syncThenRefresh() async {
    if (_isSyncInFlight) return;
    _isSyncInFlight = true;
    try {
      final userId = ref.read(authProvider).value?.id;
      final syncService = ref.read(syncServiceProvider);
      await syncService.sync(authorId: userId);
      state = await AsyncValue.guard(() => _fetchNotes());
    } finally {
      _isSyncInFlight = false;
    }
  }
}
