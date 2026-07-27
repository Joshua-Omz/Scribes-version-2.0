import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'scribes_bounce_button.dart';
import 'package:hugeicons/hugeicons.dart';

class ScribesDiamondFab extends ConsumerWidget {
  final VoidCallback onPressed;
  final dynamic icon;

  const ScribesDiamondFab({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return ScribesBounceButton(
      onTap: onPressed,
      child: Transform.rotate(
        angle: 45 * 3.1415927 / 180,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colors.primaryText,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.goldMuted, width: 1),
          ),
          child: Transform.rotate(
            angle: -45 * 3.1415927 / 180,
            child: HugeIcon(icon: icon,
              color: colors.surfaceRaised,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
