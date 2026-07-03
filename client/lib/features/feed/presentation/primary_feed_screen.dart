import 'package:flutter/material.dart';

class PrimaryFeedScreen extends StatelessWidget {
  const PrimaryFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Scribes', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Primary Feed Scaffold')),
    );
  }
}
