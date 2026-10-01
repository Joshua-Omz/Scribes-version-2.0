import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_loading_indicator.dart';
import '../../features/bible/application/bible_providers.dart';
import '../../features/bible/presentation/widgets/bible_compare_sheet.dart';

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
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Drag handle at the very top
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // 2. Header: Reference and Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reference,
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.primaryText,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                  const SizedBox(height: 12),

                  // 3. Verse Body Card (Flexible so it takes remaining space and scrolls if long)
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final selectedTranslation = ref.watch(
                                            selectedTranslationProvider,
                                          );
                                          final translationsAsync = ref.watch(
                                            bibleTranslationsProvider,
                                          );
                                          final attribution =
                                              translationsAsync.maybeWhen(
                                            data: (translations) {
                                              final match = translations
                                                  .where(
                                                    (t) =>
                                                        t.code ==
                                                        res.translation,
                                                  )
                                                  .firstOrNull;
                                              return match?.attributionText ??
                                                  '${res.translation}, public domain';
                                            },
                                            orElse: () =>
                                                '${res.translation}, public domain',
                                          );

                                          return PopupMenuButton<String>(
                                            offset: const Offset(0, 30),
                                            color: colors.surfaceRaised,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              side: BorderSide(
                                                color: colors.border,
                                              ),
                                            ),
                                            onSelected: (code) {
                                              ref
                                                  .read(
                                                    selectedTranslationProvider
                                                        .notifier,
                                                  )
                                                  .setTranslation(code);
                                            },
                                            itemBuilder: (context) {
                                              return translationsAsync.maybeWhen(
                                                data: (translations) {
                                                  return translations.map((t) {
                                                    final isSelected =
                                                        t.code ==
                                                        selectedTranslation;
                                                    return PopupMenuItem<
                                                        String>(
                                                      value: t.code,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            t.name,
                                                            style:
                                                                ScribesTextStyles
                                                                    .bodyMd
                                                                    .copyWith(
                                                              color: isSelected
                                                                  ? colors.gold
                                                                  : colors
                                                                      .primaryText,
                                                              fontWeight:
                                                                  isSelected
                                                                      ? FontWeight
                                                                          .w600
                                                                      : FontWeight
                                                                          .normal,
                                                            ),
                                                          ),
                                                          if (isSelected) ...[
                                                            const Spacer(),
                                                            Icon(
                                                              Icons.check,
                                                              color:
                                                                  colors.gold,
                                                              size: 18,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    );
                                                  }).toList();
                                                },
                                                orElse: () => [
                                                  PopupMenuItem<String>(
                                                    value: selectedTranslation,
                                                    child: Text(
                                                      selectedTranslation,
                                                      style: ScribesTextStyles
                                                          .bodyMd
                                                          .copyWith(
                                                        color: colors.gold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    attribution,
                                                    style: ScribesTextStyles
                                                        .caption
                                                        .copyWith(
                                                      color:
                                                          colors.secondaryText,
                                                      fontSize: 10,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                      decorationStyle:
                                                          TextDecorationStyle
                                                              .dotted,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 12,
                                                  color: colors.secondaryText,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
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
                                              int.tryParse(match.group(2)!) ??
                                              1;
                                          ref
                                              .read(
                                                bibleNavigationProvider
                                                    .notifier,
                                              )
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
                                            style: ScribesTextStyles.caption
                                                .copyWith(
                                              color: colors.gold,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          HugeIcon(
                                            icon: HugeIcons
                                                .strokeRoundedArrowRight01,
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
                              child: Center(
                                child: ScribesLoadingIndicator(size: 24),
                              ),
                            ),
                            error: (e, _) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'Scripture text unavailable offline',
                                style: ScribesTextStyles.caption.copyWith(
                                  color: colors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Bottom Actions (Pinned at the bottom, always visible)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.primaryText,
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedEye,
                            size: 16,
                            color: colors.gold,
                          ),
                          label: Text(
                            'Compare',
                            style: ScribesTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.primaryText,
                            ),
                          ),
                          onPressed: () {
                            final match =
                                RegExp(r'^(.+?)\s+(\d+):(\d+)').firstMatch(
                              reference,
                            );
                            if (match != null) {
                              final book = match.group(1)!;
                              final chapter =
                                  int.tryParse(match.group(2)!) ?? 1;
                              final verse = int.tryParse(match.group(3)!) ?? 1;
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                useSafeArea: true,
                                builder: (_) => BibleCompareSheet(
                                  book: book,
                                  chapter: chapter,
                                  verse: verse,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      if (onRemove != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete02,
                            size: 18,
                            color: colors.secondaryText,
                          ),
                          tooltip: 'Remove Tag',
                          onPressed: () {
                            onRemove!();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                      if (onInsertIntoNote != null) ...[
                        const SizedBox(width: 8),
                        verseAsync.maybeWhen(
                          data: (res) => IconButton(
                            style: IconButton.styleFrom(
                              side: BorderSide(
                                color: colors.goldEdge,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedDocumentAttachment,
                              size: 18,
                              color: colors.gold,
                            ),
                            tooltip: 'Insert into Document',
                            onPressed: () {
                              onInsertIntoNote!(res.fullText);
                              Navigator.pop(context);
                            },
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
