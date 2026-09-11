import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import 'scribes_bounce_button.dart';

class ScribesGlassFab extends ConsumerWidget {
  final VoidCallback onTap;
  final dynamic icon;

  const ScribesGlassFab({
    super.key,
    required this.onTap,
    this.icon = HugeIcons.strokeRoundedPlusSign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Material(
      color: Colors.transparent,
      child: ScribesBounceButton(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.surfaceRaised.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.gold.withValues(alpha: 0.75),
              width: 1.5,
            ),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              color: colors.gold,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

