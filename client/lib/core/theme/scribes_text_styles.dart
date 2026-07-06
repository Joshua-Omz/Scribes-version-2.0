import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScribesTextStyles {
  static final displayXl = GoogleFonts.cormorantGaramond(
    fontSize: 40, fontWeight: FontWeight.w300,
    height: 1.15, letterSpacing: 0.4,
  );
  
  static final displayLg = GoogleFonts.cormorantGaramond(
    fontSize: 32, fontWeight: FontWeight.w600,
    height: 1.15,
  );
  
  static final displayMd = GoogleFonts.cormorantGaramond(
    fontSize: 24, fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static final bodyLg = GoogleFonts.dmSans(
    fontSize: 17,
    fontWeight: FontWeight.w400, height: 1.75,
  );
  
  static final bodyMd = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w400, height: 1.7,
  );
  
  static final labelLg = GoogleFonts.dmSans(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
  
  static final labelSm = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500, letterSpacing: 0.5,
  );
  
  static final caption = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}
