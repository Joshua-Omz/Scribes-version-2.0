import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/draft_repository.dart';
import '../domain/draft.dart';

final draftsListProvider = AsyncNotifierProvider<DraftsListNotifier, List<Draft>>(() {
  return DraftsListNotifier();
});

class DraftsListNotifier extends AsyncNotifier<List<Draft>> {
  @override
  FutureOr<List<Draft>> build() async {
    return _fetchDrafts();
  }

  Future<List<Draft>> _fetchDrafts() async {
    final repo = ref.read(draftRepositoryProvider);
    return await repo.getAllLocalDrafts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDrafts());
  }

  Future<void> deleteDraft(String id) async {
    final repo = ref.read(draftRepositoryProvider);
    await repo.deleteDraftLocally(id);
    await refresh();
  }
}
