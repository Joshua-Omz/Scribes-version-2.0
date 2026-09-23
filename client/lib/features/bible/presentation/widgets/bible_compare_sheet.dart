import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/scribes_loading_indicator.dart';
import '../../../../core/widgets/scribes_ornament_divider.dart';
import '../../application/bible_providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final comparisonAsync = ref.watch(
      verseComparisonProvider(
        BibleVerseQuery(book: book, chapter: chapter, verse: verse),
      ),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ScribesRadius.sheet),
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
                        fontSize: 20,
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
                  icon: Icon(Icons.close, color: colors.secondaryText, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const ScribesOrnamentDivider(),
          const SizedBox(height: 8),

          // Comparison List
          Expanded(
            child: comparisonAsync.when(
              data: (comparisons) {
                if (comparisons.isEmpty) {
                  return Center(
                    child: Text(
                      'No translations available for comparison.',
                      style: TextStyle(color: colors.secondaryText),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: comparisons.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = comparisons[index];
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
                              Flexible(
                                child: Text(
                                  item.translationName,
                                  style: ScribesTextStyles.caption.copyWith(
                                    color: colors.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
}
