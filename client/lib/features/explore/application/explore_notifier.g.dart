// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoriesNotifier)
final categoriesProvider = CategoriesNotifierProvider._();

final class CategoriesNotifierProvider
    extends $AsyncNotifierProvider<CategoriesNotifier, List<PostCategory>> {
  CategoriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesNotifierHash();

  @$internal
  @override
  CategoriesNotifier create() => CategoriesNotifier();
}

String _$categoriesNotifierHash() =>
    r'9912fc2a467c67370126609da04acafb2c97fe02';

abstract class _$CategoriesNotifier extends $AsyncNotifier<List<PostCategory>> {
  FutureOr<List<PostCategory>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PostCategory>>, List<PostCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<PostCategory>>, List<PostCategory>>,
              AsyncValue<List<PostCategory>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreSelectedCategory)
final exploreSelectedCategoryProvider = ExploreSelectedCategoryProvider._();

final class ExploreSelectedCategoryProvider
    extends $NotifierProvider<ExploreSelectedCategory, String?> {
  ExploreSelectedCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSelectedCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSelectedCategoryHash();

  @$internal
  @override
  ExploreSelectedCategory create() => ExploreSelectedCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$exploreSelectedCategoryHash() =>
    r'336ee1daed3470c394af30770d8c4f4d9be76627';

abstract class _$ExploreSelectedCategory extends $Notifier<String?> {
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
    r'a2f2280c3686417929adcd6cafb114da8db541a0';

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
