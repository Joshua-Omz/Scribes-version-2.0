// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_social_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PostReactionsNotifier)
final postReactionsProvider = PostReactionsNotifierFamily._();

final class PostReactionsNotifierProvider
    extends $AsyncNotifierProvider<PostReactionsNotifier, List<ReactionCount>> {
  PostReactionsNotifierProvider._({
    required PostReactionsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postReactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postReactionsNotifierHash();

  @override
  String toString() {
    return r'postReactionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostReactionsNotifier create() => PostReactionsNotifier();

  @override
  bool operator ==(Object other) {
    return other is PostReactionsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postReactionsNotifierHash() =>
    r'98d556916115b6419891f9f6f49d788dc197d0b3';

final class PostReactionsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PostReactionsNotifier,
          AsyncValue<List<ReactionCount>>,
          List<ReactionCount>,
          FutureOr<List<ReactionCount>>,
          String
        > {
  PostReactionsNotifierFamily._()
    : super(
        retry: null,
        name: r'postReactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostReactionsNotifierProvider call(String postId) =>
      PostReactionsNotifierProvider._(argument: postId, from: this);

  @override
  String toString() => r'postReactionsProvider';
}

abstract class _$PostReactionsNotifier
    extends $AsyncNotifier<List<ReactionCount>> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<List<ReactionCount>> build(String postId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ReactionCount>>, List<ReactionCount>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ReactionCount>>, List<ReactionCount>>,
              AsyncValue<List<ReactionCount>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(PostCommentsNotifier)
final postCommentsProvider = PostCommentsNotifierFamily._();

final class PostCommentsNotifierProvider
    extends $AsyncNotifierProvider<PostCommentsNotifier, List<Comment>> {
  PostCommentsNotifierProvider._({
    required PostCommentsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'postCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$postCommentsNotifierHash();

  @override
  String toString() {
    return r'postCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PostCommentsNotifier create() => PostCommentsNotifier();

  @override
  bool operator ==(Object other) {
    return other is PostCommentsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$postCommentsNotifierHash() =>
    r'09370d63eee783e09fb6c1803bd4f2985bd3ef19';

final class PostCommentsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          PostCommentsNotifier,
          AsyncValue<List<Comment>>,
          List<Comment>,
          FutureOr<List<Comment>>,
          String
        > {
  PostCommentsNotifierFamily._()
    : super(
        retry: null,
        name: r'postCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PostCommentsNotifierProvider call(String postId) =>
      PostCommentsNotifierProvider._(argument: postId, from: this);

  @override
  String toString() => r'postCommentsProvider';
}

abstract class _$PostCommentsNotifier extends $AsyncNotifier<List<Comment>> {
  late final _$args = ref.$arg as String;
  String get postId => _$args;

  FutureOr<List<Comment>> build(String postId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Comment>>, List<Comment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Comment>>, List<Comment>>,
              AsyncValue<List<Comment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
