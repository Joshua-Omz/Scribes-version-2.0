import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/scribes_post_card.dart';
import '../../../core/widgets/scribes_bottom_nav.dart';
import '../application/explore_notifier.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesState = ref.watch(categoriesProvider);
    final postsState = ref.watch(explorePostsProvider);
    final selectedCategory = ref.watch(exploreSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Explore', style: TextStyle(fontFamily: 'CormorantGaramond', fontSize: 24, fontWeight: FontWeight.w600)),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search not implemented in v1 MVP
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Categories Row
          categoriesState.when(
            data: (categories) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(exploreSelectedCategoryProvider.notifier).select(null);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat.id,
                        onSelected: (selected) {
                          ref.read(exploreSelectedCategoryProvider.notifier).select(selected ? cat.id : null);
                        },
                      ),
                    )),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
            error: (e, st) => const SizedBox(height: 50, child: Center(child: Text('Failed to load categories'))),
          ),
          
          const Divider(),

          // Posts Feed
          Expanded(
            child: postsState.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts found.'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(explorePostsProvider.notifier).refresh(),
                  child: ListView.builder(
                    itemCount: posts.length + (ref.read(explorePostsProvider.notifier).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        ref.read(explorePostsProvider.notifier).loadMore();
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final post = posts[index];
                      // Top post is featured
                      final isFeatured = index == 0 && selectedCategory == null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ScribesPostCard(
                          title: post.content['title'] ?? 'Untitled',
                          authorName: post.authorName,
                          authorHandle: post.authorHandle,
                          bodyExcerpt: post.content['body'] ?? '',
                          caption: post.caption,
                          sermonSource: post.sermonSource?.displayTitle,
                          isCorrection: post.isCorrection,
                          publishedAt: post.publishedAt,
                          isFeatured: isFeatured,
                          onTap: () => context.push('/posts/${post.id}'),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ScribesBottomNav(currentIndex: 1),
    );
  }
}
