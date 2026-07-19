import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/note.dart';
import '../data/note_repository.dart';

final notesListProvider = AsyncNotifierProvider<NotesListNotifier, List<Note>>(() {
  return NotesListNotifier();
});

class NotesListNotifier extends AsyncNotifier<List<Note>> {
  String? _currentNotebookId;

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
  }

  Future<void> deleteNote(String id) async {
    final repo = ref.read(noteRepositoryProvider);
    await repo.deleteNoteLocally(id);
    refresh();
  }
}
