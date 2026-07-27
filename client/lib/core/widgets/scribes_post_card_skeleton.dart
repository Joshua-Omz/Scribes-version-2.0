import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import 'scribes_shimmer.dart';

class ScribesPostCardSkeleton extends ConsumerWidget {
  final double height;
  final bool showAvatar;
  final bool showImage;

  const ScribesPostCardSkeleton({
    super.key,
    this.height = 180,
    this.showAvatar = true,
    this.showImage = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showAvatar) ...[
                ScribesShimmer(
                  period: const Duration(milliseconds: 1400),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.surface,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScribesShimmer(
                      period: const Duration(milliseconds: 1600),
                      child: Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ScribesShimmer(
                      period: const Duration(milliseconds: 1800),
                      child: Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ScribesShimmer(
            period: const Duration(milliseconds: 1500),
            child: Container(
              height: 18,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ScribesShimmer(
            period: const Duration(milliseconds: 1700),
            child: Container(
              height: 14,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ScribesShimmer(
            period: const Duration(milliseconds: 1900),
            child: Container(
              height: 14,
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (showImage) ...[
            const SizedBox(height: 16),
            ScribesShimmer(
              period: const Duration(milliseconds: 2100),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
