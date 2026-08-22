import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../main.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_radius.dart';
import '../theme/scribes_text_styles.dart';

class ScribesToast {
  static void show(
    BuildContext? context,
    String message,
    ScribesColors colors, {
    dynamic icon = Icons.check_circle_outline,
    bool isError = false,
  }) {
    Widget buildIcon() {
      if (icon is Widget) return icon;
      if (icon is IconData) {
        return Icon(
          isError ? Icons.error_outline : icon,
          color: isError ? colors.orange : colors.gold,
          size: 20,
        );
      }
      return HugeIcon(
        icon: isError ? HugeIcons.strokeRoundedAlert01 : icon,
        color: isError ? colors.orange : colors.gold,
        size: 20,
      );
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ScribesRadius.card),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: colors.glassBlur,
              sigmaY: colors.glassBlur,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.glassFill,
                borderRadius: BorderRadius.circular(ScribesRadius.card),
                border: Border.all(
                  color: isError
                      ? colors.orange.withValues(alpha: 0.65)
                      : colors.goldEdge,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildIcon(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: ScribesTextStyles.bodyMd.copyWith(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      duration: Duration(seconds: message.length > 35 ? 5 : 3),
    );

    if (context != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }
}
