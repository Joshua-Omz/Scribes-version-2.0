// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_read_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LastReadNotifier)
final lastReadProvider = LastReadNotifierProvider._();

final class LastReadNotifierProvider
    extends $NotifierProvider<LastReadNotifier, Map<String, DateTime>> {
  LastReadNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastReadProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastReadNotifierHash();

  @$internal
  @override
  LastReadNotifier create() => LastReadNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, DateTime>>(value),
    );
  }
}

String _$lastReadNotifierHash() => r'b743023da2c023d10cb73b1ef98c15f621b2f714';

abstract class _$LastReadNotifier extends $Notifier<Map<String, DateTime>> {
  Map<String, DateTime> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, DateTime>, Map<String, DateTime>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, DateTime>, Map<String, DateTime>>,
              Map<String, DateTime>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
