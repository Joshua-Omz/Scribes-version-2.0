// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sound_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(soundRepository)
final soundRepositoryProvider = SoundRepositoryProvider._();

final class SoundRepositoryProvider
    extends
        $FunctionalProvider<SoundRepository, SoundRepository, SoundRepository>
    with $Provider<SoundRepository> {
  SoundRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundRepositoryHash();

  @$internal
  @override
  $ProviderElement<SoundRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SoundRepository create(Ref ref) {
    return soundRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SoundRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SoundRepository>(value),
    );
  }
}

String _$soundRepositoryHash() => r'd9e481d01b5edb0c9e0e0e236fdbbc42ad06fc6b';

@ProviderFor(soundsList)
final soundsListProvider = SoundsListProvider._();

final class SoundsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SoundTrack>>,
          List<SoundTrack>,
          FutureOr<List<SoundTrack>>
        >
    with $FutureModifier<List<SoundTrack>>, $FutureProvider<List<SoundTrack>> {
  SoundsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'soundsListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$soundsListHash();

  @$internal
  @override
  $FutureProviderElement<List<SoundTrack>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SoundTrack>> create(Ref ref) {
    return soundsList(ref);
  }
}

String _$soundsListHash() => r'f162359ec2697400dede64ff774631bd01f2fff3';
