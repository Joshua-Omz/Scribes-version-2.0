import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/scribes_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_toast.dart';
import '../application/settings_provider.dart';
import '../domain/notification_preferences.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
      ),
      body: state.when(
        data: (prefs) => _buildPreferences(context, ref, prefs, colors),
        loading: () => const Center(child: ScribesLoadingIndicator()),
        error: (e, _) => Center(
          child: Text('Failed to load preferences: \$e', style: TextStyle(color: colors.primaryText)),
        ),
      ),
    );
  }

  Widget _buildPreferences(
    BuildContext context,
    WidgetRef ref,
    NotificationPreferences prefs,
    ScribesColors colors,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        _buildSectionHeader('Channels', colors),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive alerts on this device',
          value: prefs.pushEnabled,
          colors: colors,
          onChanged: (val) => _updatePref(context, ref, prefs.copyWith(pushEnabled: val)),
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates in your inbox',
          value: prefs.emailEnabled,
          colors: colors,
          onChanged: (val) => _updatePref(context, ref, prefs.copyWith(emailEnabled: val)),
        ),
        const SizedBox(height: 40),
        _buildSectionHeader('Activity Alerts', colors),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Direct Messages',
          subtitle: 'When someone sends you a message',
          value: prefs.dmAlerts,
          colors: colors,
          onChanged: (val) => _updatePref(context, ref, prefs.copyWith(dmAlerts: val)),
        ),
        _buildSwitchTile(
          title: 'New Followers',
          subtitle: 'When someone follows your profile',
          value: prefs.newFollowerAlerts,
          colors: colors,
          onChanged: (val) => _updatePref(context, ref, prefs.copyWith(newFollowerAlerts: val)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ScribesColors colors) {
    return Text(
      title.toUpperCase(),
      style: ScribesTextStyles.labelSm.copyWith(
        color: colors.secondaryText,
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ScribesColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ScribesTextStyles.bodyLg.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: colors.gold,
            activeTrackColor: colors.gold.withOpacity(0.3),
            inactiveThumbColor: colors.secondaryText,
            inactiveTrackColor: colors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _updatePref(BuildContext context, WidgetRef ref, NotificationPreferences newPrefs) async {
    try {
      await ref.read(notificationSettingsProvider.notifier).updatePreferences(newPrefs);
    } catch (e) {
      if (context.mounted) {
        final colors = ref.read(themeProvider);
        ScribesToast.show(context, 'Failed to update preferences', colors, isError: true);
      }
    }
  }
}
