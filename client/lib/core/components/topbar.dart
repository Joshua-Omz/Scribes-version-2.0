import 'package:flutter/material.dart';

enum TopBlock {message , feeds , compose ,notes, setting , profile, explore}

class TopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final SearchController controller;
  final String title;

  const TopBar({
    super.key,
    required this.title,
    this.onMenuTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context){
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical:  8.0),
      ),
    );
  }
}
