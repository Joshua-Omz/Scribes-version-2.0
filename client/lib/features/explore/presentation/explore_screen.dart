import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Explore Scaffold')),
    );
  }
}
