import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/scribes_post_card.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../application/feed_notifier.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Feed', style: TextStyle(fontFamily: 'CormorantGaramond', fontSize: 24, fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: feedState.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState(context);
          }

            return RefreshIndicator(
              onRefresh: () => ref.read(feedProvider.notifier).refresh(),
              child: ListView.builder(
                itemCount: posts.length + (ref.read(feedProvider.notifier).hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    // Reached bottom, load more
                    ref.read(feedProvider.notifier).loadMore();
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ScribesPostCard(
                    title: post.content['title'] ?? 'Untitled',
                    authorName: post.authorName,
                    authorHandle: post.authorHandle,
                    bodyExcerpt: post.content['body'] ?? '',
                    isFeatured: false,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 0),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed_outlined, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Your scroll is empty',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow other writers or explore to discover new insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
