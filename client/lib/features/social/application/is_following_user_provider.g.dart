// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'is_following_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsFollowingUser)
final isFollowingUserProvider = IsFollowingUserFamily._();

final class IsFollowingUserProvider
    extends $AsyncNotifierProvider<IsFollowingUser, bool> {
  IsFollowingUserProvider._({
    required IsFollowingUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFollowingUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFollowingUserHash();

  @override
  String toString() {
    return r'isFollowingUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  IsFollowingUser create() => IsFollowingUser();

  @override
  bool operator ==(Object other) {
    return other is IsFollowingUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFollowingUserHash() => r'7d24eed07ec3d1b6f91d7494a56e7758ea20c31b';

final class IsFollowingUserFamily extends $Family
    with
        $ClassFamilyOverride<
          IsFollowingUser,
          AsyncValue<bool>,
          bool,
          FutureOr<bool>,
          String
        > {
  IsFollowingUserFamily._()
    : super(
        retry: null,
        name: r'isFollowingUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsFollowingUserProvider call(String userId) =>
      IsFollowingUserProvider._(argument: userId, from: this);

  @override
  String toString() => r'isFollowingUserProvider';
}

abstract class _$IsFollowingUser extends $AsyncNotifier<bool> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<bool> build(String userId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
