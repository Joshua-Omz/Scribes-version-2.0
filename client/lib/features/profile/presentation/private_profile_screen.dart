import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../../auth/application/auth_notifier.dart';
import '../../../core/widgets/scribes_profile_post_card.dart';
import '../../../core/widgets/scribes_profile_draft_card.dart';
import '../../posts/application/my_posts_provider.dart';
import '../../draft/application/drafts_list_provider.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';

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
        body: const Center(child: ScribesLoadingIndicator()),
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
            leading: context.canPop()
                ? IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.primaryText),
                    onPressed: () => context.pop(),
                  )
                : null,
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
                      context.push('/profile/edit');
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
                tabs: const ['Posts', 'Drafts', 'Saved'],
                onTabChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ), 
            ),
          ),
          if (_selectedTabIndex == 0)
            Consumer(
              builder: (context, ref, child) {
                final postsState = ref.watch(myPostsProvider);
                return postsState.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.feed_outlined, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('No posts yet.', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          // Simple excerpt extractor
                          String excerpt = '';
                          if (post.content != null && post.content['ops'] != null) {
                            for (var op in post.content['ops']) {
                              if (op['insert'] is String) {
                                excerpt += op['insert'];
                                if (excerpt.length > 100) {
                                  excerpt = '\${excerpt.substring(0, 100)}...';
                                  break;
                                }
                              }
                            }
                          }
                          return ScribesProfilePostCard(
                            title: post.caption ?? '',
                            excerpt: excerpt,
                            publishedAt: post.publishedAt,
                            onTap: () => context.push('/posts/\${post.id}'),
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: \$err'))),
                );
              },
            ),
          if (_selectedTabIndex == 1)
            Consumer(
              builder: (context, ref, child) {
                final draftsState = ref.watch(draftsListProvider);
                return draftsState.when(
                  data: (drafts) {
                    if (drafts.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_note_outlined, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('No drafts.', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final draft = drafts[index];
                          String excerpt = '';
                          if (draft.content != null && draft.content['ops'] != null) {
                            for (var op in draft.content['ops']) {
                              if (op['insert'] is String) {
                                excerpt += op['insert'];
                                if (excerpt.length > 100) {
                                  excerpt = '\${excerpt.substring(0, 100)}...';
                                  break;
                                }
                              }
                            }
                          }
                          return ScribesProfileDraftCard(
                            title: draft.caption ?? '',
                            excerpt: excerpt,
                            updatedAt: draft.updatedAt,
                            onTap: () => context.push('/drafts/\${draft.id}'),
                          );
                        },
                        childCount: drafts.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: \$err'))),
                );
              },
            ),
          if (_selectedTabIndex == 2)
            SliverFillRemaining(
              child: Center(
                child: Text('Saved posts coming soon.', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 4),
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
