import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scribes/features/messages/data/message_repository.dart';
import 'package:scribes/features/messages/domain/message.dart';

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
  @override
  Future<List<Conversation>> build() async {
    final repo = ref.watch(messageRepositoryProvider);
    return repo.getConversations();
  }

  Future<void> refresh() async {
    final repo = ref.read(messageRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.getConversations());
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
