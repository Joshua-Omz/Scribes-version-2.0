import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/features/posts/application/post_detail_provider.dart';
import 'package:scribes/core/widgets/scribes_ornament_divider.dart';
import 'package:scribes/core/widgets/scribes_reaction_bar.dart';
import 'package:scribes/core/widgets/scribes_author_header.dart';
import 'package:scribes/features/posts/presentation/widgets/post_rich_text.dart';
import 'package:scribes/features/posts/presentation/widgets/version_history_sheet.dart';
import 'package:scribes/core/widgets/scribes_comment_sheet.dart';
import 'package:scribes/core/widgets/scribes_loading_indicator.dart';
import 'package:scribes/core/widgets/scribes_scripture_chip.dart';
import 'package:scribes/core/widgets/scribes_unauth_banner.dart';
import 'package:scribes/core/widgets/scribes_error_state.dart';
import 'package:scribes/features/social/application/post_social_providers.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/core/widgets/scribes_toast.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(postDetailProvider(postId));
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value != null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: colors.primaryText),
          onPressed: () => context.pop(),
        ),
        actions: [
          state.whenOrNull(
            data: (data) {
              final isAuthor = isAuthenticated && authState.value?.id == data.post.authorId;
              if (isAuthor) {
                return IconButton(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreVertical, color: colors.primaryText),
                  onPressed: () {
                    _showPostOptions(context, ref, data.post, colors);
                  },
                );
              }
              return null;
            },
          ) ?? const SizedBox.shrink(),
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedClock01, color: colors.primaryText),
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
                        HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: colors.orange, size: 16),
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
                          context.push('/users/${post.authorId}');
                        },
                      ),
                      if (post.scriptureRefs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: post.scriptureRefs.map((ref) {
                              final refStr = ref.verseEnd != null
                                  ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
                                  : '${ref.book} ${ref.chapter}:${ref.verseStart}';
                              return ScribesScriptureChip(
                                reference: refStr,
                                onTap: () {},
                              );
                            }).toList(),
                          ),
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
                              if (post.sermonSource != null && post.sermonSource!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.sermonSource!.preacher != null && post.sermonSource!.preacher!.isNotEmpty)
                                      Row(
                                        children: [
                                          HugeIcon(icon: HugeIcons.strokeRoundedUserGroup, size: 14, color: colors.gold),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Preacher: ${post.sermonSource!.preacher!}',
                                            style: ScribesTextStyles.caption.copyWith(color: colors.goldMuted),
                                          ),
                                        ],
                                      ),
                                    if (post.sermonSource!.church != null && post.sermonSource!.church!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            HugeIcon(icon: HugeIcons.strokeRoundedChurch, size: 14, color: colors.gold),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Church: ${post.sermonSource!.church!}',
                                              style: ScribesTextStyles.caption.copyWith(color: colors.goldMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (post.sermonSource!.series != null && post.sermonSource!.series!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            HugeIcon(icon: HugeIcons.strokeRoundedBookOpen01, size: 14, color: colors.gold),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Series: ${post.sermonSource!.series!}',
                                              style: ScribesTextStyles.caption.copyWith(color: colors.goldMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (post.sermonSource!.date != null && post.sermonSource!.date!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          children: [
                                            HugeIcon(icon: HugeIcons.strokeRoundedCalendar01, size: 14, color: colors.gold),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Date: ${post.sermonSource!.date!}',
                                              style: ScribesTextStyles.caption.copyWith(color: colors.goldMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: post.tags.map((tag) => Text(
                            '#$tag',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.goldMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          )).toList(),
                        ),
                      ],

                      const SizedBox(height: 48),
                      // Reaction Bar
                      Consumer(
                        builder: (context, ref, child) {
                          final reactionsState = ref.watch(postReactionsProvider(postId));
                          final commentsState = ref.watch(postCommentsProvider(postId));

                          final reactionsStateData = reactionsState.value;
                          final reactions = reactionsStateData?.counts ?? [];
                          final userReaction = (reactionsStateData?.modifiedReaction ?? false) 
                              ? reactionsStateData?.userReaction 
                              : null; 
                          final comments = commentsState.value ?? [];
                          
                          return ScribesReactionBar(
                            amenCount: reactions.where((r) => r.type == 'amen').fold(0, (sum, r) => sum + r.count),
                            insightCount: reactions.where((r) => r.type == 'insightful').fold(0, (sum, r) => sum + r.count),
                            thoughtProvokingCount: reactions.where((r) => r.type == 'thought_provoking').fold(0, (sum, r) => sum + r.count),
                            commentCount: comments.length,
                            userReactions: userReaction != null ? [userReaction] : [],
                            onReact: (type) {
                              if (!isAuthenticated) {
                                context.push('/auth');
                                return;
                              }
                              ref.read(postReactionsProvider(postId).notifier).react(type, knownUserReaction: null);
                            },
                            onComment: () {
                              if (!isAuthenticated) {
                                context.push('/auth');
                                return;
                              }
                              ScribesCommentSheet.show(context, postId: postId, postAuthorId: post.authorId);
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
        loading: () => Center(child: ScribesLoadingIndicator()),
        error: (err, stack) => ScribesErrorState(
          title: 'Error loading post',
          subtitle: err.toString(),
          onRetry: () => ref.refresh(postDetailProvider(postId)),
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

  void _showPostOptions(BuildContext context, WidgetRef ref, Post post, dynamic colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: HugeIcon(icon: HugeIcons.strokeRoundedPencilEdit01, color: colors.primaryText),
                title: Text('Edit Post', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText)),
                onTap: () {
                  context.pop();
                  context.push('/posts/${post.id}/edit', extra: post);
                },
              ),
              ListTile(
                leading: HugeIcon(icon: HugeIcons.strokeRoundedDelete01, color: colors.orange),
                title: Text('Delete Post', style: ScribesTextStyles.bodyLg.copyWith(color: colors.orange)),
                onTap: () {
                  context.pop();
                  _showDeleteConfirmation(context, ref, post.id, colors);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String postId, dynamic colors) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Delete Post?', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
          content: Text('This action cannot be undone. Are you sure you want to delete this post?', style: ScribesTextStyles.bodyLg.copyWith(color: colors.secondaryText)),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text('Cancel', style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
            ),
            TextButton(
              onPressed: () {
                context.pop(); // close dialog
                
                // 1. Fire optimistic background delete
                ref.read(postDetailProvider(postId).notifier).optimisticDeletePost();
                
                // 2. Immediately pop the post detail screen back to feed
                if (context.mounted) {
                  ScribesToast.show(context, 'Post deleted', colors, icon: HugeIcons.strokeRoundedDelete01);
                  context.pop();
                }
              },
              child: Text('Delete', style: ScribesTextStyles.labelLg.copyWith(color: colors.orange)),
            ),
          ],
        );
      },
    );
  }
}
