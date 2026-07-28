import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';
import '../theme/scribes_text_styles.dart';


class ScribesTextField extends ConsumerWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final bool isSearchPill;

  const ScribesTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.contentPadding,
    this.autofocus = false,
    this.isSearchPill = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!.toUpperCase(),
            style: ScribesTextStyles.caption.copyWith(
              color: colors.secondaryText,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          style: ScribesTextStyles.bodyMd.copyWith(color: colors.primaryText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: ScribesTextStyles.bodyMd.copyWith(
              color: colors.secondaryText.withValues(alpha: 0.5),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            // Modern look: More border radius, very subtle border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSearchPill ? 30.0 : 16.0),
              borderSide: isSearchPill ? BorderSide.none : BorderSide(color: colors.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSearchPill ? 30.0 : 16.0),
              borderSide: isSearchPill ? BorderSide.none : BorderSide(color: colors.gold, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSearchPill ? 30.0 : 16.0),
              borderSide: BorderSide(color: colors.orange, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isSearchPill ? 30.0 : 16.0),
              borderSide: BorderSide(color: colors.orange, width: 1.5),
            ),
            filled: true,
            fillColor: isSearchPill ? colors.surfaceRaised.withValues(alpha: 0.7) : colors.surfaceRaised,
          ),
        ),
      ],
    );
  }
}
