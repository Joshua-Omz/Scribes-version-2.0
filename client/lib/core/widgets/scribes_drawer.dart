import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import '../../features/auth/application/auth_notifier.dart';
import 'scribes_author_header.dart';
import 'scribes_toast.dart';

class ScribesDrawer extends ConsumerWidget {
  const ScribesDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    return Drawer(
      backgroundColor: colors.background,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (user != null)
                    ScribesAuthorHeader(
                      authorName: user.displayName,
                      authorHandle: user.handle,
                      avatarUrl: user.avatarUrl,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/profile');
                      },
                    )
                  else
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: colors.surfaceRaised,
                          child: Icon(LucideIcons.user, color: colors.gold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
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
                ],
              ),
        ),
        
        const SizedBox(height: 16),
            
            // Menu Items
            if (user != null) ...[

              _buildMenuItem(
                context: context,
                colors: colors,
                icon: LucideIcons.file_pen,
                title: 'Notes Workspace',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/notes');
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: LucideIcons.file_text,
                title: 'Drafts Workspace',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/drafts');
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: LucideIcons.bookmark,
                title: 'Bookmarks',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to bookmarks
                  ScribesToast.show(context, 'Bookmarks coming soon', colors, icon: LucideIcons.bookmark);
                },
              ),
            ] else ...[
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: LucideIcons.log_in,
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
              icon: LucideIcons.palette,
              title: 'Change Theme',
              onTap: () {
                _cycleTheme(ref, colors);
              },
            ),
            
            _buildMenuItem(
              context: context,
              colors: colors,
              icon: LucideIcons.settings,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings
                ScribesToast.show(context, 'Settings coming soon', colors, icon: LucideIcons.settings);
              },
            ),
            
            const Spacer(),
            
            if (user != null)
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: LucideIcons.log_out,
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
