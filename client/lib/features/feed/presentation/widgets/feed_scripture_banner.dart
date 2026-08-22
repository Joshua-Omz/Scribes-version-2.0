import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/theme/scribes_radius.dart';
import '../../../../core/theme/scribes_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../bible/application/bible_providers.dart';

class FeedScriptureBanner extends ConsumerWidget {
  final String verseText;
  final String reference;
  final String book;
  final int chapter;

  const FeedScriptureBanner({
    super.key,
    this.verseText = 'Your word is a lamp to my feet and a light to my path.',
    this.reference = 'Psalm 119:105',
    this.book = 'Psalms',
    this.chapter = 119,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(color: colors.gold.withValues(alpha: 0.3), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.gold.withValues(alpha: 0.08), colors.surfaceRaised],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.gold.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSparkles,
                      color: colors.gold,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DAILY CONTEMPLATION',
                    style: ScribesTextStyles.caption.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  ref
                      .read(bibleNavigationProvider.notifier)
                      .navigateTo(book, chapter);
                  context.push('/bible?book=$book&chapter=$chapter');
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read Chapter',
                        style: ScribesTextStyles.caption.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: colors.gold),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '“$verseText”',
            style: ScribesTextStyles.bodyLg.copyWith(
              color: colors.primaryText,
              fontFamily: 'CormorantGaramond',
              fontSize: 17,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— $reference (BSB)',
              style: ScribesTextStyles.caption.copyWith(
                color: colors.secondaryText,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
