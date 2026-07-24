import 'package:flutter/material.dart';

import '../theme/scribes_colors.dart';
import '../theme/scribes_text_styles.dart';

class ScribesToast {
  static void show(
    BuildContext context, 
    String message, 
    ScribesColors colors, {
    IconData icon = Icons.check_circle_outline,
    bool isError = false,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? colors.orange : colors.surfaceRaised,
            borderRadius: BorderRadius.circular(100), // Pill shape
            boxShadow: [
              BoxShadow(
                color: colors.primaryText.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isError ? colors.orangeSoft : colors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? Icons.error_outline : icon,
                color: isError ? colors.surface : colors.gold,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: ScribesTextStyles.bodyMd.copyWith(
                    color: isError ? colors.surface : colors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
