// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConversationMessages)
final conversationMessagesProvider = ConversationMessagesFamily._();

final class ConversationMessagesProvider
    extends $StreamNotifierProvider<ConversationMessages, List<Message>> {
  ConversationMessagesProvider._({
    required ConversationMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'conversationMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$conversationMessagesHash();

  @override
  String toString() {
    return r'conversationMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ConversationMessages create() => ConversationMessages();

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$conversationMessagesHash() =>
    r'cdaf0b35252e19ca6b427722a508247bf5df2db8';

final class ConversationMessagesFamily extends $Family
    with
        $ClassFamilyOverride<
          ConversationMessages,
          AsyncValue<List<Message>>,
          List<Message>,
          Stream<List<Message>>,
          String
        > {
  ConversationMessagesFamily._()
    : super(
        retry: null,
        name: r'conversationMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ConversationMessagesProvider call(String conversationId) =>
      ConversationMessagesProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'conversationMessagesProvider';
}

abstract class _$ConversationMessages extends $StreamNotifier<List<Message>> {
  late final _$args = ref.$arg as String;
  String get conversationId => _$args;

  Stream<List<Message>> build(String conversationId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Message>>, List<Message>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Message>>, List<Message>>,
              AsyncValue<List<Message>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
