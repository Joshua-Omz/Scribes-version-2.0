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

@ProviderFor(ExploreSearchQuery)
final exploreSearchQueryProvider = ExploreSearchQueryProvider._();

final class ExploreSearchQueryProvider
    extends $NotifierProvider<ExploreSearchQuery, String?> {
  ExploreSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSearchQueryHash();

  @$internal
  @override
  ExploreSearchQuery create() => ExploreSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$exploreSearchQueryHash() =>
    r'd0d7eb45eb5816588190278fa35d74524381fba8';

abstract class _$ExploreSearchQuery extends $Notifier<String?> {
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

@ProviderFor(ExploreSearchActive)
final exploreSearchActiveProvider = ExploreSearchActiveProvider._();

final class ExploreSearchActiveProvider
    extends $NotifierProvider<ExploreSearchActive, bool> {
  ExploreSearchActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSearchActiveProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSearchActiveHash();

  @$internal
  @override
  ExploreSearchActive create() => ExploreSearchActive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$exploreSearchActiveHash() =>
    r'ca8057e9e6fc5786e66ca5093f1fff66735814ed';

abstract class _$ExploreSearchActive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreSearchModeNotifier)
final exploreSearchModeProvider = ExploreSearchModeNotifierProvider._();

final class ExploreSearchModeNotifierProvider
    extends $NotifierProvider<ExploreSearchModeNotifier, ExploreSearchMode> {
  ExploreSearchModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSearchModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSearchModeNotifierHash();

  @$internal
  @override
  ExploreSearchModeNotifier create() => ExploreSearchModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreSearchMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreSearchMode>(value),
    );
  }
}

String _$exploreSearchModeNotifierHash() =>
    r'f2a5aebf7016dd5836041f7bcb8af2506a961c4e';

abstract class _$ExploreSearchModeNotifier
    extends $Notifier<ExploreSearchMode> {
  ExploreSearchMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ExploreSearchMode, ExploreSearchMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExploreSearchMode, ExploreSearchMode>,
              ExploreSearchMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(exploreUserSearch)
final exploreUserSearchProvider = ExploreUserSearchProvider._();

final class ExploreUserSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CommentAuthor>>,
          List<CommentAuthor>,
          FutureOr<List<CommentAuthor>>
        >
    with
        $FutureModifier<List<CommentAuthor>>,
        $FutureProvider<List<CommentAuthor>> {
  ExploreUserSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreUserSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreUserSearchHash();

  @$internal
  @override
  $FutureProviderElement<List<CommentAuthor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CommentAuthor>> create(Ref ref) {
    return exploreUserSearch(ref);
  }
}

String _$exploreUserSearchHash() => r'4ac5badfe83836f9af0df1341fa387dc64d19f81';

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

@ProviderFor(ExplorePostsNotifier)
final explorePostsProvider = ExplorePostsNotifierProvider._();

final class ExplorePostsNotifierProvider
    extends $AsyncNotifierProvider<ExplorePostsNotifier, List<Post>> {
  ExplorePostsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'explorePostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$explorePostsNotifierHash();

  @$internal
  @override
  ExplorePostsNotifier create() => ExplorePostsNotifier();
}

String _$explorePostsNotifierHash() =>
    r'c0bc902079850ab6c3e9374bb5bbee65c655466d';

abstract class _$ExplorePostsNotifier extends $AsyncNotifier<List<Post>> {
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
