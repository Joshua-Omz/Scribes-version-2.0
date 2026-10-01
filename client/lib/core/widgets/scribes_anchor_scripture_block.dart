import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scribes/core/theme/scribes_colors.dart';
import 'package:scribes/core/theme/scribes_text_styles.dart';
import 'package:scribes/core/theme/scribes_radius.dart';
import 'package:scribes/core/theme/theme_provider.dart';
import 'package:hugeicons/hugeicons.dart';

/// A prominent, distinct block used exclusively for the "Anchor Scripture"
/// at the top of a Post Detail screen.
/// 
/// Unlike inline ScribesScriptureChips which are small and contextual, 
/// this block is designed to feature the primary text of the sermon or reflection.
class ScribesAnchorScriptureBlock extends ConsumerWidget {
  final String reference; // e.g. "John 1:1-5"
  final String text;      // The actual resolved verse text from local SQLite
  final String translation; // e.g. "BSB"

  const ScribesAnchorScriptureBlock({
    super.key,
    required this.reference,
    required this.text,
    required this.translation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(ScribesRadius.card),
        border: Border.all(
          color: colors.goldEdge.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.background.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Reference
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedBookOpen01,
                color: colors.gold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                reference,
                style: ScribesTextStyles.labelLg.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Attribution Guarantee (Per Invariants)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  translation,
                  style: ScribesTextStyles.caption.copyWith(
                    color: colors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // The actual scripture text
          Text(
            text,
            style: ScribesTextStyles.displayMd.copyWith(
              color: colors.primaryText,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
