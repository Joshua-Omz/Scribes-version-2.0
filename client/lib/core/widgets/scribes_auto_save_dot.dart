import 'package:flutter/material.dart';

enum SaveState {
  saving,
  localSaved,
  serverSaved,
  error,
}

class ScribesAutoSaveDot extends StatelessWidget {
  final SaveState state;

  const ScribesAutoSaveDot({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color dotColor;
    switch (state) {
      case SaveState.saving:
        dotColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
        break;
      case SaveState.localSaved:
        dotColor = theme.colorScheme.onSurface.withValues(alpha: 0.6); // Grey/local
        break;
      case SaveState.serverSaved:
        dotColor = theme.colorScheme.primary; // Gold
        break;
      case SaveState.error:
        dotColor = theme.colorScheme.error;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dotColor,
      ),
    );
  }
}
