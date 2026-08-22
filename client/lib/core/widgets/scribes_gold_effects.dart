import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';

class ScribesGoldText extends ConsumerWidget {
  final String text;
  final TextStyle style;

  const ScribesGoldText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    return ShaderMask(
      shaderCallback: (bounds) {
        return colors.goldGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style),
    );
  }
}

class ScribesGoldIcon extends ConsumerWidget {
  final dynamic iconData;
  final double size;

  const ScribesGoldIcon(this.iconData, {super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    return ShaderMask(
      shaderCallback: (bounds) {
        return colors.goldGradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: iconData is IconData
          ? Icon(
              iconData as IconData,
              size: size,
              color: Colors.white, // Color is overridden by ShaderMask
            )
          : HugeIcon(icon: iconData, color: Colors.white, size: size),
    );
  }
}

class ScribesGlassyGoldContainer extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ScribesGlassyGoldContainer({
    super.key,
    required this.child,
    this.borderRadius = 12.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    // We create a semi-transparent version of the gradient for the background
    final glassGradient = LinearGradient(
      colors: colors.goldGradient.colors
          .map((c) => c.withValues(alpha: 0.15))
          .toList(),
      stops: colors.goldGradient.stops,
      begin: (colors.goldGradient as LinearGradient).begin,
      end: (colors.goldGradient as LinearGradient).end,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: glassGradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                width: 1.0,
                // In Flutter, gradients on borders require CustomPaint, so we'll use a solid
                // semi-transparent color derived from the gradient for simplicity,
                // or we can just use the first color of the gradient.
                color: colors.goldGradient.colors.first.withValues(alpha: 0.3),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
