// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationNotifier)
final notificationProvider = NotificationNotifierProvider._();

final class NotificationNotifierProvider
    extends
        $AsyncNotifierProvider<NotificationNotifier, List<NotificationItem>> {
  NotificationNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationNotifierHash();

  @$internal
  @override
  NotificationNotifier create() => NotificationNotifier();
}

String _$notificationNotifierHash() =>
    r'f73c0802b5e3fd7300ed030d1339dacb7ab32a7f';

abstract class _$NotificationNotifier
    extends $AsyncNotifier<List<NotificationItem>> {
  FutureOr<List<NotificationItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<NotificationItem>>, List<NotificationItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<NotificationItem>>,
                List<NotificationItem>
              >,
              AsyncValue<List<NotificationItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(hasUnreadNotifications)
final hasUnreadNotificationsProvider = HasUnreadNotificationsProvider._();

final class HasUnreadNotificationsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  HasUnreadNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasUnreadNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasUnreadNotificationsHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return hasUnreadNotifications(ref);
  }
}

String _$hasUnreadNotificationsHash() =>
    r'cd36eca536779357bc83f279bdf1683758823973';
