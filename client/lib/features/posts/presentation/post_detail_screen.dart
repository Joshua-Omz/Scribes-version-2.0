import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/posts/application/post_detail_provider.dart';
import 'package:scribes/core/widgets/scribes_ornament_divider.dart';
import 'package:scribes/core/widgets/scribes_reaction_bar.dart';
import 'package:scribes/core/widgets/scribes_author_header.dart';
import 'package:scribes/features/posts/presentation/widgets/post_rich_text.dart';
import 'package:scribes/features/posts/presentation/widgets/version_history_sheet.dart';
import '../../../core/widgets/scribes_comment_sheet.dart';
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
          onPressed: () => context.pop(),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'This post corrects an original note.',
                          style: ScribesTextStyles.labelSm.copyWith(color: colors.orange),
                        ),
                        if (post.correctsPostId != null) ...[
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              context.push('/posts/${post.correctsPostId}');
                            },
                            child: Text(
                              'View Original',
                              style: ScribesTextStyles.labelSm.copyWith(
                                color: colors.orange,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                      ScribesAuthorHeader(
                        authorName: post.authorName,
                        authorHandle: post.authorHandle,
                        publishedAt: post.publishedAt,
                        isCorrection: post.isCorrection,
                        onTap: () {
                          // Navigate to author profile
                        },
                      ),
                      const SizedBox(height: 32),
                      const ScribesOrnamentDivider(),
                      const SizedBox(height: 32),
                      
                      Builder(
                        builder: (context) {
                          var bodyData = post.content['body'];
                          List<dynamic>? richContent;
                          if (bodyData is List) {
                            richContent = bodyData;
                          } else if (bodyData is String) {
                            try {
                              final decoded = jsonDecode(bodyData);
                              if (decoded is List) richContent = decoded;
                            } catch (_) {}
                          }

                          if (richContent != null) {
                            return PostRichText(content: richContent);
                          } else {
                            return Text(
                              bodyData?.toString() ?? '',
                              style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText),
                            );
                          }
                        },
                      ),

                      if ((post.caption != null && post.caption!.isNotEmpty) || (post.sermonSource != null && post.sermonSource!.isNotEmpty))
                        Container(
                          margin: const EdgeInsets.only(top: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            border: Border(
                              left: BorderSide(color: colors.goldMuted, width: 3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.caption != null && post.caption!.isNotEmpty)
                                Text(
                                  post.caption!,
                                  style: ScribesTextStyles.bodyMd.copyWith(
                                    color: colors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (post.caption != null && post.caption!.isNotEmpty && post.sermonSource != null && post.sermonSource!.isNotEmpty)
                                const SizedBox(height: 12),
                              if (post.sermonSource != null && post.sermonSource!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(Icons.church_outlined, size: 14, color: colors.gold),
                                    const SizedBox(width: 6),
                                    Text(
                                      post.sermonSource!.displayTitle,
                                      style: ScribesTextStyles.caption.copyWith(
                                        color: colors.goldMuted,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
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
                              ScribesCommentSheet.show(context, postId: postId);
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
