import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/theme/scribes_radius.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
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
import 'package:scribes/core/widgets/scribes_error_state.dart';
import 'package:scribes/features/social/application/post_social_providers.dart';
import 'package:scribes/features/social/application/user_lookup_provider.dart';
import 'package:scribes/features/social/domain/comment.dart';
import 'package:scribes/features/social/domain/comment_author.dart';
import 'package:scribes/features/auth/application/auth_notifier.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/core/widgets/scribes_toast.dart';
import 'package:scribes/core/network/api_exception.dart';
import 'package:scribes/core/widgets/scribes_empty_state.dart';
import 'package:scribes/core/widgets/scribes_share_sheet.dart';
import 'package:scribes/core/widgets/scribes_image_resolver.dart';
import 'package:scribes/core/widgets/scribes_avatar.dart';
import 'package:scribes/core/widgets/scribes_text_field.dart';
import 'package:scribes/core/widgets/scribes_connected_post_card.dart';
import 'package:scribes/features/export/presentation/export_loading_sheet.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsSectionKey = GlobalKey();

  final List<String> _mentionedUserIds = [];
  Timer? _debounceTimer;
  String? _activeMentionQuery;
  bool _showMentionOverlay = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _commentController.removeListener(_onCommentTextChanged);
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCommentTextChanged() {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;

    if (cursorPos < 0 || cursorPos > text.length) {
      _dismissMentionOverlay();
      return;
    }

    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex < 0) {
      _dismissMentionOverlay();
      return;
    }

    if (lastAtIndex > 0 && textBeforeCursor[lastAtIndex - 1] != ' ') {
      _dismissMentionOverlay();
      return;
    }

    final query = textBeforeCursor.substring(lastAtIndex + 1);

    if (query.contains(' ') || query.isEmpty) {
      _dismissMentionOverlay();
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _activeMentionQuery = query;
          _showMentionOverlay = true;
        });
      }
    });
  }

  void _dismissMentionOverlay() {
    if (_showMentionOverlay) {
      setState(() {
        _showMentionOverlay = false;
        _activeMentionQuery = null;
      });
    }
  }

  void _insertMention(CommentAuthor user) {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;
    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex < 0) return;

    final textAfterCursor = text.substring(cursorPos);
    final newText =
        '${text.substring(0, lastAtIndex)}@${user.handle} $textAfterCursor';
    _commentController.text = newText;
    _commentController.selection = TextSelection.collapsed(
      offset: lastAtIndex + user.handle.length + 2,
    );

    _mentionedUserIds.add(user.id);
    _dismissMentionOverlay();
  }

  Future<void> _submitComment() async {
    final authState = ref.read(authProvider);
    if (authState.value == null) {
      context.push('/auth');
      return;
    }

    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    await ref
        .read(postCommentsProvider(widget.postId).notifier)
        .addComment(
          body,
          _mentionedUserIds.toSet().toList(),
        );

    _commentController.clear();
    _mentionedUserIds.clear();
    _dismissMentionOverlay();
    _commentFocusNode.unfocus();
  }

  void _scrollToComments() {
    final context = _commentsSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
    _commentFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final state = ref.watch(postDetailProvider(widget.postId));
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.value != null;

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
        actions: [
          state.whenOrNull(
                data: (data) {
                  return IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedShare01,
                      color: colors.primaryText,
                    ),
                    tooltip: 'Share & Export',
                    onPressed: () {
                      ScribesShareSheet.show(
                        context,
                        data.post.id,
                        post: data.post,
                      );
                    },
                  );
                },
              ) ??
              const SizedBox.shrink(),
          state.whenOrNull(
                data: (data) {
                  final isAuthor =
                      isAuthenticated &&
                      authState.value?.id == data.post.authorId;
                  if (isAuthor) {
                    return IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedMoreVertical,
                        color: colors.primaryText,
                      ),
                      onPressed: () {
                        _showPostOptions(context, ref, data.post, colors);
                      },
                    );
                  }
                  return null;
                },
              ) ??
              const SizedBox.shrink(),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              color: colors.primaryText,
            ),
            tooltip: 'Version History',
            onPressed: () {
              ref.read(postDetailProvider(widget.postId).notifier).loadVersions();
              VersionHistorySheet.show(context, widget.postId);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: state.whenOrNull(
        data: (data) {
          if (data.post.postType == 'passage') {
            return null; // Passage decks use PassageViewerScreen
          }

          return Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  (MediaQuery.of(context).padding.bottom > 0 ? 12 : 16),
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(
                  color: colors.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showMentionOverlay && _activeMentionQuery != null)
                    _MentionSuggestions(
                      query: _activeMentionQuery!,
                      colors: colors,
                      onSelect: _insertMention,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: ScribesAvatar(
                          imageUrl: authState.value?.avatarUrl,
                          authorName: authState.value?.displayName ?? 'Guest',
                          radius: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ScribesTextField(
                          controller: _commentController,
                          focusNode: _commentFocusNode,
                          hintText: 'comment',
                          minLines: 1,
                          maxLines: 4,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedSent,
                              color: colors.surfaceRaised,
                              size: 18,
                            ),
                            onPressed: _submitComment,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: state.when(
        data: (data) {
          final post = data.post;
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.isCorrection)
                  Container(
                    width: double.infinity,
                    color: colors.orangeSoft,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          color: colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'This post corrects an original note.',
                          style: ScribesTextStyles.labelSm.copyWith(
                            color: colors.orange,
                          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Reflection tag badge (Distinct placement so author info isn't crowded)
                      if (post.postType == 'reflection') ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.gold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.gold.withValues(alpha: 0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedQuillWrite02,
                                  color: colors.gold,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Reflection',
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: colors.gold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Standard post title
                      if (post.postType != 'reflection') ...[
                        Text(
                          post.content['title'] ?? 'Untitled',
                          style: ScribesTextStyles.displayLg.copyWith(
                            color: colors.primaryText,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Author Header
                      ScribesAuthorHeader(
                        authorName: post.authorName,
                        authorHandle: post.authorHandle,
                        avatarUrl: post.authorAvatarUrl,
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
                              return ScribesScriptureChip(reference: refStr);
                            }).toList(),
                          ),
                        ),

                      if (post.postType != 'reflection') ...[
                        const SizedBox(height: 24),
                        const ScribesOrnamentDivider(),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 18),
                      ],

                      if (post.postType == 'passage') ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius:
                                BorderRadius.circular(ScribesRadius.card),
                            border: Border.all(
                              color: colors.gold.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.gold.withValues(alpha: 0.12),
                                ),
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedLayers01,
                                  color: colors.gold,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Interactive Passage Deck',
                                style: ScribesTextStyles.displayMd.copyWith(
                                  color: colors.primaryText,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This is an immersive, multi-panel devotional experience with ambient audio and illuminated scripture reflections.',
                                textAlign: TextAlign.center,
                                style: ScribesTextStyles.bodyMd.copyWith(
                                  color: colors.secondaryText,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colors.primaryText,
                                  side: BorderSide(
                                    color: colors.goldEdge,
                                    width: 1.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ScribesRadius.button,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  context.push('/passage/${post.id}');
                                },
                                icon: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedBookOpen01,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                label: Text(
                                  'Launch Passage Deck',
                                  style: ScribesTextStyles.labelLg.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
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
                                post.plainTextBody.isNotEmpty
                                    ? post.plainTextBody
                                    : (bodyData?.toString() ?? ''),
                                style: post.postType == 'reflection'
                                    ? ScribesTextStyles.bodyLg.copyWith(
                                        color: colors.primaryText,
                                        fontSize: 17.5,
                                        height: 1.65,
                                      )
                                    : ScribesTextStyles.bodyLg.copyWith(
                                        color: colors.primaryText,
                                        height: 1.75,
                                      ),
                              );
                            }
                          },
                        ),

                      if (post.reflectionImageUrl != null ||
                          (post.postType == 'reflection' &&
                              ScribesImageResolver.extractFirstImageUrl(post) !=
                                  null)) ...[
                        const SizedBox(height: 20),
                        Builder(builder: (context) {
                          final screenW = MediaQuery.sizeOf(context).width;
                          final displayW = screenW - 40;
                          final displayH = displayW * (9 / 16);
                          final cacheW = ScribesImageResolver.computeCacheWidth(
                            context,
                            displayW,
                            maxPixels: 720,
                          );

                          return SizedBox(
                            width: displayW,
                            height: displayH,
                            child: RepaintBoundary(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ColoredBox(color: colors.surfaceRaised),
                                    ScribesImageResolver.buildImage(
                                      imageUrl: post.reflectionImageUrl ??
                                          ScribesImageResolver.extractFirstImageUrl(
                                            post,
                                          ),
                                      fit: BoxFit.cover,
                                      memCacheWidth: cacheW,
                                      placeholder: (context, url) => ColoredBox(
                                        color: colors.surfaceRaised,
                                      ),
                                      fallback: ColoredBox(
                                        color: colors.surfaceRaised,
                                      ),
                                    ),
                                    IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: colors.border.withValues(alpha: 0.6),
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],

                      if ((post.caption != null && post.caption!.isNotEmpty) ||
                          (post.sermonSource != null &&
                              post.sermonSource!.isNotEmpty))
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
                              left: BorderSide(color: colors.border, width: 3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.caption != null &&
                                  post.caption!.isNotEmpty)
                                Text(
                                  post.caption!,
                                  style: ScribesTextStyles.bodyMd.copyWith(
                                    color: colors.secondaryText,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              if (post.sermonSource != null &&
                                  post.sermonSource!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.sermonSource!.preacher != null &&
                                        post.sermonSource!.preacher!.isNotEmpty)
                                      Row(
                                        children: [
                                          HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedUserGroup,
                                            size: 14,
                                            color: colors.primaryText,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Preacher: ${post.sermonSource!.preacher!}',
                                            style: ScribesTextStyles.caption
                                                .copyWith(
                                                  color: colors.secondaryText,
                                                ),
                                          ),
                                        ],
                                      ),
                                    if (post.sermonSource!.church != null &&
                                        post.sermonSource!.church!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedChurch,
                                              size: 14,
                                              color: colors.primaryText,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Church: ${post.sermonSource!.church!}',
                                              style: ScribesTextStyles.caption
                                                  .copyWith(
                                                    color: colors.secondaryText,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (post.sermonSource!.series != null &&
                                        post.sermonSource!.series!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedBookOpen01,
                                              size: 14,
                                              color: colors.primaryText,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Series: ${post.sermonSource!.series!}',
                                              style: ScribesTextStyles.caption
                                                  .copyWith(
                                                    color: colors.secondaryText,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (post.sermonSource!.date != null &&
                                        post.sermonSource!.date!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            HugeIcon(
                                              icon: HugeIcons
                                                  .strokeRoundedCalendar01,
                                              size: 14,
                                              color: colors.primaryText,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Date: ${post.sermonSource!.date!}',
                                              style: ScribesTextStyles.caption
                                                  .copyWith(
                                                    color: colors.secondaryText,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                      // Clickable tags
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 6.0,
                          children: post.tags
                              .map(
                                (tag) => InkWell(
                                  onTap: () => context.push('/tags/$tag'),
                                  borderRadius: BorderRadius.circular(
                                    ScribesRadius.chip,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceRaised,
                                      borderRadius: BorderRadius.circular(
                                        ScribesRadius.chip,
                                      ),
                                      border: Border.all(
                                        color: colors.border.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: ScribesTextStyles.labelSm.copyWith(
                                        color: colors.secondaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 28),
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),

                      // Reaction Bar
                      Consumer(
                        builder: (context, ref, child) {
                          final reactionsState = ref.watch(
                            postReactionsProvider(widget.postId),
                          );
                          final commentsState = ref.watch(
                            postCommentsProvider(widget.postId),
                          );

                          final reactionsStateData = reactionsState.value;
                          final reactions = reactionsStateData?.counts ?? [];
                          final userReaction =
                              (reactionsStateData?.modifiedReaction ?? false)
                              ? reactionsStateData?.userReaction
                              : null;
                          final comments = commentsState.value ?? [];

                          return ScribesReactionBar(
                            amenCount: reactions
                                .where((r) => r.type == 'amen')
                                .fold(0, (sum, r) => sum + r.count),
                            insightCount: reactions
                                .where((r) => r.type == 'insightful')
                                .fold(0, (sum, r) => sum + r.count),
                            thoughtProvokingCount: reactions
                                .where((r) => r.type == 'thought_provoking')
                                .fold(0, (sum, r) => sum + r.count),
                            commentCount: comments.length,
                            userReactions: userReaction != null
                                ? [userReaction]
                                : [],
                            onReact: (type) {
                              if (!isAuthenticated) {
                                context.push('/auth');
                                return;
                              }
                              ref
                                  .read(postReactionsProvider(widget.postId).notifier)
                                  .react(type, knownUserReaction: null);
                            },
                            onComment: () {
                              if (post.postType == 'passage') {
                                ScribesCommentSheet.show(
                                  context,
                                  postId: widget.postId,
                                  postAuthorId: post.authorId,
                                );
                              } else {
                                _scrollToComments();
                              }
                            },
                            onShare: () =>
                                ScribesShareSheet.show(context, widget.postId),
                          );
                        },
                      ),

                      // Inline Thread Section (Twitter/X style) for standard & reflection posts
                      if (post.postType != 'passage') ...[
                        const SizedBox(height: 24),
                        Container(
                          key: _commentsSectionKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer(
                                builder: (context, ref, child) {
                                  final commentsState = ref.watch(
                                    postCommentsProvider(widget.postId),
                                  );
                                  final comments = commentsState.value ?? [];

                                  return Row(
                                    children: [
                                      Text(
                                        'Thoughts',
                                        style: ScribesTextStyles.displayMd
                                            .copyWith(
                                              color: colors.primaryText,
                                              fontSize: 20,
                                            ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceRaised,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${comments.length}',
                                          style: ScribesTextStyles.labelSm
                                              .copyWith(
                                                color: colors.gold,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Comments List
                              Consumer(
                                builder: (context, ref, child) {
                                  final commentsState = ref.watch(
                                    postCommentsProvider(widget.postId),
                                  );

                                  return commentsState.when(
                                    data: (comments) {
                                      if (comments.isEmpty) {
                                        return Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 28,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceRaised.withValues(
                                              alpha: 0.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: colors.border.withValues(
                                                alpha: 0.4,
                                              ),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              HugeIcon(
                                                icon: HugeIcons
                                                    .strokeRoundedMessage01,
                                                color: colors.secondaryText,
                                                size: 28,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'No thoughts yet',
                                                style: ScribesTextStyles.labelLg
                                                    .copyWith(
                                                      color: colors.primaryText,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Be the first to share your reflections below.',
                                                style: ScribesTextStyles.caption
                                                    .copyWith(
                                                      color:
                                                          colors.secondaryText,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: comments.length,
                                        separatorBuilder:
                                            (context, index) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              child: Divider(
                                                height: 1,
                                                thickness: 0.5,
                                                color: colors.border.withValues(
                                                  alpha: 0.35,
                                                ),
                                              ),
                                            ),
                                        itemBuilder: (context, index) {
                                          final comment = comments[index];
                                          return _InlineCommentTile(
                                            comment: comment,
                                            postId: widget.postId,
                                            postAuthorId: post.authorId,
                                            colors: colors,
                                          );
                                        },
                                      );
                                    },
                                    loading: () => const Padding(
                                      padding: EdgeInsets.all(24.0),
                                      child: Center(
                                        child: ScribesLoadingIndicator(size: 24),
                                      ),
                                    ),
                                    error: (e, _) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        'Unable to load thoughts: $e',
                                        style: ScribesTextStyles.caption
                                            .copyWith(color: colors.orange),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                      // Similar Posts Section
                      Consumer(
                        builder: (context, ref, child) {
                          final similarState = ref.watch(
                            similarPostsProvider(widget.postId),
                          );
                          return similarState.when(
                            data: (posts) {
                              if (posts.isEmpty) return const SizedBox.shrink();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'More on this theme',
                                    style: ScribesTextStyles.displayMd.copyWith(
                                      color: colors.primaryText,
                                      fontSize: 19,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...posts.map(
                                    (p) => Padding(
                                      key: ValueKey(p.id),
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: RepaintBoundary(
                                        child: ScribesConnectedPostCard(
                                          post: p,
                                          isFeatured: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () =>
                                const Center(child: ScribesLoadingIndicator()),
                            error: (e, st) => const SizedBox.shrink(),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: ScribesLoadingIndicator()),
        error: (err, stack) {
          if (err is ApiException && err.statusCode == 404) {
            return const Center(
              child: ScribesEmptyState(
                icon: HugeIcons.strokeRoundedDelete01,
                title: 'Post Deleted',
                subtitle: 'This post is no longer available.',
              ),
            );
          }
          return ScribesErrorState(
            title: 'Error loading post',
            subtitle: err.toString(),
            onRetry: () => ref.refresh(postDetailProvider(widget.postId)),
          );
        },
      ),
    );
  }

  void _showPostOptions(
    BuildContext context,
    WidgetRef ref,
    Post post,
    dynamic colors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (post.postType == 'standard') ...[
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedFile02,
                    color: colors.gold,
                  ),
                  title: Text(
                    'Export Manuscript (PDF)',
                    style: ScribesTextStyles.bodyLg.copyWith(
                      color: colors.primaryText,
                    ),
                  ),
                  subtitle: Text(
                    'Generate illuminated PDF document',
                    style: ScribesTextStyles.labelSm.copyWith(
                      color: colors.secondaryText,
                    ),
                  ),
                  onTap: () {
                    sheetContext.pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        ExportLoadingSheet.show(context, post);
                      }
                    });
                  },
                ),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit01,
                    color: colors.primaryText,
                  ),
                  title: Text(
                    'Edit Post',
                    style: ScribesTextStyles.bodyLg.copyWith(
                      color: colors.primaryText,
                    ),
                  ),
                  onTap: () {
                    sheetContext.pop();
                    context.push('/posts/${post.id}/edit', extra: post);
                  },
                ),
              ],
              ListTile(
                leading: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete01,
                  color: colors.orange,
                ),
                title: Text(
                  'Delete Post',
                  style: ScribesTextStyles.bodyLg.copyWith(
                    color: colors.orange,
                  ),
                ),
                onTap: () {
                  sheetContext.pop();
                  _showDeleteConfirmation(context, ref, post.id, colors);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String postId,
    dynamic colors,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            'Delete Post?',
            style: ScribesTextStyles.displayMd.copyWith(
              color: colors.primaryText,
            ),
          ),
          content: Text(
            'This action cannot be undone. Are you sure you want to delete this post?',
            style: ScribesTextStyles.bodyLg.copyWith(
              color: colors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: ScribesTextStyles.labelLg.copyWith(
                  color: colors.primaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                ref
                    .read(postDetailProvider(postId).notifier)
                    .optimisticDeletePost();

                if (context.mounted) {
                  ScribesToast.show(
                    context,
                    'Post deleted',
                    colors,
                    icon: HugeIcons.strokeRoundedDelete01,
                  );
                  context.pop();
                }
              },
              child: Text(
                'Delete',
                style: ScribesTextStyles.labelLg.copyWith(color: colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Twitter/X Style Inline Comment Tile ────────────────────

class _InlineCommentTile extends ConsumerWidget {
  final Comment comment;
  final String postId;
  final String postAuthorId;
  final ScribesColors colors;

  const _InlineCommentTile({
    required this.comment,
    required this.postId,
    required this.postAuthorId,
    required this.colors,
  });

  String _formatTimeAgo(DateTime createdAt) {
    final diff = DateTime.now().toUtc().difference(createdAt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  void _showCommentActions(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;
    if (comment.isHidden || comment.isDeleted) return;

    final isCommentAuthor = currentUser.id == comment.authorId;
    final isPostAuthor = currentUser.id == postAuthorId;

    if (!isCommentAuthor && !isPostAuthor) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (isCommentAuthor)
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: colors.orange,
                    size: 22,
                  ),
                  title: Text(
                    'Delete my comment',
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.orange,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(postCommentsProvider(postId).notifier)
                        .deleteComment(comment.id);
                  },
                ),
              if (isPostAuthor && !isCommentAuthor)
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedViewOff,
                    color: colors.primaryText,
                    size: 22,
                  ),
                  title: Text(
                    'Hide this comment',
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.primaryText,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(postCommentsProvider(postId).notifier)
                        .hideComment(comment.id);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (comment.isDeleted || comment.isHidden) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedRemove01,
              size: 16,
              color: colors.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              comment.body,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    final authorAsync = ref.watch(commentAuthorProvider(comment.authorId));

    return InkWell(
      onLongPress: () => _showCommentActions(context, ref),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            authorAsync.when(
              data: (author) => GestureDetector(
                onTap: () => context.push('/users/${author.id}'),
                child: ScribesAvatar(
                  imageUrl: author.avatarUrl,
                  authorName: author.displayName,
                  radius: 17,
                ),
              ),
              loading: () => CircleAvatar(
                radius: 17,
                backgroundColor: colors.surfaceRaised,
              ),
              error: (_, _) => CircleAvatar(
                radius: 17,
                backgroundColor: colors.surfaceRaised,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  size: 18,
                  color: colors.gold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  authorAsync.when(
                    data: (author) => Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => context.push('/users/${author.id}'),
                            child: Text(
                              author.displayName,
                              style: ScribesTextStyles.labelLg.copyWith(
                                color: colors.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '@${author.handle}',
                            style: ScribesTextStyles.labelSm.copyWith(
                              color: colors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· ${_formatTimeAgo(comment.createdAt)}',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    loading: () => Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (_, _) => Text(
                      'Scribe',
                      style: ScribesTextStyles.labelLg.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    comment.body,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.primaryText,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── @Mention Suggestions Popup ─────────────────────────────

class _MentionSuggestions extends ConsumerWidget {
  final String query;
  final ScribesColors colors;
  final void Function(CommentAuthor) onSelect;

  const _MentionSuggestions({
    required this.query,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(userSearchProvider(query));

    return searchAsync.when(
      data: (users) {
        if (users.isEmpty) return const SizedBox.shrink();
        return Container(
          constraints: const BoxConstraints(maxHeight: 180),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.6),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                dense: true,
                leading: ScribesAvatar(
                  imageUrl: user.avatarUrl,
                  authorName: user.displayName,
                  radius: 15,
                ),
                title: Text(
                  user.displayName,
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: colors.primaryText,
                  ),
                ),
                subtitle: Text(
                  '@${user.handle}',
                  style: ScribesTextStyles.caption.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
                onTap: () => onSelect(user),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: ScribesLoadingIndicator(size: 18),
          ),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
