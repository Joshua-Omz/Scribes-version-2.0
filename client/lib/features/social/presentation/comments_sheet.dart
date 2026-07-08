import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/social/application/post_social_providers.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CommentsSheet(postId: postId),
      ),
    );
  }

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    
    // Extract mentions simply by looking for @words (very naive implementation)
    final words = _controller.text.split(' ');
    final mentions = words.where((w) => w.startsWith('@') && w.length > 1).map((w) => w.substring(1)).toList();

    ref.read(postCommentsProvider(widget.postId).notifier).addComment(
      _controller.text.trim(),
      mentions,
    );
    
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    final state = ref.watch(postCommentsProvider(widget.postId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Comments', style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText)),
                IconButton(
                  icon: Icon(Icons.close, color: colors.primaryText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(color: colors.border, height: 1),
          Expanded(
            child: state.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Text('No comments yet. Be the first!', style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText)),
                  );
                }

                return ListView.separated(
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => Divider(color: colors.border, height: 1),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text('User ${comment.authorId.substring(0, 8)}', style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)), // Normally we would join the author name
                      subtitle: Text(comment.body, style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText)),
                      trailing: Text(
                        comment.createdAt.toLocal().toString().split(' ')[0],
                        style: ScribesTextStyles.caption.copyWith(color: colors.secondaryText),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: colors.gold)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          Divider(color: colors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colors.gold),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: colors.gold,
                  child: IconButton(
                    icon: Icon(Icons.send, color: colors.surface, size: 20),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
