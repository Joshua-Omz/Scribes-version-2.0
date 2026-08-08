import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/utils/share/share_service.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/posts/data/post_repository.dart';

class ScribesShareSheet extends ConsumerStatefulWidget {
  final String postId;

  const ScribesShareSheet({super.key, required this.postId});

  static Future<void> show(BuildContext context, String postId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScribesShareSheet(postId: postId),
    );
  }

  @override
  ConsumerState<ScribesShareSheet> createState() => _ScribesShareSheetState();
}

class _ScribesShareSheetState extends ConsumerState<ScribesShareSheet> {
  bool _isExporting = false;

  void _shareLink() {
    // We assume a generic web domain for Scribes
    final url = 'https://scribes.com/posts/${widget.postId}';
    shareService.shareText('Check out this post: $url');
    Navigator.of(context).pop();
  }

  Future<void> _exportAs(String format) async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(postRepositoryProvider);
      final content = await repo.exportPost(widget.postId, format);

      final mimeType = format == 'md' ? 'text/markdown' : 'text/plain';
      final filename = 'scribes_post_${widget.postId}.$format';

      await shareService.exportAndShareFile(
        content: content,
        filename: filename,
        mimeType: mimeType,
        subject: 'Scribes Post Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 48),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Post',
            style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
          ),
          const SizedBox(height: 16),
          if (_isExporting)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: colors.gold),
              ),
            )
          else ...[
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedLink01, color: colors.secondaryText, size: 24),
              title: Text('Share Link', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText)),
              subtitle: Text('Share a direct link to this post', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
              onTap: _shareLink,
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedDocumentCode, color: colors.secondaryText, size: 24),
              title: Text('Export as Markdown', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText)),
              subtitle: Text('Download as .md file', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
              onTap: () => _exportAs('md'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: HugeIcon(icon: HugeIcons.strokeRoundedText, color: colors.secondaryText, size: 24),
              title: Text('Export as Plain Text', style: ScribesTextStyles.bodyLg.copyWith(color: colors.primaryText)),
              subtitle: Text('Download as .txt file', style: ScribesTextStyles.labelSm.copyWith(color: colors.secondaryText)),
              onTap: () => _exportAs('txt'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }
}
