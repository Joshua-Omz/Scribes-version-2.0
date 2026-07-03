import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, color: theme.colorScheme.primary, size: 64),
            const SizedBox(height: 24),
            Text(
              'Scribes',
              style: theme.textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}
