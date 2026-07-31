import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/widgets/scribes_toast.dart';

part 'inbox_providers.g.dart';

@riverpod
class PendingRequests extends _$PendingRequests {
  @override
  Future<List<MessageRequest>> build() async {
    final repo = ref.watch(messageRepositoryProvider);
    return repo.getPendingRequests();
  }

  Future<void> approveRequest(String requestId) async {
    final repo = ref.read(messageRepositoryProvider);
    await repo.approveRequest(requestId);
    ref.invalidateSelf();
    ref.invalidate(conversationsProvider); // Refresh conversations to show the newly approved one
  }

  Future<void> rejectRequest(String requestId) async {
    final repo = ref.read(messageRepositoryProvider);
    await repo.rejectRequest(requestId);
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class ConversationsNotifier extends _$ConversationsNotifier {
  Timer? _pollingTimer;
  int _lastTotalMessages = 0; // simplistic way to detect new messages across conversations

  @override
  Stream<List<Conversation>> build() async* {
    final repo = ref.watch(messageRepositoryProvider);
    
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    // Start background sync polling
    _startPolling();

    // Trigger initial background refresh immediately
    repo.refreshConversations();

    // Yield the local DB stream for instant cached UI
    await for (final convos in repo.watchConversations()) {
      _checkNewMessages(convos);
      yield convos;
    }
  }

  void _checkNewMessages(List<Conversation> convos) {
    int currentTotal = 0;
    for (var c in convos) {
      currentTotal += c.lastActive.millisecondsSinceEpoch;
    }
    
    if (_lastTotalMessages != 0 && currentTotal > _lastTotalMessages) {
      try {
        final themeColors = ref.read(themeProvider);
        ScribesToast.show(
          null, // uses global key
          'New message received',
          themeColors,
          icon: HugeIcons.strokeRoundedMail01,
        );
      } catch (_) {}
    }
    _lastTotalMessages = currentTotal;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final repo = ref.read(messageRepositoryProvider);
      repo.refreshConversations(); // Automatically updates DB, which updates the Stream
    });
  }

  Future<void> hideConversations(List<String> ids) async {
    final repo = ref.read(messageRepositoryProvider);
    await repo.hideConversations(ids);
  }

  Future<void> refresh() async {
    final repo = ref.read(messageRepositoryProvider);
    await repo.refreshConversations();
  }
}

@riverpod
class UnreadMessagesCount extends _$UnreadMessagesCount {
  @override
  int build() {
    // In a real app, this would be computed by comparing the conversation's last_active
    // timestamp against a local last_read timestamp. For V1 we just return a static
    // or computed value. E.g. check pending requests length as well.
    final pending = ref.watch(pendingRequestsProvider);
    return pending.when(
      data: (reqs) => reqs.length,
      loading: () => 0,
      error: (err, stack) => 0,
    );
  }
}
