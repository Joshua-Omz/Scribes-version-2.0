import 'package:flutter/material.dart';

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Topics', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Topic Selection Scaffold')),
    );
  }
}
