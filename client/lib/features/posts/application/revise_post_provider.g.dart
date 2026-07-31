// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revise_post_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RevisePostNotifier)
final revisePostProvider = RevisePostNotifierProvider._();

final class RevisePostNotifierProvider
    extends $NotifierProvider<RevisePostNotifier, AsyncValue<void>> {
  RevisePostNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revisePostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revisePostNotifierHash();

  @$internal
  @override
  RevisePostNotifier create() => RevisePostNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$revisePostNotifierHash() =>
    r'cdbbacebfc97df9ab26bf7d671c67c3366fde47d';

abstract class _$RevisePostNotifier extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
