import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/posts/application/post_detail_provider.dart';
import 'package:scribes/core/widgets/scribes_ornament_divider.dart';
import 'package:scribes/core/widgets/scribes_reaction_bar.dart';
import 'package:scribes/features/posts/presentation/widgets/post_rich_text.dart';
import 'package:scribes/features/posts/presentation/widgets/version_history_sheet.dart';
import 'package:scribes/features/social/presentation/comments_sheet.dart';
import 'package:scribes/core/widgets/scribes_unauth_banner.dart';
import 'package:scribes/features/social/application/post_social_providers.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:go_router/go_router.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    final state = ref.watch(postDetailProvider(postId));
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: colors.primaryText),
            onPressed: () {
              ref.read(postDetailProvider(postId).notifier).loadVersions();
              VersionHistorySheet.show(context, postId);
            },
          ),
        ],
      ),
      body: state.when(
        data: (data) {
          final post = data.post;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.isCorrection)
                  Container(
                    width: double.infinity,
                    color: colors.orangeSoft,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      'This post corrects a previous version.',
                      style: ScribesTextStyles.labelSm.copyWith(color: colors.orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.content['title'] ?? 'Untitled',
                        style: ScribesTextStyles.displayLg.copyWith(color: colors.primaryText),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colors.goldMuted,
                            child: Text(
                              post.authorName.isNotEmpty ? post.authorName[0] : '?',
                              style: ScribesTextStyles.labelLg.copyWith(color: colors.surface),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post.authorName, style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
                              Text('@${post.authorHandle}', style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const ScribesOrnamentDivider(),
                      const SizedBox(height: 32),
                      
                      // Rich text renderer
                      if (post.content['body'] is List)
                        PostRichText(content: post.content['body'] as List)
                      else
                        Text(
                          post.content['body']?.toString() ?? '',
                          style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                        ),

                      const SizedBox(height: 48),
                      // Reaction Bar
                      Consumer(
                        builder: (context, ref, child) {
                          final reactionsState = ref.watch(postReactionsProvider(postId));
                          final commentsState = ref.watch(postCommentsProvider(postId));

                          final reactions = reactionsState.value ?? [];
                          final comments = commentsState.value ?? [];

                          return ScribesReactionBar(
                            amenCount: reactions.where((r) => r.type == 'amen').fold(0, (sum, r) => sum + r.count),
                            insightCount: reactions.where((r) => r.type == 'insight').fold(0, (sum, r) => sum + r.count),
                            thoughtCount: comments.length,
                            onReact: (type) {
                              if (!isAuthenticated) {
                                context.push('/auth');
                                return;
                              }
                              ref.read(postReactionsProvider(postId).notifier).react(type);
                            },
                            onComment: () {
                              if (!isAuthenticated) {
                                context.push('/auth');
                                return;
                              }
                              CommentsSheet.show(context, postId);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: colors.gold)),
        error: (err, stack) => Center(
          child: Text('Error loading post: $err', style: TextStyle(color: colors.primaryText)),
        ),
      ),
      bottomNavigationBar: isAuthenticated
          ? null
          : ScribesUnauthBanner(
              onJoinTap: () => context.push('/auth'),
              onLoginTap: () => context.push('/auth'),
            ),
    );
  }
}
