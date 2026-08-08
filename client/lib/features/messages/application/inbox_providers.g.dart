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
    extends $StreamNotifierProvider<ConversationsNotifier, List<Conversation>> {
  ConversationsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conversationsProvider',
        isAutoDispose: false,
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
    r'd4b4c4259c621ecba5ceeed0d850992a291453f2';

abstract class _$ConversationsNotifier
    extends $StreamNotifier<List<Conversation>> {
  Stream<List<Conversation>> build();
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
    r'6d8358836e35a04b8fce622cf370b3254aad62ff';

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
