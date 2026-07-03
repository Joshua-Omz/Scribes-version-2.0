import 'package:flutter/material.dart';

class ReactionChip extends StatelessWidget {
  final IconData icon;
  final String count;
  final VoidCallback onTap;

  const ReactionChip({
    super.key,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine soft background color based on theme
    final isNight = theme.brightness == Brightness.dark && theme.scaffoldBackgroundColor == const Color(0xFF0A0A0A);
    final isParchment = theme.brightness == Brightness.light && theme.scaffoldBackgroundColor == const Color(0xFFF5F0E8);
    
    Color bgColor;
    Color fgColor;

    if (isNight) {
      bgColor = const Color(0xFF3D2010);
      fgColor = const Color(0xFFD4621A);
    } else if (isParchment) {
      bgColor = const Color(0xFFFAEADE);
      fgColor = const Color(0xFFC4511A);
    } else {
      // Silver
      bgColor = const Color(0xFFFAEDE4);
      fgColor = const Color(0xFFD4520A);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fgColor, size: 16),
            const SizedBox(width: 4),
            Text(
              count,
              style: theme.textTheme.labelSmall?.copyWith(color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}
