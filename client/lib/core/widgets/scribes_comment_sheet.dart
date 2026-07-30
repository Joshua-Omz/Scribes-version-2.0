import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/widgets/scribes_error_state.dart';
import 'dart:async';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import 'scribes_shimmer.dart';
import 'scribes_text_field.dart';
import 'scribes_toast.dart';
import 'scribes_avatar.dart';
import 'scribes_empty_state.dart';
import '../../features/social/application/post_social_providers.dart';
import '../../features/social/application/user_lookup_provider.dart';
import '../../features/social/domain/comment.dart';
import '../../features/social/domain/comment_author.dart';
import '../../features/auth/application/auth_notifier.dart';
import 'package:scribes/features/messages/presentation/widgets/dm_request_modal.dart';
import '../../features/messages/data/message_repository.dart';

class ScribesCommentSheet extends ConsumerStatefulWidget {
  final String postId;
  final String? postAuthorId;

  const ScribesCommentSheet({
    super.key,
    required this.postId,
    this.postAuthorId,
  });

  static Future<void> show(
    BuildContext context, {
    required String postId,
    String? postAuthorId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ScribesCommentSheet(postId: postId, postAuthorId: postAuthorId),
    );
  }

  @override
  ConsumerState<ScribesCommentSheet> createState() =>
      _ScribesCommentSheetState();
}

class _ScribesCommentSheetState extends ConsumerState<ScribesCommentSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  final List<String> _mentionedUserIds = [];
  Timer? _debounceTimer;
  String? _activeMentionQuery;
  bool _showMentionOverlay = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _commentController.removeListener(_onTextChanged);
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Detects @mention patterns in the text as the user types.
  void _onTextChanged() {
    final text = _commentController.text;
    final cursorPos = _commentController.selection.baseOffset;

    if (cursorPos < 0 || cursorPos > text.length) {
      _dismissMentionOverlay();
      return;
    }

    // Walk backwards from cursor to find an unfinished @mention
    final textBeforeCursor = text.substring(0, cursorPos);
    final lastAtIndex = textBeforeCursor.lastIndexOf('@');

    if (lastAtIndex < 0) {
      _dismissMentionOverlay();
      return;
    }

    // The @ must be at start of text or preceded by a space
    if (lastAtIndex > 0 && textBeforeCursor[lastAtIndex - 1] != ' ') {
      _dismissMentionOverlay();
      return;
    }

    final query = textBeforeCursor.substring(lastAtIndex + 1);

    // If the query contains a space, the mention is "closed" — user moved on
    if (query.contains(' ')) {
      _dismissMentionOverlay();
      return;
    }

    if (query.isEmpty) {
      _dismissMentionOverlay();
      return;
    }

    // Debounce the search by 300ms
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
      offset: lastAtIndex + user.handle.length + 2, // +2 for @ and space
    );

    _mentionedUserIds.add(user.id);
    _dismissMentionOverlay();
  }

  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    await ref
        .read(postCommentsProvider(widget.postId).notifier)
        .addComment(
          body,
          _mentionedUserIds.toSet().toList(), // Deduplicate
        );
    _commentController.clear();
    _mentionedUserIds.clear();
  }

  void _showCommentActions(
    BuildContext context,
    Comment comment,
    ScribesColors colors,
  ) {
    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;

    // Don't show actions on hidden or deleted comments
    if (comment.isHidden || comment.isDeleted) return;

    final isCommentAuthor = currentUser.id == comment.authorId;
    final isPostAuthor =
        widget.postAuthorId != null && currentUser.id == widget.postAuthorId;

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
              // Drag handle
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
                _buildActionTile(
                  colors: colors,
                  icon: HugeIcons.strokeRoundedDelete02,
                  label: 'Delete my comment',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(postCommentsProvider(widget.postId).notifier)
                        .deleteComment(comment.id);
                  },
                ),

              if (isPostAuthor && !isCommentAuthor)
                _buildActionTile(
                  colors: colors,
                  icon: HugeIcons.strokeRoundedViewOff,
                  label: 'Hide this comment',
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(postCommentsProvider(widget.postId).notifier)
                        .hideComment(comment.id);
                  },
                ),

              _buildActionTile(
                colors: colors,
                icon: HugeIcons.strokeRoundedMail01,
                label: 'Reply via DM',
                onTap: () {
                  Navigator.pop(ctx);
                  _showReplyViaDMDialog(context, comment, colors);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showReplyViaDMDialog(BuildContext context, Comment comment, ScribesColors colors) {
    final controller = TextEditingController(text: 'Replying to your comment: "${comment.body}"\n\n');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Reply via DM', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText, fontSize: 20)),
        content: ScribesTextField(
          controller: controller,
          maxLines: 4,
          minLines: 4,
          hintText: 'Type your message...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.gold, elevation: 0),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(ctx);
                try {
                  await ref.read(messageRepositoryProvider).sendRequest(comment.authorId, text);
                  if (context.mounted) {
                    ScribesToast.show(context, 'Message request sent', colors, icon: HugeIcons.strokeRoundedCheckmarkBadge01);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScribesToast.show(context, 'Failed to send message', colors, icon: HugeIcons.strokeRoundedAlert01);
                  }
                }
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required ScribesColors colors,
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colors.orange : colors.primaryText;
    return ListTile(
      leading: HugeIcon(icon: icon, color: color, size: 22),
      title: Text(
        label,
        style: ScribesTextStyles.bodyMd.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final _ = MediaQuery.of(context).viewInsets.bottom;
    final commentsState = ref.watch(postCommentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom - 40,
            ),
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
            ),
            child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thoughts',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colors.border),

            // Comments List
            Expanded(
              child: commentsState.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Center(
                      child: ScribesEmptyState(
                        icon: HugeIcons.strokeRoundedMessage01,
                        title: 'No thoughts yet',
                        subtitle: 'Be the first to share your thoughts!',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(postCommentsProvider(widget.postId));
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: colors.border),
                      ),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _CommentTile(
                          comment: comment,
                          colors: colors,
                          onLongPress: () =>
                              _showCommentActions(context, comment, colors),
                        );
                      },
                    ),
                  );
                },
                loading: () => ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: 4,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, color: colors.border),
                  ),
                  itemBuilder: (context, index) => ScribesShimmer(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.surfaceRaised,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: 100,
                                color: colors.surfaceRaised,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 14,
                                width: double.infinity,
                                color: colors.surfaceRaised,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 14,
                                width: 150,
                                color: colors.surfaceRaised,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stack) => ScribesErrorState(
                  title: 'Failed to load comments',
                  subtitle: error.toString(),
                  onRetry: () => ref.refresh(postCommentsProvider(widget.postId)),
                ),
              ),
            ),

            // @mention autocomplete overlay + Input Area
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mention suggestions
                if (_showMentionOverlay && _activeMentionQuery != null)
                  _MentionSuggestions(
                    query: _activeMentionQuery!,
                    colors: colors,
                    onSelect: _insertMention,
                  ),

                // Input Area
                Container(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 32,
                  ),
                  decoration: BoxDecoration(
                    color: colors.background,
                    border: Border(top: BorderSide(color: colors.border)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ScribesTextField(
                          controller: _commentController,
                          focusNode: _focusNode,
                          maxLines: 4,
                          minLines: 1,
                          hintText: 'Share your thoughts...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: colors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: HugeIcon(icon: HugeIcons.strokeRoundedSent,
                            color: colors.surfaceRaised,
                          ),
                          onPressed: _submitComment,
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
    ),
  ));
  }
}

