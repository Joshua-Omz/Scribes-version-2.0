import 'package:flutter/material.dart';
import '../theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScribesIconButton extends ConsumerWidget {
  final IconData icon;
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

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size),
      splashColor: colors.gold.withValues(alpha: 0.1),
      highlightColor: colors.gold.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
