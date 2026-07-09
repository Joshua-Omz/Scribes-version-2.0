import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScribesBadge extends ConsumerWidget {
  final String label;
  final IconData? icon;
  final bool isFilled;

  const ScribesBadge({
    super.key,
    required this.label,
    this.icon,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? colors.gold.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isFilled ? colors.gold.withValues(alpha: 0.5) : colors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isFilled ? colors.gold : colors.secondaryText,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: ScribesTextStyles.caption.copyWith(
              color: isFilled ? colors.gold : colors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
