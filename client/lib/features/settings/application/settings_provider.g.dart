// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationSettingsNotifier)
final notificationSettingsProvider = NotificationSettingsNotifierProvider._();

final class NotificationSettingsNotifierProvider
    extends
        $AsyncNotifierProvider<
          NotificationSettingsNotifier,
          NotificationPreferences
        > {
  NotificationSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsNotifierHash();

  @$internal
  @override
  NotificationSettingsNotifier create() => NotificationSettingsNotifier();
}

String _$notificationSettingsNotifierHash() =>
    r'ee5b8ad380e63e7b851a14138486c289e031a5a7';

abstract class _$NotificationSettingsNotifier
    extends $AsyncNotifier<NotificationPreferences> {
  FutureOr<NotificationPreferences> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPreferences>,
              NotificationPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPreferences>,
                NotificationPreferences
              >,
              AsyncValue<NotificationPreferences>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
