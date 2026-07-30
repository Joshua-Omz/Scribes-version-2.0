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

@riverpod
class ConversationsNotifier extends _$ConversationsNotifier {
  Timer? _pollingTimer;
  int _lastTotalMessages = 0; // simplistic way to detect new messages across conversations

  @override
  Future<List<Conversation>> build() async {
    final repo = ref.watch(messageRepositoryProvider);
    
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    _startPolling();

    final convos = await repo.getConversations();
    _updateTotalMessages(convos);
    return convos;
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final repo = ref.read(messageRepositoryProvider);
        final convos = await repo.getConversations();
        
        // Detect if there are new unread messages
        int currentTotal = 0;
        bool hasNew = false;
        
        for (var c in convos) {
          currentTotal += c.lastActive.millisecondsSinceEpoch;
        }
        
        if (_lastTotalMessages != 0 && currentTotal != _lastTotalMessages) {
          hasNew = true;
        }
        
        _lastTotalMessages = currentTotal;

        if (hasNew) {
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
        
        state = AsyncData(convos);
      } catch (_) {}
    });
  }

  void _updateTotalMessages(List<Conversation> convos) {
    int currentTotal = 0;
    for (var c in convos) {
      currentTotal += c.lastActive.millisecondsSinceEpoch;
    }
    _lastTotalMessages = currentTotal;
  }

  Future<void> refresh() async {
    final repo = ref.read(messageRepositoryProvider);
    state = const AsyncLoading();
    final convos = await repo.getConversations();
    _updateTotalMessages(convos);
    state = AsyncData(convos);
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
