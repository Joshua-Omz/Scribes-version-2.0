import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/storage/secure_storage.dart';

part 'last_read_provider.g.dart';

@Riverpod(keepAlive: true)
class LastReadNotifier extends _$LastReadNotifier {
  @override
  Map<String, DateTime> build() {
    // We start empty, and lazily load
    return {};
  }

  Future<void> loadForConversation(String conversationId) async {
    final storage = ref.read(secureStorageProvider);
    final value = await storage.getLastRead(conversationId);
    if (!ref.mounted) return;
    if (value != null) {
      state = {...state, conversationId: DateTime.parse(value)};
    }
  }

  Future<void> loadAll(List<String> conversationIds) async {
    final storage = ref.read(secureStorageProvider);
    final updates = <String, DateTime>{};
    for (final id in conversationIds) {
      if (state.containsKey(id)) continue;
      final value = await storage.getLastRead(id);
      if (!ref.mounted) return;
      if (value != null) {
        updates[id] = DateTime.parse(value);
      }
    }
    if (!ref.mounted) return;
    if (updates.isNotEmpty) {
      state = {...state, ...updates};
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final now = DateTime.now();
    final storage = ref.read(secureStorageProvider);
    await storage.saveLastRead(conversationId, now.toIso8601String());
    if (!ref.mounted) return;

    state = {...state, conversationId: now};
  }
}
