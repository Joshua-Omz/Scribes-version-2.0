import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'scribes_colors.dart';

class ScribesQuillScriptureHelper {
  /// Consistent golden italic text style for inline scripture highlights.
  static TextStyle buildScriptureTextStyle(ScribesColors colors) {
    return TextStyle(
      color: colors.gold,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      backgroundColor: colors.gold.withValues(alpha: 0.14),
      decoration: TextDecoration.underline,
      decorationColor: colors.goldMuted,
      decorationStyle: TextDecorationStyle.solid,
    );
  }

  /// Extracts all unique inline scripture references from a Delta or JSON delta list.
  static List<String> extractScriptureRefs(dynamic deltaJson) {
    if (deltaJson == null) return [];
    final List<String> refs = [];

    try {
      List<dynamic> ops = [];
      if (deltaJson is List) {
        ops = deltaJson;
      } else if (deltaJson is Map && deltaJson['ops'] is List) {
        ops = deltaJson['ops'] as List<dynamic>;
      }

      for (final op in ops) {
        if (op is Map && op.containsKey('attributes')) {
          final attrs = op['attributes'];
          if (attrs is Map && attrs.containsKey('scripture')) {
            final val = attrs['scripture']?.toString().trim();
            if (val != null && val.isNotEmpty && !refs.contains(val)) {
              refs.add(val);
            }
          }
        }
      }
    } catch (_) {}

    return refs;
  }

  /// Checks if the cursor is currently inside a scripture highlight span.
  static String? getActiveScriptureReference(QuillController controller) {
    final style = controller.getSelectionStyle();
    if (style.containsKey('scripture')) {
      final attr = style.attributes['scripture'];
      final val = attr?.value?.toString().trim();
      if (val != null && val.isNotEmpty) {
        return val;
      }
    }
    return null;
  }

  /// Applies the scripture attribute to the active selection.
  static void applyScriptureAttribute(
    QuillController controller,
    String reference,
  ) {
    controller.formatSelection(
      Attribute('scripture', AttributeScope.inline, reference.trim()),
    );
  }

  /// Removes the scripture attribute from the active selection.
  static void removeScriptureAttribute(QuillController controller) {
    controller.formatSelection(
      const Attribute('scripture', AttributeScope.inline, null),
    );
  }
}
