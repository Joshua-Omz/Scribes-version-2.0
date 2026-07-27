import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class ScribesOrnamentDivider extends ConsumerWidget {
  const ScribesOrnamentDivider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colors.border.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Opacity(
            opacity: 0.2,
            child: HugeIcon(icon: HugeIcons.strokeRoundedDiamond01, // Geometric medallion ornament
              color: colors.gold,
              size: 16,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colors.border.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}
