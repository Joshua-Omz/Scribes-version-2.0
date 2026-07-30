import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';

part 'conversation_providers.g.dart';

@riverpod
class ConversationMessages extends _$ConversationMessages {
  StreamSubscription<List<Message>>? _dbSub;
  StreamSubscription<Message>? _realtimeSub;

  @override
  Stream<List<Message>> build(String conversationId) {
    final repo = ref.watch(messageRepositoryProvider);
    
    // 1. Kick off a background refresh to fetch from API
    repo.refreshMessages(conversationId);

    // 2. Start the realtime SSE subscription to listen for new messages
    _realtimeSub = repo.streamRealtimeMessages(conversationId).listen(
      (msg) {
        // We don't need to manually update state here because the repo 
        // inserts it into Drift, and we are returning a Drift watch stream.
      },
      onError: (err) {
        // SSE error, might want to reconnect or handle gracefully
      }
    );

    ref.onDispose(() {
      _dbSub?.cancel();
      _realtimeSub?.cancel();
    });

    // 3. Return the stream that watches the local drift DB.
    // The UI will consume this stream via AsyncValue.
    return repo.watchMessages(conversationId);
  }

  Future<void> sendMessage(String body, {String? replyToId}) async {
    final repo = ref.read(messageRepositoryProvider);
    final user = ref.read(authProvider).value;
    if (user == null) return;
    await repo.sendMessage(conversationId, body, user.id, replyToId: replyToId);
  }
}
