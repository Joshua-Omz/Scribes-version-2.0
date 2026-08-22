import 'package:flutter/material.dart';

class ScribesColors extends ThemeExtension<ScribesColors> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color primaryText;
  final Color secondaryText;
  final Color gold;
  final Color goldMuted;
  final Gradient goldGradient;
  final Color orange;
  final Color orangeSoft;
  final Color border;

  // Glass tokens (§3 Glassmorphic Surface Addendum)
  final Color glassFill;
  final double glassBlur;
  final Color goldEdge;
  final Color goldEdgeActive;
  final Color glassInnerHighlight;

  const ScribesColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.primaryText,
    required this.secondaryText,
    required this.gold,
    required this.goldMuted,
    required this.goldGradient,
    required this.orange,
    required this.orangeSoft,
    required this.border,
    required this.glassFill,
    this.glassBlur = 16.0,
    required this.goldEdge,
    required this.goldEdgeActive,
    required this.glassInnerHighlight,
  });

  static const night = ScribesColors(
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1714),
    primaryText: Color(0xFFF0EDE6),
    secondaryText: Color(0xFF8A8070),
    gold: Color(0xFFC9A84C),
    goldMuted: Color(0xFF7A6230),
    goldGradient: LinearGradient(
      colors: [Color(0xFF8C4A1D), Color(0xFFC9A84C), Color(0xFFF2D479)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    orange: Color(0xFFD4621A),
    orangeSoft: Color(0xFF3D2010),
    border: Color(0x402A2520),
    glassFill: Color(0x8C111111), // rgba(17, 17, 17, 0.55)
    glassBlur: 16.0,
    goldEdge: Color(0x33C9A84C), // rgba(201, 168, 76, 0.20)
    goldEdgeActive: Color(0x66C9A84C), // rgba(201, 168, 76, 0.40)
    glassInnerHighlight: Color(0x0FFFFFFF), // rgba(255, 255, 255, 0.06)
  );

  static const parchment = ScribesColors(
    background: Color(0xFFF5F0E8),
    surface: Color(0xFFFDFAF4),
    surfaceRaised: Color(0xFFFFFFFF),
    primaryText: Color(0xFF1A1612),
    secondaryText: Color(0xFF6B6055),
    gold: Color(0xFF9A7020),
    goldMuted: Color(0xFFC8B070),
    goldGradient: LinearGradient(
      colors: [Color(0xFF8C4A1D), Color(0xFF9A7020), Color(0xFFE5C05C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    orange: Color(0xFFC4511A),
    orangeSoft: Color(0xFFFAEADE),
    border: Color(0x66DDD5C0),
    glassFill: Color(0x99FDFAF4), // rgba(253, 250, 244, 0.60)
    glassBlur: 16.0,
    goldEdge: Color(0x339A7020), // rgba(154, 112, 32, 0.20)
    goldEdgeActive: Color(0x669A7020), // rgba(154, 112, 32, 0.40)
    glassInnerHighlight: Color(0x59FFFFFF), // rgba(255, 255, 255, 0.35)
  );

  static const silver = ScribesColors(
    background: Color(0xFFF2F2F4),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFAFAFC),
    primaryText: Color(0xFF111116),
    secondaryText: Color(0xFF5E5E66),
    gold: Color(0xFFB08A2A),
    goldMuted: Color(0xFFD4C080),
    goldGradient: LinearGradient(
      colors: [Color(0xFF8C4A1D), Color(0xFFB08A2A), Color(0xFFF2D479)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    orange: Color(0xFFD4520A),
    orangeSoft: Color(0xFFFAEDE4),
    border: Color(0x66E0E0E6),
    glassFill: Color(0xA6FFFFFF), // rgba(255, 255, 255, 0.65)
    glassBlur: 16.0,
    goldEdge: Color(0x33B08A2A), // rgba(176, 138, 42, 0.20)
    goldEdgeActive: Color(0x66B08A2A), // rgba(176, 138, 42, 0.40)
    glassInnerHighlight: Color(0x80FFFFFF), // rgba(255, 255, 255, 0.50)
  );

  static const light = parchment;
  static const dark = night;

  @override
  ScribesColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? primaryText,
    Color? secondaryText,
    Color? gold,
    Color? goldMuted,
    Gradient? goldGradient,
    Color? orange,
    Color? orangeSoft,
    Color? border,
    Color? glassFill,
    double? glassBlur,
    Color? goldEdge,
    Color? goldEdgeActive,
    Color? glassInnerHighlight,
  }) {
    return ScribesColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      gold: gold ?? this.gold,
      goldMuted: goldMuted ?? this.goldMuted,
      goldGradient: goldGradient ?? this.goldGradient,
      orange: orange ?? this.orange,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      border: border ?? this.border,
      glassFill: glassFill ?? this.glassFill,
      glassBlur: glassBlur ?? this.glassBlur,
      goldEdge: goldEdge ?? this.goldEdge,
      goldEdgeActive: goldEdgeActive ?? this.goldEdgeActive,
      glassInnerHighlight: glassInnerHighlight ?? this.glassInnerHighlight,
    );
  }

  @override
  ScribesColors lerp(ThemeExtension<ScribesColors>? other, double t) {
    return this;
  }
}
