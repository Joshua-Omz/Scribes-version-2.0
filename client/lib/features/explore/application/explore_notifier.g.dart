// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExploreSelectedTag)
final exploreSelectedTagProvider = ExploreSelectedTagProvider._();

final class ExploreSelectedTagProvider
    extends $NotifierProvider<ExploreSelectedTag, String?> {
  ExploreSelectedTagProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSelectedTagProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSelectedTagHash();

  @$internal
  @override
  ExploreSelectedTag create() => ExploreSelectedTag();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$exploreSelectedTagHash() =>
    r'07e8e4bbf2cb59b0e0d1d1e20408958eda54be4b';

abstract class _$ExploreSelectedTag extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreScriptureFilter)
final exploreScriptureFilterProvider = ExploreScriptureFilterProvider._();

final class ExploreScriptureFilterProvider
    extends $NotifierProvider<ExploreScriptureFilter, ScriptureFilter?> {
  ExploreScriptureFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreScriptureFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreScriptureFilterHash();

  @$internal
  @override
  ExploreScriptureFilter create() => ExploreScriptureFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScriptureFilter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScriptureFilter?>(value),
    );
  }
}

String _$exploreScriptureFilterHash() =>
    r'4e12eb415793cf1eba629c91babf5343a23dd62f';

abstract class _$ExploreScriptureFilter extends $Notifier<ScriptureFilter?> {
  ScriptureFilter? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ScriptureFilter?, ScriptureFilter?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScriptureFilter?, ScriptureFilter?>,
              ScriptureFilter?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreTrendingNotifier)
final exploreTrendingProvider = ExploreTrendingNotifierProvider._();

final class ExploreTrendingNotifierProvider
    extends $AsyncNotifierProvider<ExploreTrendingNotifier, List<Post>> {
  ExploreTrendingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreTrendingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreTrendingNotifierHash();

  @$internal
  @override
  ExploreTrendingNotifier create() => ExploreTrendingNotifier();
}

String _$exploreTrendingNotifierHash() =>
    r'b11cafea3fdd8728f57c47bfd5c88adcd5c282e0';

abstract class _$ExploreTrendingNotifier extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(exploreInsightful)
final exploreInsightfulProvider = ExploreInsightfulProvider._();

final class ExploreInsightfulProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  ExploreInsightfulProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreInsightfulProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreInsightfulHash();

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    return exploreInsightful(ref);
  }
}

String _$exploreInsightfulHash() => r'2e588d119c5e4aa282c8571a183ba1e7459aaf83';

@ProviderFor(exploreProphetic)
final explorePropheticProvider = ExplorePropheticProvider._();

final class ExplorePropheticProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  ExplorePropheticProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorePropheticProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorePropheticHash();

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    return exploreProphetic(ref);
  }
}

String _$explorePropheticHash() => r'feefe4a90744192d589529bf0c6381c214757168';

@ProviderFor(exploreAffirmed)
final exploreAffirmedProvider = ExploreAffirmedProvider._();

final class ExploreAffirmedProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  ExploreAffirmedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreAffirmedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreAffirmedHash();

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    return exploreAffirmed(ref);
  }
}

String _$exploreAffirmedHash() => r'e1493d3b3a94445e3cb98c8cbc0f6a89f0818506';

@ProviderFor(ExploreForYouNotifier)
final exploreForYouProvider = ExploreForYouNotifierProvider._();

final class ExploreForYouNotifierProvider
    extends $AsyncNotifierProvider<ExploreForYouNotifier, List<Post>> {
  ExploreForYouNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreForYouProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreForYouNotifierHash();

  @$internal
  @override
  ExploreForYouNotifier create() => ExploreForYouNotifier();
}

String _$exploreForYouNotifierHash() =>
    r'6ecc3deb61f991435b8a9bb49d28720c899868f1';

abstract class _$ExploreForYouNotifier extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreChurchesNotifier)
final exploreChurchesProvider = ExploreChurchesNotifierProvider._();

final class ExploreChurchesNotifierProvider
    extends $AsyncNotifierProvider<ExploreChurchesNotifier, List<Post>> {
  ExploreChurchesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreChurchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreChurchesNotifierHash();

  @$internal
  @override
  ExploreChurchesNotifier create() => ExploreChurchesNotifier();
}

String _$exploreChurchesNotifierHash() =>
    r'2e562f25a0edc0830fa3aed244ebeb938e58dd58';

abstract class _$ExploreChurchesNotifier extends $AsyncNotifier<List<Post>> {
  FutureOr<List<Post>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Post>>, List<Post>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Post>>, List<Post>>,
              AsyncValue<List<Post>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(exploreSuggestedUsers)
final exploreSuggestedUsersProvider = ExploreSuggestedUsersProvider._();

final class ExploreSuggestedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<User>>,
          List<User>,
          FutureOr<List<User>>
        >
    with $FutureModifier<List<User>>, $FutureProvider<List<User>> {
  ExploreSuggestedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSuggestedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSuggestedUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<User>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<User>> create(Ref ref) {
    return exploreSuggestedUsers(ref);
  }
}

String _$exploreSuggestedUsersHash() =>
    r'c769f29d15fee52176545c9f24f554f5de24b874';
