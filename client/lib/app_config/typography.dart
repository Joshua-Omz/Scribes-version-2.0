import 'package:flutter/material.dart';

class AppTypography {
  // Font Families
  static const String serifFont = 'Times New Roman'; // Fallback serif
  static const String sansFont = 'Arial'; // Fallback sans-serif

  // Main Headers
  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontFamily: serifFont,
    color: Colors.black87,
    height: 1.2,
  );

  static const TextStyle articleTitle = TextStyle(
    fontSize: 20,
    fontFamily: serifFont,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle articleTitleLarge = TextStyle(
    fontSize: 22,
    fontFamily: serifFont,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    height: 1.2,
  );

  // Overlines & Labels (Uppercase, letter spacing)
  static const TextStyle sectionOverline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: Colors.grey,
    fontFamily: sansFont,
  );

  static const TextStyle categoryLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.black54,
    letterSpacing: 1.0,
  );

  static const TextStyle categoryLabelBright = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.redAccent,
    letterSpacing: 1.0,
  );

  // Body & Paragraphs
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Color(0xFF757575), // Colors.grey.shade600
    height: 1.5,
  );

  // Metadata (Read time, dates)
  static const TextStyle metaData = TextStyle(
    fontSize: 12,
    color: Color(0xFF757575), // Colors.grey.shade600
  );

  static const TextStyle authorName = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle actionLink = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}
