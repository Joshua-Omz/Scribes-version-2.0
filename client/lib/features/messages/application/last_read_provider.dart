import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/secure_storage.dart';

part 'last_read_provider.g.dart';

@riverpod
class LastReadNotifier extends _$LastReadNotifier {
  @override
  Map<String, DateTime> build() {
    // We start empty, and lazily load
    return {};
  }

  Future<void> loadForConversation(String conversationId) async {
    final storage = ref.read(secureStorageProvider);
    final value = await storage.getLastRead(conversationId);
    if (value != null) {
      state = {
        ...state,
        conversationId: DateTime.parse(value),
      };
    }
  }

  Future<void> loadAll(List<String> conversationIds) async {
    final storage = ref.read(secureStorageProvider);
    final updates = <String, DateTime>{};
    for (final id in conversationIds) {
      if (state.containsKey(id)) continue;
      final value = await storage.getLastRead(id);
      if (value != null) {
        updates[id] = DateTime.parse(value);
      }
    }
    if (updates.isNotEmpty) {
      state = {
        ...state,
        ...updates,
      };
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final now = DateTime.now();
    final storage = ref.read(secureStorageProvider);
    await storage.saveLastRead(conversationId, now.toIso8601String());
    
    state = {
      ...state,
      conversationId: now,
    };
  }
}
