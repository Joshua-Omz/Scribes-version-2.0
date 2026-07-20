import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_avatar.dart';
import '../../../core/widgets/scribes_tab_bar.dart';
import '../../../core/widgets/scribes_tab_bar_delegate.dart';
import '../../auth/application/auth_notifier.dart';
import 'package:scribes/features/social/application/saved_posts_provider.dart';
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
                      _buildStatItem('Followers', user.followersCount.toString(), colors),
                      const SizedBox(width: 40),
                      _buildStatItem('Following', user.followingCount.toString(), colors),
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
                          final savedPosts = ref.watch(savedPostsProvider).value ?? [];
                          final isSaved = savedPosts.any((p) => p['id'] == post.id || p['post_id'] == post.id);

                          // Simple excerpt extractor
                          String excerpt = '';
                          if (post.content['ops'] != null) {
                            for (var op in post.content['ops']) {
                              if (op['insert'] is String) {
                                excerpt += op['insert'];
                                if (excerpt.length > 100) {
                                  excerpt = '${excerpt.substring(0, 100)}...';
                                  break;
                                }
                              }
                            }
                          }
                          return ScribesProfilePostCard(
                            title: post.content['title'] ?? '',
                            excerpt: excerpt,
                            publishedAt: post.publishedAt,
                            isSaved: isSaved,
                            onSaveToggle: () {
                              if (isSaved) {
                                ref.read(savedPostsProvider.notifier).unsavePost(post.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post unsaved')));
                              } else {
                                ref.read(savedPostsProvider.notifier).savePost(post.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post saved')));
                              }
                            },
                            onTap: () => context.push('/posts/${post.id}'),
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
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
                          if (draft.content['ops'] != null) {
                            for (var op in draft.content['ops']) {
                              if (op['insert'] is String) {
                                excerpt += op['insert'];
                                if (excerpt.length > 100) {
                                  excerpt = '${excerpt.substring(0, 100)}...';
                                  break;
                                }
                              }
                            }
                          }
                          return ScribesProfileDraftCard(
                            title: draft.content['title'] ?? '',
                            excerpt: excerpt,
                            updatedAt: draft.updatedAt,
                            onTap: () => context.push('/drafts/${draft.id}'),
                          );
                        },
                        childCount: drafts.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
                );
              },
            ),
          if (_selectedTabIndex == 2)
            Consumer(
              builder: (context, ref, child) {
                final savedPostsState = ref.watch(savedPostsProvider);
                return savedPostsState.when(
                  data: (savedPosts) {
                    if (savedPosts.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_outline, size: 64, color: colors.secondaryText.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('No saved posts.', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final savedPost = savedPosts[index];
                          // Simple excerpt extractor
                          String excerpt = '';
                          final content = savedPost['content'];
                          if (content != null && content['ops'] != null) {
                            for (var op in content['ops']) {
                              if (op['insert'] is String) {
                                excerpt += op['insert'];
                                if (excerpt.length > 100) {
                                  excerpt = '${excerpt.substring(0, 100)}...';
                                  break;
                                }
                              }
                            }
                          }
                          String title = 'Saved Post';
                          final captionField = savedPost['caption'];
                          if (captionField is String && captionField.isNotEmpty) {
                            title = captionField;
                          } else if (captionField is Map && captionField['Valid'] == true) {
                            title = captionField['String'] ?? 'Saved Post';
                          } else if (content != null && content['title'] is String) {
                            title = content['title'];
                          }

                          // Use the ScribesProfilePostCard for now, though it expects a post object. We might need a generic one.
                          return ScribesProfilePostCard(
                            title: title,
                            excerpt: excerpt,
                            publishedAt: DateTime.parse(savedPost['created_at']),
                            onTap: () => context.push('/posts/${savedPost['post_id']}'),
                          );
                        },
                        childCount: savedPosts.length,
                      ),
                    );
                  },
                  loading: () => const SliverFillRemaining(child: Center(child: ScribesLoadingIndicator())),
                  error: (err, stack) => SliverFillRemaining(child: Center(child: Text('Error: $err'))),
                );
              },
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
