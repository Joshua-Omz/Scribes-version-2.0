// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, ScribesColors> {
  ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScribesColors value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScribesColors>(value),
    );
  }
}

String _$themeNotifierHash() => r'429191bb6ddf394b91ddfdb4e70250de151a4f01';

abstract class _$ThemeNotifier extends $Notifier<ScribesColors> {
  ScribesColors build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScribesColors, ScribesColors>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScribesColors, ScribesColors>,
              ScribesColors,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
