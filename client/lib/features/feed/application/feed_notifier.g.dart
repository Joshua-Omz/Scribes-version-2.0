// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedNotifier)
final feedProvider = FeedNotifierProvider._();

final class FeedNotifierProvider
    extends $AsyncNotifierProvider<FeedNotifier, FeedState> {
  FeedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedNotifierHash();

  @$internal
  @override
  FeedNotifier create() => FeedNotifier();
}

String _$feedNotifierHash() => r'89dfc5cb81625c6876512184f17c9ea6e4193078';

abstract class _$FeedNotifier extends $AsyncNotifier<FeedState> {
  FutureOr<FeedState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedState>, FeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedState>, FeedState>,
              AsyncValue<FeedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FollowingFeedNotifier)
final followingFeedProvider = FollowingFeedNotifierProvider._();

final class FollowingFeedNotifierProvider
    extends $AsyncNotifierProvider<FollowingFeedNotifier, FeedState> {
  FollowingFeedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingFeedNotifierHash();

  @$internal
  @override
  FollowingFeedNotifier create() => FollowingFeedNotifier();
}

String _$followingFeedNotifierHash() =>
    r'bc3bb3d44c0c985b4b94fdf119415c6e78aa51e4';

abstract class _$FollowingFeedNotifier extends $AsyncNotifier<FeedState> {
  FutureOr<FeedState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FeedState>, FeedState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FeedState>, FeedState>,
              AsyncValue<FeedState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
