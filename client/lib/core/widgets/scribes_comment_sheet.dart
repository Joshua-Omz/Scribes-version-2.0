import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import 'scribes_loading_indicator.dart';
import 'scribes_avatar.dart';
import '../../features/social/application/post_social_providers.dart';
import '../../features/social/application/user_lookup_provider.dart';
import '../../features/social/domain/comment.dart';
import '../../features/social/domain/comment_author.dart';
import '../../features/auth/application/auth_notifier.dart';

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
                  icon: Icons.delete_outline,
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
                  icon: Icons.visibility_off_outlined,
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
                icon: Icons.mail_outline,
                label: 'Reply via DM',
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Direct messaging is coming soon.'),
                      backgroundColor: colors.surfaceRaised,
                    ),
                  );
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required ScribesColors colors,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? colors.orange : colors.primaryText;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
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
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final commentsState = ref.watch(postCommentsProvider(widget.postId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thoughts',
                    style: ScribesTextStyles.displayMd.copyWith(
                      color: colors.primaryText,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.secondaryText),
                    onPressed: () => Navigator.pop(context),
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
                    return Center(
                      child: Text(
                        'No thoughts yet. Share yours!',
                        style: ScribesTextStyles.bodyMd.copyWith(
                          color: colors.secondaryText,
                        ),
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
                loading: () => const Center(child: ScribesLoadingIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Failed to load comments.',
                    style: TextStyle(color: colors.primaryText),
                  ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: colors.border),
                          ),
                          child: TextField(
                            controller: _commentController,
                            focusNode: _focusNode,
                            maxLines: 4,
                            minLines: 1,
                            style: ScribesTextStyles.bodyMd.copyWith(
                              color: colors.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Share your thoughts...',
                              hintStyle: ScribesTextStyles.bodyMd.copyWith(
                                color: colors.secondaryText,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
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
                          icon: Icon(
                            Icons.arrow_upward,
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
    );
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
            error: (_, __) => CircleAvatar(
              radius: 18,
              backgroundColor: colors.surfaceRaised,
              child: Icon(Icons.person_outline, size: 20, color: colors.gold),
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
                      error: (_, __) => Text(
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
          Icon(
            Icons.remove_circle_outline,
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
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
