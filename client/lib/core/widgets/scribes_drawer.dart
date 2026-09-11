import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/theme_provider.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import '../../features/auth/application/auth_notifier.dart';
import '../../features/messages/application/inbox_providers.dart';
import 'scribes_author_header.dart';
import 'scribes_brand_logo.dart';

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
                  const SizedBox(height: 8),
                  const ScribesBrandLogo(
                    variant: BrandLogoVariant.horizontal,
                    size: 24,
                  ),
                  const SizedBox(height: 18),
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
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            color: colors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to Scribes',
                                style: ScribesTextStyles.labelLg.copyWith(
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sign in to sync your work',
                                style: ScribesTextStyles.labelSm.copyWith(
                                  color: colors.secondaryText,
                                ),
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

            _buildMenuItem(
              context: context,
              colors: colors,
              icon: HugeIcons.strokeRoundedBook01,
              title: 'Bible',
              onTap: () {
                Navigator.pop(context);
                context.push('/bible');
              },
            ),
            const SizedBox(height:8),

            // Menu Items
            if (user != null) ...[
              Consumer(
                builder: (context, ref, _) {
                  final unreadCount = ref.watch(unreadMessagesCountProvider);
                  return _buildMenuItem(
                    context: context,
                    colors: colors,
                    icon: HugeIcons.strokeRoundedChatAdd,
                    title: 'Messages',
                    badgeCount: unreadCount,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/inbox');
                    },
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: HugeIcons.strokeRoundedFolder01,
                title: 'Workspace',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/drafts');
                },
              ),
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: HugeIcons.strokeRoundedBookmark01,
                title: 'Bookmarks',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/bookmarks');
                },
              ),
            ] else ...[
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: HugeIcons.strokeRoundedLogin01,
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
              icon: HugeIcons.strokeRoundedSettings01,
              title: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),

            const Spacer(),

            if (user != null)
              _buildMenuItem(
                context: context,
                colors: colors,
                icon: HugeIcons.strokeRoundedLogout01,
                title: 'Sign Out',
                textColor: colors.orange,
                iconColor: colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
              ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'THE WORD IS MADE FLESH',
                style: ScribesTextStyles.caption.copyWith(
                  letterSpacing: 2.0,
                  color: colors.secondaryText.withValues(alpha: 0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required ScribesColors colors,
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    int? badgeCount,
  }) {
    return ListTile(
      leading: HugeIcon(
        icon: icon,
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
      trailing: (badgeCount != null && badgeCount > 0)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : badgeCount.toString(),
                style: TextStyle(
                  color: colors.background,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      onTap: onTap,
    );
  }
}
