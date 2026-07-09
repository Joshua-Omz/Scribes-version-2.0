import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../../auth/application/auth_notifier.dart';

class PrivateProfileScreen extends ConsumerStatefulWidget {
  const PrivateProfileScreen({super.key});

  @override
  ConsumerState<PrivateProfileScreen> createState() => _PrivateProfileScreenState();
}

class _PrivateProfileScreenState extends ConsumerState<PrivateProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.value;

    if (user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            pinned: true,
            title: Text('Profile', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
            actions: [
              IconButton(
                icon: Icon(Icons.settings_outlined, color: colors.primaryText),
                onPressed: () {
                  // Navigate to Settings
                },
              ),
              IconButton(
                icon: Icon(Icons.logout, color: colors.primaryText),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              color: colors.surface,
              child: Column(
                children: [
                  ScribesAvatar(
                    authorName: user.displayName,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.handle}',
                    style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('Followers', '124', colors),
                      const SizedBox(width: 40),
                      _buildStatItem('Following', '42', colors),
                    ],
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      // Edit Profile
                    },
                    child: Text('Edit Profile', style: ScribesTextStyles.labelLg),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: ScribesTabBarDelegate(
              child: ScribesTabBar(
                selectedIndex: _selectedTabIndex,
                tabs: const ['POSTS', 'DRAFTS', 'SAVED'],
                onTabChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ), 
            ),
          ),
          SliverFillRemaining(
            child: Container(
              color: colors.background,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feed_outlined, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      _selectedTabIndex == 0 ? 'No posts yet.' : 'No drafts.',
                      style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String count, dynamic colors) {
    return Column(
      children: [
        Text(
          count,
          style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
        ),
        Text(
          label,
          style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
        ),
      ],
    );
  }
}
