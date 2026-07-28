import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/core/widgets/scribes_tab_bar.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/features/auth/domain/user.dart';
import 'package:scribes/features/social/application/follow_list_provider.dart';

class FollowListScreen extends ConsumerStatefulWidget {
  final String userId;
  final int initialIndex;

  const FollowListScreen({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends ConsumerState<FollowListScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text('Connections', style: TextStyle(color: colors.primaryText)),
      ),
      body: Column(
        children: [
          ScribesTabBar(
            tabs: const ['Followers', 'Following'],
            selectedIndex: _selectedIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _FollowersTab(userId: widget.userId, colors: colors),
                _FollowingTab(userId: widget.userId, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowersTab extends ConsumerWidget {
  final String userId;
  final ScribesColors colors;

  const _FollowersTab({required this.userId, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(userId));

    return followersAsync.when(
      data: (followers) {
        if (followers.isEmpty) {
          return _buildEmptyState('No followers yet', colors);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final user = followers[index];
            return _UserListTile(user: user, colors: colors);
          },
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load followers', style: TextStyle(color: colors.primaryText)),
      ),
    );
  }
}

class _FollowingTab extends ConsumerWidget {
  final String userId;
  final ScribesColors colors;

  const _FollowingTab({required this.userId, required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider(userId));

    return followingAsync.when(
      data: (following) {
        if (following.isEmpty) {
          return _buildEmptyState('Not following anyone', colors);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: following.length,
          itemBuilder: (context, index) {
            final user = following[index];
            return _UserListTile(user: user, colors: colors);
          },
        );
      },
      loading: () => const Center(child: ScribesLoadingIndicator()),
      error: (error, stack) => Center(
        child: Text('Failed to load following', style: TextStyle(color: colors.primaryText)),
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final User user;
  final ScribesColors colors;

  const _UserListTile({required this.user, required this.colors});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/users/${user.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ScribesAvatar(
              imageUrl: user.avatarUrl,
              authorName: user.displayName.isNotEmpty ? user.displayName : user.handle,
              radius: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName.isNotEmpty ? user.displayName : user.handle,
                    style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.handle}',
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(String message, ScribesColors colors) {
  return Center(
    child: Text(
      message,
      style: TextStyle(
        color: colors.secondaryText,
        fontSize: 16,
        fontFamily: 'CormorantGaramond',
        fontStyle: FontStyle.italic,
      ),
    ),
  );
}