import 'package:flutter/material.dart';

class PrivateProfileScreen extends StatelessWidget {
  const PrivateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Private Profile Scaffold')),
    );
  }
}
