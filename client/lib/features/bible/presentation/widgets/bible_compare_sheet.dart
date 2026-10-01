import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_colors.dart';
import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/scribes_loading_indicator.dart';
import '../../../../core/widgets/scribes_ornament_divider.dart';
import '../../application/bible_providers.dart';
import '../../domain/bible_models.dart';
import 'bible_translations_sheet.dart';

class BibleCompareSheet extends ConsumerWidget {
  final String book;
  final int chapter;
  final int verse;

  const BibleCompareSheet({
    super.key,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _promptDownload(
    BuildContext context,
    WidgetRef ref,
    BibleTranslation translation,
    ScribesColors colors,
  ) {
    final sizeStr = _formatBytes(
      translation.compressedBytes > 0
          ? translation.compressedBytes
          : translation.fileSizeBytes,
    );
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          side: BorderSide(color: colors.border.withValues(alpha: 0.6)),
        ),
        title: Text(
          'Download ${translation.name}?',
          style: ScribesTextStyles.displayMd.copyWith(
            color: colors.primaryText,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Download "${translation.code}" (${sizeStr.isNotEmpty ? sizeStr : "approx. 4MB"}) for offline parallel comparison.',
          style: ScribesTextStyles.bodyMd.copyWith(
            color: colors.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.gold,
              foregroundColor: colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ScribesRadius.button),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Download', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).then((confirm) {
      if (confirm == true) {
        ref
            .read(comparisonSelectedTranslationsProvider.notifier)
            .addTranslation(translation.code);
        ref
            .read(bibleDownloadNotifierProvider.notifier)
            .downloadTranslation(translation);
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final selectedTranslations =
        ref.watch(comparisonSelectedTranslationsProvider);
    final translationsAsync = ref.watch(bibleTranslationsProvider);
    final downloadStates = ref.watch(bibleDownloadNotifierProvider);

    final comparisonAsync = ref.watch(
      verseComparisonProvider(
        BibleVerseQuery(
          book: book,
          chapter: chapter,
          verse: verse,
          translations: selectedTranslations,
        ),
      ),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$book $chapter:$verse',
                      style: ScribesTextStyles.displayMd.copyWith(
                        color: colors.primaryText,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Parallel Translation Comparison',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: colors.secondaryText,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const ScribesOrnamentDivider(),

          // Translation Selector Row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TRANSLATIONS TO COMPARE',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    InkWell(
                      onTap: () => BibleTranslationsSheet.show(context, colors),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedSettings01,
                              color: colors.secondaryText,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Manage Downloads',
                              style: ScribesTextStyles.caption.copyWith(
                                color: colors.secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                translationsAsync.when(
                  data: (translations) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: translations.map((t) {
                          final isSelected =
                              selectedTranslations.contains(t.code);
                          final isDownloaded = t.isBundled || t.isDownloaded;
                          final downloadState = downloadStates[t.code];
                          final isDownloading =
                              downloadState?.isDownloading ?? false;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              selected: isSelected,
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    t.code,
                                    style: ScribesTextStyles.labelSm.copyWith(
                                      color: isSelected
                                          ? (isDownloaded
                                              ? colors.gold
                                              : colors.orange)
                                          : colors.primaryText,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  if (!isDownloaded && !isDownloading) ...[
                                    const SizedBox(width: 4),
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedDownload04,
                                      color: isSelected
                                          ? colors.orange
                                          : colors.secondaryText.withValues(
                                              alpha: 0.6,
                                            ),
                                      size: 12,
                                    ),
                                  ],
                                  if (isDownloading) ...[
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          colors.gold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              selectedColor:
                                  colors.gold.withValues(alpha: 0.15),
                              backgroundColor: colors.surfaceRaised,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  ScribesRadius.chip,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? colors.gold.withValues(alpha: 0.7)
                                      : colors.border.withValues(alpha: 0.5),
                                  width: isSelected ? 1.0 : 0.5,
                                ),
                              ),
                              showCheckmark: isSelected && isDownloaded,
                              checkmarkColor: colors.gold,
                              onSelected: (_) {
                                if (isDownloaded) {
                                  if (isSelected &&
                                      selectedTranslations.length <= 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'At least one translation must be selected.',
                                        ),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  ref
                                      .read(
                                        comparisonSelectedTranslationsProvider
                                            .notifier,
                                      )
                                      .toggleTranslation(t.code);
                                } else {
                                  _promptDownload(context, ref, t, colors);
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 32,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          Divider(
            color: colors.border.withValues(alpha: 0.4),
            height: 1,
            thickness: 0.5,
          ),

          // Comparison List
          Expanded(
            child: comparisonAsync.when(
              data: (comparisons) {
                final allTranslations = translationsAsync.value ?? [];

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: selectedTranslations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final code = selectedTranslations[index];
                    final match = comparisons
                        .where(
                          (c) =>
                              c.translation.toUpperCase() == code.toUpperCase(),
                        )
                        .firstOrNull;

                    if (match != null) {
                      return _buildComparisonCard(context, match, colors);
                    }

                    // Check if translation is currently downloading or not installed
                    final t = allTranslations
                        .where(
                          (tr) =>
                              tr.code.toUpperCase() == code.toUpperCase(),
                        )
                        .firstOrNull;
                    final downloadState = downloadStates[code.toUpperCase()];

                    if (downloadState?.isDownloading ?? false) {
                      return _buildDownloadingCard(
                        code,
                        t?.name ?? code,
                        downloadState!,
                        colors,
                      );
                    }

                    return _buildUninstalledCard(
                      context,
                      ref,
                      t,
                      code,
                      colors,
                    );
                  },
                );
              },
              loading: () => const Center(child: ScribesLoadingIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error comparing translations: $err',
                    style: TextStyle(color: colors.secondaryText),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    BibleComparisonResult item,
    ScribesColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      item.translation,
                      style: ScribesTextStyles.labelSm.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.translationName,
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCopy01,
                  color: colors.secondaryText.withValues(alpha: 0.7),
                  size: 16,
                ),
                tooltip: 'Copy verse (${item.translation})',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '"${item.text}" — ${item.reference} (${item.translation})',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Copied ${item.reference} (${item.translation}) to clipboard',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.text,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              height: 1.5,
              color: colors.primaryText,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.attribution,
            style: ScribesTextStyles.caption.copyWith(
              color: colors.secondaryText.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingCard(
    String code,
    String name,
    TranslationDownloadState downloadState,
    ScribesColors colors,
  ) {
    final pct = (downloadState.progress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.gold.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: ScribesTextStyles.labelSm.copyWith(
                    color: colors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: ScribesTextStyles.caption.copyWith(
                  color: colors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                downloadState.statusLabel,
                style: ScribesTextStyles.bodyMd.copyWith(
                  color: colors.primaryText,
                  fontSize: 13,
                ),
              ),
              Text(
                '$pct%',
                style: ScribesTextStyles.labelSm.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: downloadState.progress > 0 ? downloadState.progress : null,
              backgroundColor: colors.border.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUninstalledCard(
    BuildContext context,
    WidgetRef ref,
    BibleTranslation? translation,
    String code,
    ScribesColors colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.border.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        code,
                        style: ScribesTextStyles.labelSm.copyWith(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        translation?.name ?? code,
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Translation not installed locally for offline comparison.',
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: colors.secondaryText.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (translation != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.gold.withValues(alpha: 0.15),
                foregroundColor: colors.gold,
                elevation: 0,
                side: BorderSide(
                  color: colors.gold.withValues(alpha: 0.4),
                  width: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ScribesRadius.button),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDownload04,
                color: colors.gold,
                size: 14,
              ),
              label: const Text(
                'Download',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                _promptDownload(context, ref, translation, colors);
              },
            ),
        ],
      ),
    );
  }
}
