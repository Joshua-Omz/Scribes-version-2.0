import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          _buildSectionHeader('Appearance', colors),
          const SizedBox(height: 16),
          _buildThemeSelector(context, ref, colors),
          const SizedBox(height: 40),
          _buildSectionHeader('Account', colors),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Edit Profile',
            subtitle: 'Change your username, handle, and bio',
            icon: HugeIcons.strokeRoundedUserEdit01,
            colors: colors,
            onTap: () => context.push('/profile/edit'),
          ),
          _buildSettingsTile(
            title: 'Email & Password',
            subtitle: 'Manage your login credentials',
            icon: HugeIcons.strokeRoundedMail01,
            colors: colors,
            onTap: () => context.push('/settings/security'),
          ),
          _buildSettingsTile(
            title: 'Notifications',
            subtitle: 'Push and email notification preferences',
            icon: HugeIcons.strokeRoundedNotification01,
            colors: colors,
            onTap: () => context.push('/settings/notifications'),
          ),
          const SizedBox(height: 40),
          _buildSectionHeader('Support & About', colors),
          const SizedBox(height: 16),
          _buildSettingsTile(
            title: 'Help Center',
            icon: HugeIcons.strokeRoundedHelpCircle,
            colors: colors,
            onTap: () {},
          ),
          _buildSettingsTile(
            title: 'About Scribes',
            icon: HugeIcons.strokeRoundedInformationCircle,
            colors: colors,
            onTap: () {},
          ),
        ],
      ),
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

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, ScribesColors currentColors) {
    final themes = [
      {'name': 'Night', 'theme': ScribesColors.night},
      {'name': 'Parchment', 'theme': ScribesColors.parchment},
      {'name': 'Silver', 'theme': ScribesColors.silver},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: themes.map((t) {
        final name = t['name'] as String;
        final theme = t['theme'] as ScribesColors;
        final isSelected = currentColors == theme;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(themeProvider.notifier).setTheme(theme);
            },
            child: Container(
              margin: EdgeInsets.only(right: name != 'Silver' ? 12.0 : 0.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    height: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? currentColors.gold : theme.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: currentColors.gold.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: theme.gold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.primaryText.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, size: 14, color: currentColors.gold),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          name,
                          style: ScribesTextStyles.labelLg.copyWith(
                            color: isSelected ? currentColors.primaryText : currentColors.secondaryText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required dynamic icon,
    required ScribesColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: HugeIcon(icon: icon, size: 20, color: colors.gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ScribesTextStyles.bodyLg.copyWith(
                      color: colors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ScribesTextStyles.labelSm.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }
}
