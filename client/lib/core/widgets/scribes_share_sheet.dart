import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scribes/core/utils/share/share_service.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/features/posts/data/post_repository.dart';
import 'package:scribes/features/posts/domain/post.dart';
import 'package:scribes/features/export/presentation/export_loading_sheet.dart';

class ScribesShareSheet extends ConsumerWidget {
  final String postId;
  final Post? post;

  const ScribesShareSheet({
    super.key,
    required this.postId,
    this.post,
  });

  static Future<void> show(BuildContext context, String postId, {Post? post}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ScribesShareSheet(postId: postId, post: post),
    );
  }

  void _shareLink(BuildContext context) {
    final url = 'https://scribes.com/posts/$postId';
    shareService.shareText('Check out this post: $url');
    Navigator.of(context).pop();
  }

  void _exportAsPdf(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final parentContext = navigator.context;
    navigator.pop();

    Post? targetPost = post;
    if (targetPost == null) {
      try {
        final repo = ref.read(postRepositoryProvider);
        targetPost = await repo.getPost(postId);
      } catch (e) {
        debugPrint('Could not fetch post for PDF export: $e');
      }
    }

    if (targetPost != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (parentContext.mounted) {
          ExportLoadingSheet.show(parentContext, targetPost!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Material(
      color: colors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 48),
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
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedFile02,
                color: colors.gold,
                size: 24,
              ),
              title: Text(
                'Export Manuscript (PDF)',
                style: ScribesTextStyles.bodyLg.copyWith(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Illuminated PDF with scripture and theme styling',
                style: ScribesTextStyles.labelSm.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              onTap: () => _exportAsPdf(context, ref),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedLink01,
                color: colors.secondaryText,
                size: 24,
              ),
              title: Text(
                'Share Link',
                style: ScribesTextStyles.bodyLg.copyWith(
                  color: colors.primaryText,
                ),
              ),
              subtitle: Text(
                'Share a direct link to this post',
                style: ScribesTextStyles.labelSm.copyWith(
                  color: colors.secondaryText,
                ),
              ),
              onTap: () => _shareLink(context),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

