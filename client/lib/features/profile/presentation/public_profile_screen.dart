import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Public Profile Scaffold')),
    );
  }
}
