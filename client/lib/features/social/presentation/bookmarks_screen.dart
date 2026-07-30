import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/widgets/scribes_grid_card.dart';
import 'package:scribes/core/widgets/scribes_empty_state.dart';
import 'package:scribes/core/widgets/scribes_error_state.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/core/widgets/scribes_post_card_skeleton.dart';
import 'package:scribes/core/widgets/scribes_toast.dart';
import 'package:scribes/features/social/application/saved_posts_provider.dart';
import 'dart:ui';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final savedPostsState = ref.watch(savedPostsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: colors.background.withValues(alpha: 0.8),
                ),
              ),
            ),
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
              onPressed: () => context.pop(),
            ),
            title: Text('Bookmarks', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
          ),
          savedPostsState.when(
            data: (savedPosts) {
              if (savedPosts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: ScribesEmptyState(
                      icon: HugeIcons.strokeRoundedBookmark01,
                      title: 'No saved posts',
                      subtitle: 'Posts you save will appear here.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
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

                      return ScribesGridCard(
                        title: title,
                        excerpt: excerpt,
                        date: DateTime.parse(savedPost['created_at']),
                        isSaved: true,
                        onSaveToggle: () {
                          ref.read(savedPostsProvider.notifier).unsavePost(savedPost['post_id']);
                          ScribesToast.show(context, 'Post unsaved', colors, icon: HugeIcons.strokeRoundedRemove01);
                        },
                        onTap: () => context.push('/posts/${savedPost['post_id']}'),
                      );
                    },
                    childCount: savedPosts.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const ScribesPostCardSkeleton(showAvatar: false);
                  },
                  childCount: 3,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: ScribesErrorState(
                title: 'Could not load saved posts',
                subtitle: err.toString(),
                onRetry: () => ref.invalidate(savedPostsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
