// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soundApi)
final soundApiProvider = SoundApiProvider._();

final class SoundApiProvider
    extends $FunctionalProvider<SoundApi, SoundApi, SoundApi>
    with $Provider<SoundApi> {
  SoundApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundApiHash();

  @$internal
  @override
  $ProviderElement<SoundApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoundApi create(Ref ref) {
    return soundApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundApi>(value),
    );
  }
}

String _$soundApiHash() => r'59ba87bcc3cc3cf0c8622a8e8e4d475b7aba37b2';
