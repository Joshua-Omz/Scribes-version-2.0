import 'package:flutter/material.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Notes List Scaffold')),
    );
  }
}
