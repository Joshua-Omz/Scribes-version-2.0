import 'package:flutter/material.dart';
import 'package:scribes/core/theme/app_theme.dart';


enum TopBlock {message , feeds , compose ,notes, setting , profile, explore}

class TopBar extends StatelessWidget implements PreferredSize{
  final VoidCallback? onMenuTap;
  final SearchController controller;
  final String title;
  final AppTheme theme = AppTheme();

  TopBar({
    super.key,
    required this.title,
    this.onMenuTap,
    required this.controller,
  });


@override
Widget build(BuildContext context){
  return SafeArea(
    child:Container(
      padding:EdgeInsets.symmetric(horizontal: 16.0, vertical:  8.0),
      color: theme.

    ),);
}
}
