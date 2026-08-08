// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaApi)
final mediaApiProvider = MediaApiProvider._();

final class MediaApiProvider
    extends $FunctionalProvider<MediaApi, MediaApi, MediaApi>
    with $Provider<MediaApi> {
  MediaApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaApiHash();

  @$internal
  @override
  $ProviderElement<MediaApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaApi create(Ref ref) {
    return mediaApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaApi>(value),
    );
  }
}

String _$mediaApiHash() => r'2177d808e2732e8f3cd2a7f6ee96d52053c40aa3';
