import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Heuristically converts a line starting with "1. " or "1) "
/// into an Ordered List block (`Attribute.ol`) upon pressing Enter,
/// allowing Quill to automatically create item 2.
KeyEventResult? handleAutoNumberOnEnter(
  KeyEvent event,
  QuillController controller,
) {
  if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.enter) {
    return null;
  }

  final selection = controller.selection;
  if (!selection.isCollapsed) return null;

  final plainText = controller.document.toPlainText();
  final offset = selection.baseOffset;
  if (offset <= 0 || offset > plainText.length) return null;

  final textBefore = plainText.substring(0, offset);
  final lastNewline = textBefore.lastIndexOf('\n');
  final lineStart = lastNewline == -1 ? 0 : lastNewline + 1;
  final lineEndIdx = plainText.indexOf('\n', lineStart);
  final lineText = plainText.substring(
    lineStart,
    lineEndIdx == -1 ? plainText.length : lineEndIdx,
  );

  final match = RegExp(r'^(\s*1[\.\)]\s+)(.*)$').firstMatch(lineText);
  if (match == null) return null;

  final prefix = match.group(1)!;

  // Check if current block is already an ordered list
  final style = controller.getSelectionStyle();
  if (style.containsKey(Attribute.ol.key)) {
    return null;
  }

  // Strip prefix "1. " and apply Attribute.ol
  controller.replaceText(lineStart, prefix.length, '', null);
  controller.formatText(lineStart, 1, Attribute.ol);

  // Return null so the Enter event continues through to Quill,
  // which will split the newly formatted ordered list item and create item 2.
  return null;
}
