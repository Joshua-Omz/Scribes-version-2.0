import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/theme_provider.dart';

enum BrandLogoVariant {
  /// Pure emblem mark (descending sacred scroll, feather quill & radiance).
  /// Ideal for AppBars, list items, avatars, and compact headers.
  iconOnly,

  /// Horizontal lockup: Emblem beside stylized 'Scribes' typography.
  /// Ideal for navigation drawers, web headers, and dialog banners.
  horizontal,

  /// Stacked lockup: Emblem centered above 'Scribes' title and sacred tagline.
  /// Ideal for splash screens, authentication gates, and about pages.
  stacked,

  /// Low-opacity background watermark for manuscript cards and empty states.
  watermark,
}

/// The centralized brand logo atom for Scribes.
///
/// Implements the "app-brand-asset-pipeline" specification:
/// 1. Theme-adaptive: Automatically tints with the active theme's gold accent.
/// 2. Zero-artifact alpha: Uses anti-aliased alpha-keyed assets.
/// 3. Standardized typography: Cormorant Garamond display serif lockup with
///    the sacred tagline "The Word is made flesh".
class ScribesBrandLogo extends ConsumerWidget {
  final BrandLogoVariant variant;
  final double? size;
  final Color? color;
  final bool showTagline;
  final VoidCallback? onTap;

  const ScribesBrandLogo({
    super.key,
    this.variant = BrandLogoVariant.iconOnly,
    this.size,
    this.color,
    this.showTagline = true,
    this.onTap,
  });

  static const String assetEmblem = 'assets/branding/scribes_emblem_transparent.png';
  static const String assetEmblemWhite = 'assets/branding/scribes_emblem_white.png';
  static const String assetEmblemDark = 'assets/branding/scribes_emblem_dark.png';
  static const String assetCombination = 'assets/branding/scribes_combination_transparent.png';
  static const String assetCombinationWhite = 'assets/branding/scribes_combination_white.png';
  static const String assetCombinationDark = 'assets/branding/scribes_combination_dark.png';
  static const String defaultTagline = 'The Word is made flesh';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final tintColor = color;

    Widget content;
    switch (variant) {
      case BrandLogoVariant.iconOnly:
        final iconSize = size ?? 24.0;
        content = Image.asset(
          assetEmblem,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          color: tintColor,
          colorBlendMode: tintColor != null ? BlendMode.srcIn : null,
          filterQuality: FilterQuality.medium,
        );
        break;

      case BrandLogoVariant.horizontal:
        final iconSize = size ?? 32.0;
        content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetEmblem,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              color: tintColor,
              colorBlendMode: tintColor != null ? BlendMode.srcIn : null,
              filterQuality: FilterQuality.medium,
            ),
            const SizedBox(width: 10),
            Text(
              'Scribes',
              style: GoogleFonts.cormorantGaramond(
                fontSize: iconSize * 0.75,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: colors.primaryText,
              ),
            ),
          ],
        );
        break;

      case BrandLogoVariant.stacked:
        final emblemSize = size ?? 96.0;
        content = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              assetEmblem,
              width: emblemSize,
              height: emblemSize,
              fit: BoxFit.contain,
              color: tintColor,
              colorBlendMode: tintColor != null ? BlendMode.srcIn : null,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(height: 14),
            Text(
              'Scribes',
              style: GoogleFonts.cormorantGaramond(
                fontSize: emblemSize * 0.38,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.primaryText,
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 6),
              Text(
                defaultTagline.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: (emblemSize * 0.11).clamp(9.0, 13.0),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.2,
                  color: colors.secondaryText,
                ),
              ),
            ],
          ],
        );
        break;

      case BrandLogoVariant.watermark:
        final wmSize = size ?? 140.0;
        content = Image.asset(
          assetEmblem,
          width: wmSize,
          height: wmSize,
          fit: BoxFit.contain,
          color: (tintColor ?? colors.gold).withValues(alpha: 0.12),
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.low,
        );
        break;
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
