import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import '../theme/scribes_colors.dart';

class ScribesCommentSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 3, // Mock data for UI presentation
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: colors.border),
              ),
              itemBuilder: (context, index) {
                return _buildMockComment(colors);
              },
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
                    onPressed: () {
                      // Submit comment
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockComment(ScribesColors colors) {
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
                  Text('Reader', style: ScribesTextStyles.labelLg.copyWith(color: colors.primaryText)),
                  const SizedBox(width: 8),
                  Text('@reader', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
                  const SizedBox(width: 8),
                  Text('2h', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'This is a wonderful insight into the text. Thank you for sharing!',
                style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
