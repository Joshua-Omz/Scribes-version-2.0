import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'scribes_brand_logo.dart';

class ScribesEmptyState extends ConsumerWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool useBrandMark;

  const ScribesEmptyState({
    super.key,
    this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.useBrandMark = false,
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
                color: colors.surfaceRaised,
                shape: BoxShape.circle,
                border: Border.all(
                  color: (useBrandMark || icon == null)
                      ? colors.gold.withValues(alpha: 0.3)
                      : colors.border.withValues(alpha: 0.5),
                ),
              ),
              child: (useBrandMark || icon == null)
                  ? const ScribesBrandLogo(
                      variant: BrandLogoVariant.iconOnly,
                      size: 46,
                    )
                  : HugeIcon(icon: icon, size: 48, color: colors.goldMuted),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: ScribesTextStyles.displayMd.copyWith(
                color: colors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: ScribesTextStyles.bodyMd.copyWith(
                color: colors.secondaryText,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.gold,
                  foregroundColor: colors.surface,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  actionLabel!,
                  style: ScribesTextStyles.labelLg.copyWith(
                    color: colors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
