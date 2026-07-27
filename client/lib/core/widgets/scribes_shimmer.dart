import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme_provider.dart';

class ScribesShimmer extends ConsumerWidget {
  final Widget child;
  
  /// Whether the child is just a skeleton placeholder and should be painted over completely with the shimmer colors.
  /// If true, this just wraps the child in a Shimmer.fromColors.
  /// If false, this is typically a custom use of Shimmer.
  final bool enabled;
  final Duration period;

  const ScribesShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;

    final colors = ref.watch(themeProvider);
    
    // For skeleton loading, we typically use the surface color as the base
    // and a slightly lighter/darker color for the highlight depending on theme
    final baseColor = colors.surfaceRaised;
    // Compute a highlight color based on background luminance
    final isDark = colors.background.computeLuminance() < 0.5;
    final highlightColor = isDark 
        ? Colors.white.withValues(alpha: 0.1) 
        : Colors.black.withValues(alpha: 0.05);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: period,
      child: child,
    );
  }
}
