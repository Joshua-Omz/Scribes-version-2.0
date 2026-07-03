import 'package:flutter/material.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Detail', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: const Center(child: Text('Note Detail Scaffold')),
    );
  }
}
