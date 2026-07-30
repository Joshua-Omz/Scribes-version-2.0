// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PendingRequests)
final pendingRequestsProvider = PendingRequestsProvider._();

final class PendingRequestsProvider
    extends $AsyncNotifierProvider<PendingRequests, List<MessageRequest>> {
  PendingRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRequestsHash();

  @$internal
  @override
  PendingRequests create() => PendingRequests();
}

String _$pendingRequestsHash() => r'efff9cb85e16da83295ae671a6a97eb746c928be';

abstract class _$PendingRequests extends $AsyncNotifier<List<MessageRequest>> {
  FutureOr<List<MessageRequest>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MessageRequest>>, List<MessageRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MessageRequest>>,
                List<MessageRequest>
              >,
              AsyncValue<List<MessageRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ConversationsNotifier)
final conversationsProvider = ConversationsNotifierProvider._();

final class ConversationsNotifierProvider
    extends $AsyncNotifierProvider<ConversationsNotifier, List<Conversation>> {
  ConversationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conversationsNotifierHash();

  @$internal
  @override
  ConversationsNotifier create() => ConversationsNotifier();
}

String _$conversationsNotifierHash() =>
    r'd5111dcac855edff01835e509dfb966ec2a82e81';

abstract class _$ConversationsNotifier
    extends $AsyncNotifier<List<Conversation>> {
  FutureOr<List<Conversation>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Conversation>>, List<Conversation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Conversation>>, List<Conversation>>,
              AsyncValue<List<Conversation>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(UnreadMessagesCount)
final unreadMessagesCountProvider = UnreadMessagesCountProvider._();

final class UnreadMessagesCountProvider
    extends $NotifierProvider<UnreadMessagesCount, int> {
  UnreadMessagesCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadMessagesCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadMessagesCountHash();

  @$internal
  @override
  UnreadMessagesCount create() => UnreadMessagesCount();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$unreadMessagesCountHash() =>
    r'a5ee89c1a59d943214156d7c84bd4c52b2284c6c';

abstract class _$UnreadMessagesCount extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
