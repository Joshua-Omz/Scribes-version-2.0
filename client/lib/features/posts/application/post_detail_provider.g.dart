// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostDetailNotifier)
final postDetailProvider = PostDetailNotifierFamily._();

final class PostDetailNotifierProvider
    extends $AsyncNotifierProvider<PostDetailNotifier, PostDetailState> {
  PostDetailNotifierProvider._({
    required PostDetailNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postDetailNotifierHash();

  @override
  String toString() {
    return r'postDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostDetailNotifier create() => PostDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is PostDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postDetailNotifierHash() =>
    r'3f28cd87ef0aae5608f25d595ae00417e87fd3b9';

final class PostDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PostDetailNotifier,
          AsyncValue<PostDetailState>,
          PostDetailState,
          FutureOr<PostDetailState>,
          String
        > {
  PostDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'postDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostDetailNotifierProvider call(String postId) =>
      PostDetailNotifierProvider._(argument: postId, from: this);

  @override
  String toString() => r'postDetailProvider';
}

abstract class _$PostDetailNotifier extends $AsyncNotifier<PostDetailState> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<PostDetailState> build(String postId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PostDetailState>, PostDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PostDetailState>, PostDetailState>,
              AsyncValue<PostDetailState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(similarPosts)
final similarPostsProvider = SimilarPostsFamily._();

final class SimilarPostsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Post>>,
          List<Post>,
          FutureOr<List<Post>>
        >
    with $FutureModifier<List<Post>>, $FutureProvider<List<Post>> {
  SimilarPostsProvider._({
    required SimilarPostsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'similarPostsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$similarPostsHash();

  @override
  String toString() {
    return r'similarPostsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Post>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Post>> create(Ref ref) {
    final argument = this.argument as String;
    return similarPosts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SimilarPostsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$similarPostsHash() => r'f89bc14f9258c7e769f18fa3e5817027f15b8b5d';

final class SimilarPostsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Post>>, String> {
  SimilarPostsFamily._()
    : super(
        retry: null,
        name: r'similarPostsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SimilarPostsProvider call(String postId) =>
      SimilarPostsProvider._(argument: postId, from: this);

  @override
  String toString() => r'similarPostsProvider';
}
