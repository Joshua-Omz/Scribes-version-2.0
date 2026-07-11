import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';
import 'scribes_loading_indicator.dart';
import '../../features/social/application/post_social_providers.dart';

class ScribesCommentSheet extends ConsumerStatefulWidget {
  final String postId;

  const ScribesCommentSheet({
    super.key,
    required this.postId,
  });

  static Future<void> show(BuildContext context, {required String postId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScribesCommentSheet(postId: postId),
    );
  }

  @override
  ConsumerState<ScribesCommentSheet> createState() => _ScribesCommentSheetState();
}

class _ScribesCommentSheetState extends ConsumerState<ScribesCommentSheet> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    await ref.read(postCommentsProvider(widget.postId).notifier).addComment(body, []);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final commentsState = ref.watch(postCommentsProvider(widget.postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Take up 75% of screen
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
                    child: Text('No thoughts yet. Share yours!', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
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
                      return _buildComment(colors, comment);
                    },
                  ),
                );
              },
              loading: () => const Center(child: ScribesLoadingIndicator()),
              error: (err, stack) => Center(child: Text('Failed to load comments.', style: TextStyle(color: colors.primaryText))),
            ),
          ),
          
          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: bottomPadding > 0 ? bottomPadding + 12 : 32,
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
                      maxLines: 4,
                      minLines: 1,
                      style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  margin: const EdgeInsets.only(bottom: 2), // Align visually with text field
                  decoration: BoxDecoration(
                    color: colors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_upward, color: colors.surfaceRaised),
                    onPressed: _submitComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(ScribesColors colors, dynamic comment) {
    // Assuming Comment has author, created_at, and body.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: colors.surfaceRaised,
          child: Icon(Icons.person_outline, size: 20, color: colors.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(comment.author?.displayName ?? 'Anonymous', style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
                  const SizedBox(width: 8),
                  Text('@${comment.author?.handle ?? 'unknown'}', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
                  const SizedBox(width: 8),
                  // Text(comment.createdAt.toString(), style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)), // format this better
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.body,
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
