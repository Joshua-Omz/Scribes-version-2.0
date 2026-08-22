import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';
import 'scribes_bounce_button.dart';

enum ScribesButtonVariant { glassmorphic, solid, outlined }

class ScribesButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final dynamic leadingIcon;
  final dynamic trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final ScribesButtonVariant variant;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const ScribesButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.variant = ScribesButtonVariant.glassmorphic,
    this.height = 48.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
  });

  Widget _buildIcon(dynamic icon, Color color) {
    if (icon == null) return const SizedBox.shrink();
    if (icon is Widget) return icon;
    if (icon is IconData) return Icon(icon, size: 20, color: color);
    return HugeIcon(icon: icon, color: color, size: 20);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);
    final isEnabled = onPressed != null && !isLoading;

    final textColor = variant == ScribesButtonVariant.glassmorphic
        ? colors.primaryText
        : colors.surface;

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (leadingIcon != null) ...[
          _buildIcon(leadingIcon, textColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: ScribesTextStyles.labelLg.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          _buildIcon(trailingIcon, textColor),
        ],
      ],
    );

    if (variant == ScribesButtonVariant.glassmorphic) {
      return ScribesBounceButton(
        onTap: isEnabled ? onPressed! : () {},
        child: Container(
          height: height,
          width: isFullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: colors.border, width: 1.2),
                ),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      );
    }

    return ScribesBounceButton(
      onTap: isEnabled ? onPressed! : () {},
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        padding: padding,
        decoration: BoxDecoration(
          color: colors.primaryText,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: colors.border, width: 1.0),
        ),
        child: Center(child: content),
      ),
    );
  }
}
