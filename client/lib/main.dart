import 'package:flutter/material.dart';
import 'app_config/theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ScribesApp());
}

class ScribesApp extends StatelessWidget {
  const ScribesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribes 2.0',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Will switch based on device settings
      home: const HomeScreen(),
    );
  }
}
