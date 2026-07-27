import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';

class ScribesErrorState extends ConsumerWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const ScribesErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.subtitle = 'Please try again later.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.orangeSoft.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: colors.orange.withValues(alpha: 0.3)),
              ),
              child: HugeIcon(icon: HugeIcons.strokeRoundedAlert01,
                size: 48,
                color: colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: ScribesTextStyles.displayMd.copyWith(color: colors.primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ScribesTextStyles.bodyMd.copyWith(color: colors.secondaryText),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primaryText,
                  side: BorderSide(color: colors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: HugeIcon(icon: HugeIcons.strokeRoundedReload, size: 18),
                label: Text(
                  'Try Again',
                  style: ScribesTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
