import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors (Light)
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color cardOffWhite = Color(0xFFF0F0F0);
  static const Color cardLightBlue = Color(0xFFF0F4F8);
  static const Color primaryText = Colors.black87;
  static const Color mutedText = Colors.grey;

  // Core Colors (Dark - Rusty Orange, Gold, Black)
  static const Color scaffoldBackgroundDark = Color(0xFF121212); // Deep Black
  static const Color cardDark = Color(0xFF1E1E1E); // Elevated Black
  static const Color primaryTextDark = Color(0xFFFDFDFD); // White-ish Text
  static const Color mutedTextDark = Color(0xFFAAAAAA); // Grey Text
  static const Color rustyOrange = Color(0xFFCC5500);
  static const Color gold = Color(0xFFE5A91E);

  // Shadow Details
  static List<BoxShadow> standardShadow = [
    BoxShadow(
      // ignore: deprecated_member_use
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: scaffoldBackground,
      primaryColor: Colors.black,
      
      // Default AppBar Style
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        titleTextStyle: TextStyle(
          color: primaryText,
          fontFamily: 'Times New Roman',
          fontStyle: FontStyle.italic,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom Navigation Bar Style
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: primaryText,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBackgroundDark, // Black
      primaryColor: gold, // Gold
      
      // Default AppBar Style
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: gold), // Gold icons
        titleTextStyle: TextStyle(
          color: gold, // Gold text for brand
          fontFamily: 'Times New Roman',
          fontStyle: FontStyle.italic,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom Navigation Bar Style
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: scaffoldBackgroundDark,
        selectedItemColor: rustyOrange, // Rusty Orange for active
        unselectedItemColor: mutedTextDark,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      cardColor: cardDark,

      colorScheme: const ColorScheme.dark().copyWith(
        primary: gold,
        secondary: rustyOrange,
        background: scaffoldBackgroundDark,
        surface: cardDark,
        onBackground: primaryTextDark,
        onSurface: primaryTextDark,
      ),
    );
  }
}
