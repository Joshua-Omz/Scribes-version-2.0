import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_colors.dart';
import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/widgets/scribes_ornament_divider.dart';
import '../../application/bible_providers.dart';
import '../../domain/bible_models.dart';

class BibleTranslationsSheet extends ConsumerWidget {
  final ScribesColors colors;

  const BibleTranslationsSheet({super.key, required this.colors});

  static void show(BuildContext context, ScribesColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BibleTranslationsSheet(colors: colors),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCode = ref.watch(selectedTranslationProvider);
    final translationsAsync = ref.watch(bibleTranslationsProvider);
    final downloadStates = ref.watch(bibleDownloadNotifierProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
        ),
        border: Border(
          top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.secondaryText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scripture Translations',
                          style: ScribesTextStyles.displayMd.copyWith(
                            color: colors.primaryText,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zero-API offline translations read directly from device storage.',
                          style: ScribesTextStyles.caption.copyWith(
                            color: colors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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

            const SizedBox(height: 10),
            const ScribesOrnamentDivider(),
            const SizedBox(height: 10),

            // Translations list
            Flexible(
              child: translationsAsync.when(
                data: (translations) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: translations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = translations[index];
                      final isSelected = t.code == selectedCode;
                      final downloadState = downloadStates[t.code.toUpperCase()];

                      return _TranslationCard(
                        translation: t,
                        isSelected: isSelected,
                        downloadState: downloadState,
                        colors: colors,
                        formatBytes: _formatBytes,
                        onSelect: () {
                          if (t.isDownloaded || t.isBundled) {
                            ref
                                .read(selectedTranslationProvider.notifier)
                                .setTranslation(t.code);
                            Navigator.of(context).pop();
                          }
                        },
                        onDownload: () {
                          ref
                              .read(bibleDownloadNotifierProvider.notifier)
                              .downloadTranslation(t);
                        },
                        onCancelDownload: () {
                          ref
                              .read(bibleDownloadNotifierProvider.notifier)
                              .cancelDownload(t.code);
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: colors.surfaceRaised,
                              title: Text(
                                'Remove Translation',
                                style: ScribesTextStyles.displayMd.copyWith(
                                  color: colors.primaryText,
                                  fontSize: 18,
                                ),
                              ),
                              content: Text(
                                'Remove "${t.name}" from local storage? You can re-download it at any time.',
                                style: ScribesTextStyles.bodyMd.copyWith(
                                  color: colors.secondaryText,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref
                                .read(bibleDownloadNotifierProvider.notifier)
                                .deleteTranslation(t.code);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Failed to load translations: $err',
                    style: TextStyle(color: colors.orange),
                  ),
                ),
              ),
            ),

            // Attribution Guarantee Notice
            translationsAsync.maybeWhen(
              data: (translations) {
                final current = translations.firstWhere(
                  (t) => t.code == selectedCode,
                  orElse: () => translations.first,
                );
                return Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(ScribesRadius.input),
                    border: Border.all(
                      color: colors.border.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            size: 14,
                            color: colors.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ATTRIBUTION GUARANTEE (${current.code})',
                            style: ScribesTextStyles.caption.copyWith(
                              color: colors.gold,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        current.attributionText,
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                          fontSize: 10.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final BibleTranslation translation;
  final bool isSelected;
  final TranslationDownloadState? downloadState;
  final ScribesColors colors;
  final String Function(int) formatBytes;
  final VoidCallback onSelect;
  final VoidCallback onDownload;
  final VoidCallback onCancelDownload;
  final VoidCallback onDelete;

  const _TranslationCard({
    required this.translation,
    required this.isSelected,
    required this.downloadState,
    required this.colors,
    required this.formatBytes,
    required this.onSelect,
    required this.onDownload,
    required this.onCancelDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloading = downloadState != null && downloadState!.isDownloading;
    final hasError = downloadState != null && downloadState!.hasError;
    final isAvailableLocally =
        translation.isBundled || translation.isDownloaded || (downloadState?.isCompleted ?? false);

    return InkWell(
      onTap: isAvailableLocally ? onSelect : null,
      borderRadius: BorderRadius.circular(ScribesRadius.card),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.gold.withValues(alpha: 0.08)
              : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          border: Border.all(
            color: isSelected
                ? colors.gold
                : colors.border.withValues(alpha: 0.6),
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Code badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.gold
                        : colors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? colors.gold : colors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    translation.code,
                    style: ScribesTextStyles.caption.copyWith(
                      color: isSelected ? colors.surface : colors.primaryText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Name
                Expanded(
                  child: Text(
                    translation.name,
                    style: ScribesTextStyles.bodyMd.copyWith(
                      color: colors.primaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),

                // Active checkmark
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle_rounded, color: colors.gold, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Meta row & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Metadata
                Row(
                  children: [
                    Text(
                      translation.language.toUpperCase(),
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (translation.fileSizeBytes > 0) ...[
                      Text(
                        ' · ${formatBytes(translation.fileSizeBytes)}',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.secondaryText,
                        ),
                      ),
                    ],
                  ],
                ),

                // Action area
                if (isDownloading) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        downloadState!.statusLabel,
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          color: colors.secondaryText,
                          size: 16,
                        ),
                        onPressed: onCancelDownload,
                        tooltip: 'Cancel Download',
                      ),
                    ],
                  ),
                ] else if (hasError) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed',
                        style: ScribesTextStyles.caption.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.gold,
                          side: BorderSide(color: colors.gold, width: 0.8),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ScribesRadius.button),
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 14),
                        label: const Text('Retry', style: TextStyle(fontSize: 12)),
                        onPressed: onDownload,
                      ),
                    ],
                  ),
                ] else if (translation.isBundled) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BUNDLED',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ] else if (isAvailableLocally) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'INSTALLED',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDelete02,
                          color: colors.secondaryText,
                          size: 16,
                        ),
                        tooltip: 'Delete Translation',
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryText,
                      side: BorderSide(color: colors.border, width: 0.8),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ScribesRadius.button),
                      ),
                    ),
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedDownload04,
                      color: colors.gold,
                      size: 14,
                    ),
                    label: Text(
                      'Download',
                      style: ScribesTextStyles.caption.copyWith(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: onDownload,
                  ),
                ],
              ],
            ),

            // Progress bar if downloading
            if (isDownloading) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: downloadState!.progress,
                  backgroundColor: colors.border.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                  minHeight: 4,
                ),
              ),
            ],

            // Error message snippet if error
            if (hasError && downloadState!.errorMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                downloadState!.errorMessage!,
                style: ScribesTextStyles.caption.copyWith(
                  color: Colors.redAccent,
                  fontSize: 10.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
