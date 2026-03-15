import 'package:flutter/material.dart';

void main() {
  runApp(const ScribesApp());
}

class ScribesApp extends StatelessWidget {
  const ScribesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Scribes'),
        ),
      ),
    );
  }
}
