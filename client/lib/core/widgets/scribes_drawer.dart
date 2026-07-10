import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import '../../features/auth/application/auth_notifier.dart';

class ScribesDrawer extends ConsumerWidget {
  const ScribesDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Drawer(
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  if (user != null)
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.surfaceRaised,
                      child: user.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.avatarUrl!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                              style: ScribesTextStyles.displayMd.copyWith(color: colors.gold),
                            ),
                    )
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: colors.surfaceRaised,
                      child: Icon(Icons.person_outline, color: colors.gold),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: user != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '@${user.handle}',
                                style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Scribes',
                                style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to sync your work',
                                style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Menu Items
            if (user != null) ...[
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: Icons.person_outline,
                title: 'Profile',
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  context.push('/profile');
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: Icons.edit_document,
                title: 'Drafts Workspace',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/drafts');
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: Icons.bookmark_border,
                title: 'Bookmarks',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to bookmarks
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmarks coming soon')),
                  );
                },
              ),
            ] else ...[
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: Icons.login,
                title: 'Sign In / Join',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/auth');
                },
              ),
            ],
            
            const Divider(height: 32, thickness: 1),
            
            _buildMenuItem(
              context: context,
              colors: colors,
              icon: Icons.palette_outlined,
              title: 'Change Theme',
              onTap: () {
                _cycleTheme(ref, colors);
              },
            ),
            
            _buildMenuItem(
              context: context,
              colors: colors,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
                );
              },
            ),
            
            const Spacer(),
            
            if (user != null)
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: Icons.logout,
                title: 'Sign Out',
                textColor: colors.orange,
                iconColor: colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _cycleTheme(WidgetRef ref, ScribesColors currentTheme) {
    if (currentTheme == ScribesColors.light) {
      ref.read(themeProvider.notifier).setTheme(ScribesColors.dark);
    } else if (currentTheme == ScribesColors.dark) {
      ref.read(themeProvider.notifier).setTheme(ScribesColors.night);
    } else if (currentTheme == ScribesColors.night) {
      ref.read(themeProvider.notifier).setTheme(ScribesColors.parchment);
    } else if (currentTheme == ScribesColors.parchment) {
      ref.read(themeProvider.notifier).setTheme(ScribesColors.silver);
    } else {
      ref.read(themeProvider.notifier).setTheme(ScribesColors.light);
    }
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ScribesColors colors,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? colors.secondaryText,
        size: 24,
      ),
      title: Text(
        title,
        style: ScribesTextStyles.bodyMd.copyWith(
          color: textColor ?? colors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      onTap: onTap,
    );
  }
}
