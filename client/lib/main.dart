import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/auth_gate_screen.dart';
import 'features/feed/presentation/primary_feed_screen.dart';
import 'features/explore/presentation/explore_screen.dart';
import 'features/profile/presentation/private_profile_screen.dart';
void main() {
  runApp(const ScribesApp());
}

class ScribesApp extends StatelessWidget {
  const ScribesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribes',
      theme: AppTheme.parchmentTheme,
      darkTheme: AppTheme.nightTheme,
      themeMode: ThemeMode.system,
      home: const PrivateProfileScreen(),
    );
  }
}