// ─── Comment Tile ────────────────────────────────────────

/// Individual comment tile that resolves its own author info via provider.
class _CommentTile extends ConsumerWidget {
  final Comment comment;
  final ScribesColors colors;
  final VoidCallback onLongPress;

  const _CommentTile({
    required this.comment,
    required this.colors,
    required this.onLongPress,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Tombstone: deleted comments
    if (comment.isDeleted) {
      return _buildTombstone(comment.body, colors);
    }

    // Hidden: moderated by post author
    if (comment.isHidden) {
      return _buildTombstone(comment.body, colors);
    }

    // Normal comment — resolve author info
    final authorAsync = ref.watch(commentAuthorProvider(comment.authorId));

    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          authorAsync.when(
            data: (author) =>
                ScribesAvatar(authorName: author.displayName, radius: 18),
            loading: () =>
                CircleAvatar(radius: 18, backgroundColor: colors.surfaceRaised),
            error: (_, _) => CircleAvatar(
              radius: 18,
              backgroundColor: colors.surfaceRaised,
              child: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: 20, color: colors.gold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    authorAsync.when(
                      data: (author) => Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                author.displayName,
                                style: ScribesTextStyles.labelLg.copyWith(
                                  color: colors.primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '@${author.handle}',
                              style: ScribesTextStyles.labelSm.copyWith(
                                color: colors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () => Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      error: (err, stackTrace) => Text(
                        'Unknown',
                        style: ScribesTextStyles.labelLg.copyWith(
                          color: colors.secondaryText,
                        ),
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
                const SizedBox(height: 4),
                Text(
                  comment.body,
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                // Actions row
                Row(
                  children: [
                    // Reply button (placeholder logic for now)
                    InkWell(
                      onTap: () {
                        // TODO: trigger reply
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Text(
                          'Reply',
                          style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Message button
                    Consumer(
                      builder: (context, ref, child) {
                        final currentUserId = ref.watch(authProvider).value?.id;
                        if (currentUserId == comment.authorId) {
                          return const SizedBox.shrink(); // Can't message self
                        }
                        return InkWell(
                          onTap: () {
                            DmRequestModal.show(context, comment.authorId);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                            child: Row(
                              children: [
                                HugeIcon(icon: HugeIcons.strokeRoundedMail01, size: 14, color: colors.secondaryText),
                                const SizedBox(width: 4),
                                Text(
                                  'Message',
                                  style: ScribesTextStyles.labelLg.copyWith(color: colors.secondaryText),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTombstone(String maskedBody, ScribesColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedRemove01,
            size: 16,
            color: colors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Text(
            maskedBody,
            style: ScribesTextStyles.bodyMd.copyWith(
              color: colors.secondaryText.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── @Mention Suggestions ───────────────────────────────

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
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            border: Border(
              top: BorderSide(color: colors.border),
              bottom: BorderSide(color: colors.border),
            ),
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
                  authorName: user.displayName,
                  radius: 16,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.gold,
            ),
          ),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
