import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Headings & Titles: Cormorant Garamond
  static TextStyle get displayXl => GoogleFonts.cormorantGaramond(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    height: 1.1,
    letterSpacing: 0.04,
  );

  static TextStyle get displayLg => GoogleFonts.cormorantGaramond(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: 0.02,
  );

  static TextStyle get displaySmall => GoogleFonts.cormorantGaramond(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.02,
  );

  // Body & UI: DM Sans
  static TextStyle get bodyLg => GoogleFonts.dmSans(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMd => GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get labelLg => GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
  );

  static TextStyle get labelSm => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05,
  );

  static TextStyle get caption =>
      GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w400);
}
