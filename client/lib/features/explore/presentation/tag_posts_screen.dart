import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/scribes_text_styles.dart';
import '../../../core/widgets/scribes_connected_post_card.dart';
import '../../../core/widgets/scribes_loading_indicator.dart';
import '../../../core/widgets/scribes_empty_state.dart';
import '../../../core/widgets/scribes_error_state.dart';
import '../application/tag_posts_provider.dart';

class TagPostsScreen extends ConsumerWidget {
  final String tag;

  const TagPostsScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final asyncPosts = ref.watch(tagPostsProvider(tag));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: colors.primaryText,
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#$tag',
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
                fontSize: 20,
              ),
            ),
            asyncPosts.maybeWhen(
              data: (posts) => Text(
                '${posts.length} ${posts.length == 1 ? 'post' : 'posts'}',
                style: ScribesTextStyles.caption.copyWith(
                  color: colors.secondaryText,
                  fontSize: 11,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: colors.border.withValues(alpha: 0.35),
          ),
        ),
      ),
      body: asyncPosts.when(
        loading: () => const Center(child: ScribesLoadingIndicator()),
        error: (err, stack) => Center(
          child: ScribesErrorState(
            title: 'Unable to load tag posts',
            subtitle: err.toString(),
            onRetry: () => ref.refresh(tagPostsProvider(tag)),
          ),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedTag01,
                title: 'No posts yet',
                subtitle: 'No public posts found with #$tag',
              ),
            );
          }

          return RefreshIndicator(
            color: colors.gold,
            backgroundColor: colors.surfaceRaised,
            onRefresh: () async {
              ref.invalidate(tagPostsProvider(tag));
            },
            child: ListView.builder(
              scrollCacheExtent: const ScrollCacheExtent.pixels(1500), // Viewport Pre-Rasterization invariant
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  key: ValueKey(post.id),
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ScribesConnectedPostCard(
                    post: post,
                    isFeatured: false,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
