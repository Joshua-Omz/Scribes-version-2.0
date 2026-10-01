import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/feed/application/feed_notifier.dart';
import '../../features/posts/domain/post.dart';
import 'scribes_post_tile.dart';

class ScribesLightPostTile extends ConsumerWidget {
  final String postId;
  final Post? post;
  final bool isExploreScreen;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;

  const ScribesLightPostTile({
    super.key,
    required this.postId,
    this.post,
    this.isExploreScreen = false,
    this.onTap,
    this.onAuthorTap,
  });
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GRANULAR REACTIVITY: O(1) Lookup if post is not explicitly passed
    final resolvedPost = post ??
        ref.watch(feedProvider.select((state) => state.value?.posts[postId]));

    if (resolvedPost == null) return const SizedBox.shrink();

    // ScribesPostTile handles all the layout, action bars, image extraction, and dividers
    return ScribesPostTile(
      post: resolvedPost,
      onTap: onTap,
      onAuthorTap: onAuthorTap,
      isExploreScreen: isExploreScreen,
    );
  }
}
