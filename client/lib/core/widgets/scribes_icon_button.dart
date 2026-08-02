import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';


class ScribesIconButton extends ConsumerWidget {
  final dynamic icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final bool isSelected;

  const ScribesIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
    this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final iconColor = color ?? (isSelected ? colors.primaryText : colors.secondaryText);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size),
            side: BorderSide(
              color: colors.primaryText.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size),
            splashColor: colors.gold.withValues(alpha: 0.2),
            highlightColor: colors.gold.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: HugeIcon(
                icon: icon,
                size: size,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
