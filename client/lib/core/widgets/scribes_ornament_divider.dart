import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ScribesOrnamentDivider extends StatelessWidget {
  const ScribesOrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            thickness: 0.5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              LucideIcons.gem, // Geometric medallion ornament
              color: theme.colorScheme.primary,
              size: 16,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            thickness: 0.5,
          ),
        ),
      ],
    );
  }
}
