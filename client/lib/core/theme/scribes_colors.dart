import 'package:flutter/material.dart';

class ScribesColors extends ThemeExtension<ScribesColors> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color primaryText;
  final Color secondaryText;
  final Color gold;
  final Color goldMuted;
  final Color orange;
  final Color orangeSoft;
  final Color border;

  const ScribesColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.primaryText,
    required this.secondaryText,
    required this.gold,
    required this.goldMuted,
    required this.orange,
    required this.orangeSoft,
    required this.border,
  });

  static const night = ScribesColors(
    background:    Color(0xFF0A0A0A),
    surface:       Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1714),
    primaryText:   Color(0xFFF0EDE6),
    secondaryText: Color(0xFF8A8070),
    gold:          Color(0xFFC9A84C),
    goldMuted:     Color(0xFF7A6230),
    orange:        Color(0xFFD4621A),
    orangeSoft:    Color(0xFF3D2010),
    border:        Color(0xFF2A2520),
  );

  static const parchment = ScribesColors(
    background:    Color(0xFFF5F0E8),
    surface:       Color(0xFFFDFAF4),
    surfaceRaised: Color(0xFFFFFFFF),
    primaryText:   Color(0xFF1A1612),
    secondaryText: Color(0xFF6B6055),
    gold:          Color(0xFF9A7020),
    goldMuted:     Color(0xFFC8B070),
    orange:        Color(0xFFC4511A),
    orangeSoft:    Color(0xFFFAEADE),
    border:        Color(0xFFDDD5C0),
  );

  static const silver = ScribesColors(
    background:    Color(0xFFF2F2F4),
    surface:       Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFAFAFC),
    primaryText:   Color(0xFF111116),
    secondaryText: Color(0xFF72727A),
    gold:          Color(0xFFB08A2A),
    goldMuted:     Color(0xFFD4C080),
    orange:        Color(0xFFD4520A),
    orangeSoft:    Color(0xFFFAEDE4),
    border:        Color(0xFFE0E0E6),
  );

  @override
  ScribesColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? primaryText,
    Color? secondaryText,
    Color? gold,
    Color? goldMuted,
    Color? orange,
    Color? orangeSoft,
    Color? border,
  }) {
    return ScribesColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      gold: gold ?? this.gold,
      goldMuted: goldMuted ?? this.goldMuted,
      orange: orange ?? this.orange,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      border: border ?? this.border,
    );
  }

  @override
  ScribesColors lerp(ThemeExtension<ScribesColors>? other, double t) {
    return this;
  }
}
