import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_loading_indicator.dart';
import '../../features/bible/application/bible_providers.dart';

class ScribesScriptureQuickDialog extends ConsumerWidget {
  final String reference;
  final VoidCallback? onRemove;
  final void Function(String verseText)? onInsertIntoNote;

  const ScribesScriptureQuickDialog({
    super.key,
    required this.reference,
    this.onRemove,
    this.onInsertIntoNote,
  });

  static Future<void> show(
    BuildContext context, {
    required String reference,
    VoidCallback? onRemove,
    void Function(String verseText)? onInsertIntoNote,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ScribesScriptureQuickDialog(
        reference: reference,
        onRemove: onRemove,
        onInsertIntoNote: onInsertIntoNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<ScribesColors>()!;
    final verseAsync = ref.watch(verseLookupProvider(reference));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: colors.glassBlur,
          sigmaY: colors.glassBlur,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: colors.goldEdge, width: 0.8),
            ),
          ),
          child: 
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: bottomInset + 16,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
            
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  reference,
                                  style: ScribesTextStyles.displayMd.copyWith(
                                    color: colors.primaryText,
                                    fontSize: 20,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: colors.secondaryText,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
            
                    // Verse Body Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      child: verseAsync.when(
                        data: (res) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.fullText,
                              style: ScribesTextStyles.bodyLg.copyWith(
                                color: colors.primaryText,
                                fontFamily: 'CormorantGaramond',
                                fontSize: 19,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Berean Standard Bible, public domain',
                                    style: ScribesTextStyles.caption.copyWith(
                                      color: colors.secondaryText,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final match = RegExp(
                                      r'^(.+?)\s+(\d+):',
                                    ).firstMatch(reference);
                                    if (match != null) {
                                      final book = match.group(1)!;
                                      final chapter =
                                          int.tryParse(match.group(2)!) ?? 1;
                                      ref
                                          .read(bibleNavigationProvider.notifier)
                                          .navigateTo(book, chapter);
                                      Navigator.pop(context);
                                      context.push('/bible');
                                    }
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Read full chapter',
                                        style: ScribesTextStyles.caption.copyWith(
                                          color: colors.gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedArrowRight01,
                                        size: 12,
                                        color: colors.gold,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: ScribesLoadingIndicator(size: 24)),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Text(
                            'Scripture text unavailable offline',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.secondaryText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
            
                    // Bottom Actions
                    if (onRemove != null || onInsertIntoNote != null)
                      Row(
                        children: [
                          if (onRemove != null) ...[
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colors.secondaryText,
                                side: BorderSide(color: colors.border),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                size: 16,
                                color: colors.secondaryText,
                              ),
                              label: Text(
                                'Remove Tag',
                                style: ScribesTextStyles.labelSm.copyWith(
                                  color: colors.secondaryText,
                                ),
                              ),
                              onPressed: () {
                                onRemove!();
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (onInsertIntoNote != null)
                            Expanded(
                              child: verseAsync.maybeWhen(
                                data: (res) => OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colors.primaryText,
                                    side: BorderSide(color: colors.goldEdge, width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedDocumentAttachment,
                                    size: 16,
                                    color: colors.gold,
                                  ),
                                  label: Text(
                                    'Insert into Document',
                                    style: ScribesTextStyles.labelLg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primaryText,
                                    ),
                                  ),
                                  onPressed: () {
                                    onInsertIntoNote!(res.fullText);
                                    Navigator.pop(context);
                                  },
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
