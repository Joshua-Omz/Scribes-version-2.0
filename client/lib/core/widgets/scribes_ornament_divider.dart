import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Image.asset(
            'assets/branding/cherubim_wings.png',
            width: 48,
            height: 18,
            fit: BoxFit.contain,
            cacheWidth: 96,
            color: colors.gold.withValues(alpha: 0.18),
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.low,
            excludeFromSemantics: true,
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
