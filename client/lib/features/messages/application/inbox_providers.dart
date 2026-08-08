import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/messages/domain/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scribes/features/messages/application/last_read_provider.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';

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

  @override
  Stream<List<Conversation>> build() async* {
    final repo = ref.watch(messageRepositoryProvider);
    
    ref.onDispose(() {
      _isDisposed = true;
      _pollingTimer?.cancel();
    });

    // Start background sync polling
    _startPolling();

    final user = ref.read(authProvider).value;
    if (user == null) return;

    // Trigger initial background refresh immediately
    repo.refreshConversations();

    // Yield the local DB stream for instant cached UI
    await for (final convos in repo.watchConversations(user.id)) {
      _checkNewMessages(convos);
      // Eagerly load the last read states so the global unread badge doesn't assume all are unread.
      ref.read(lastReadProvider.notifier).loadAll(convos.map((c) => c.id).toList());
      yield convos;
    }
  }

  void _checkNewMessages(List<Conversation> convos) {
    // Relying on global SSE notification for banners instead of naive checks.
  }

  bool _isDisposed = false;
  int _currentBackoff = 0;
  final int _maxBackoff = 300; // 5 mins max

  void _startPolling() {
    _isDisposed = false;
    _scheduleNextPoll();
  }

  void _scheduleNextPoll() {
    if (_isDisposed) return;
    
    int baseInterval = 10;
    try {
      final envVal = dotenv.env['INBOX_REFRESH_INTERVAL_SEC'];
      if (envVal != null) {
        baseInterval = int.parse(envVal);
      }
    } catch (_) {}
    
    final int secondsToWait = baseInterval + _currentBackoff;
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer(Duration(seconds: secondsToWait), _poll);
  }

  Future<void> _poll() async {
    if (_isDisposed) return;
    
    try {
      final repo = ref.read(messageRepositoryProvider);
      await repo.refreshConversations();
      _currentBackoff = 0; // Success: reset backoff
    } catch (e) {
      if (_currentBackoff == 0) {
        _currentBackoff = 15;
      } else {
        _currentBackoff = (_currentBackoff * 2).clamp(0, _maxBackoff);
      }
    }
    
    _scheduleNextPoll();
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
    int count = 0;
    
    // Count pending requests
    final pending = ref.watch(pendingRequestsProvider);
    count += pending.when(
      data: (reqs) => reqs.length,
      loading: () => 0,
      error: (err, stack) => 0,
    );

    // Count unread conversations
    final convosAsync = ref.watch(conversationsProvider);
    final lastReadMap = ref.watch(lastReadProvider);
    
    if (convosAsync is AsyncData) {
      final convos = convosAsync.value ?? [];
      for (final c in convos) {
        final lastRead = lastReadMap[c.id];
        // If never read, or lastActive is newer than lastRead
        if (lastRead == null || c.lastActive.isAfter(lastRead)) {
          count++;
        }
      }
    }
    
    return count;
  }
}
