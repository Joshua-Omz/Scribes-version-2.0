import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_colors.dart';
import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/scribes_bounce_button.dart';
import '../../../../core/widgets/scribes_toast.dart';
import '../../data/bible_repository.dart';
import '../../domain/bible_models.dart';
import '../../domain/verse_selection.dart';
import '../../application/verse_selection_provider.dart';
import 'bible_compare_sheet.dart';

/// Contextual glass action bar displayed at the bottom of the Bible Drawer
/// whenever a contiguous range of verses is selected.
class BibleSelectionActionBar extends ConsumerWidget {
  final VerseSelection selection;
  final BibleChapter? chapter;

  const BibleSelectionActionBar({
    super.key,
    required this.selection,
    this.chapter,
  });

  void _clearSelection(WidgetRef ref) {
    ref.read(verseSelectionProvider.notifier).clear();
  }

  void _copyVerseText(BuildContext context, ScribesColors colors) {
    String textToCopy = '';
    if (chapter != null) {
      final selectedVerses = chapter!.verses.where(
        (v) => selection.contains(v.verse),
      ).toList();

      if (selectedVerses.isNotEmpty) {
        final content = selectedVerses.map((v) => v.text.trim()).join(' ');
        textToCopy = '"$content" — ${selection.displayLabel} (Berean Standard Bible)';
      }
    }

    if (textToCopy.isEmpty) {
      textToCopy = selection.displayLabel;
    }

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScribesToast.show(
      context,
      'Copied ${selection.displayLabel} to clipboard',
      colors,
      icon: HugeIcons.strokeRoundedCopy01,
    );
  }

  void _quoteInReflection(BuildContext context, WidgetRef ref) {
    final reference = selection.toReference();

    // 1. Clear ephemeral selection state
    ref.read(verseSelectionProvider.notifier).clear();

    // 2. Open Reflection Composer pre-filled with the reference via GoRouter
    context.push('/compose/reflection', extra: reference);
  }

  void _openComparison(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BibleCompareSheet(
        book: selection.book,
        chapter: selection.chapter,
        verse: selection.verseStart,
      ),
    );
  }

  Future<void> _highlightSelection(
    BuildContext context,
    WidgetRef ref,
    ScribesColors colors,
  ) async {
    final repo = ref.read(bibleRepositoryProvider);
    for (int v = selection.verseStart; v <= selection.verseEnd; v++) {
      await repo.saveHighlight(
        bookCode: selection.book,
        chapter: selection.chapter,
        verse: v,
        colorHex: '#F5A623',
      );
    }
    ref.read(verseSelectionProvider.notifier).clear();
    if (context.mounted) {
      ScribesToast.show(
        context,
        'Highlighted ${selection.displayLabel}',
        colors,
        icon: HugeIcons.strokeRoundedBookmark02,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      offset: Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        opacity: 1.0,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ScribesRadius.card + 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ScribesRadius.card + 4),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: colors.glassBlur,
                sigmaY: colors.glassBlur,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.glassFill,
                  borderRadius: BorderRadius.circular(ScribesRadius.card + 4),
                  border: Border.all(
                    color: colors.goldEdge,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Selection Label + Clear Action
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedBookOpen01,
                            color: colors.gold,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${selection.displayLabel} selected',
                            style: ScribesTextStyles.labelLg.copyWith(
                              color: colors.primaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: () => _clearSelection(ref),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              'Clear',
                              style: ScribesTextStyles.labelSm.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottom Row: Action Buttons
                    Row(
                      children: [
                        // Highlight Action
                        Expanded(
                          child: ScribesBounceButton(
                            onTap: () => _highlightSelection(context, ref, colors),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: colors.gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.button,
                                ),
                                border: Border.all(
                                  color: colors.goldEdgeActive,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedBookmark02,
                                    color: colors.gold,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Highlight',
                                    style: ScribesTextStyles.labelSm.copyWith(
                                      color: colors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Compare Action (available when single verse is selected)
                        if (selection.isSingleVerse) ...[
                          Expanded(
                            child: ScribesBounceButton(
                              onTap: () => _openComparison(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: colors.surfaceRaised.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(
                                    ScribesRadius.button,
                                  ),
                                  border: Border.all(
                                    color: colors.border.withValues(alpha: 0.7),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedView,
                                      color: colors.primaryText,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Compare',
                                      style: ScribesTextStyles.labelSm.copyWith(
                                        color: colors.primaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],

                        // Quote Action
                        Expanded(
                          child: ScribesBounceButton(
                            onTap: () => _quoteInReflection(context, ref),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.button,
                                ),
                                border: Border.all(
                                  color: colors.border.withValues(alpha: 0.7),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedQuillWrite02,
                                    color: colors.primaryText,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Quote',
                                    style: ScribesTextStyles.labelSm.copyWith(
                                      color: colors.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Copy Action
                        Expanded(
                          child: ScribesBounceButton(
                            onTap: () => _copyVerseText(context, colors),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: colors.surfaceRaised.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.button,
                                ),
                                border: Border.all(
                                  color: colors.border.withValues(alpha: 0.7),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedCopy01,
                                    color: colors.primaryText,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Copy',
                                    style: ScribesTextStyles.labelSm.copyWith(
                                      color: colors.primaryText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
