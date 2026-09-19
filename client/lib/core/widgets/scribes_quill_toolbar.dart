import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/scribes_colors.dart';
import '../theme/scribes_quill_scripture_helper.dart';
import 'scribes_scripture_selector.dart';
import 'scribes_toast.dart';

/// Centralized rich text toolbar for Scribes.
/// Guarantees that the Scripture Tag tool is placed at index 0 (very first in the row)
/// and introduces visible, elegant vertical dividers between logical formatting groups.
class ScribesQuillToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback? onTagScripture;
  final ScribesColors? colors;

  const ScribesQuillToolbar({
    super.key,
    required this.controller,
    this.onTagScripture,
    this.colors,
  });

  Widget _buildDivider(ScribesColors themeColors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      width: 1,
      height: 22,
      color: themeColors.border.withValues(alpha: 0.7),
    );
  }

  void _defaultTagScripture(BuildContext context, ScribesColors themeColors) {
    final selection = controller.selection;
    if (!selection.isCollapsed) {
      ScribesScriptureSelector.show(
        context,
        colors: themeColors,
        onSelected: (book, chapter, verseStart, verseEnd) {
          String refStr = book;
          if (chapter != null) {
            refStr += ' $chapter';
            if (verseStart != null) {
              refStr += ':$verseStart';
              if (verseEnd != null && verseEnd != verseStart) {
                refStr += '-$verseEnd';
              }
            }
          }
          ScribesQuillScriptureHelper.applyScriptureAttribute(
            controller,
            refStr,
          );
          ScribesToast.show(
            context,
            'Tagged as Scripture: $refStr',
            themeColors,
            icon: HugeIcons.strokeRoundedBookOpen01,
          );
        },
      );
    } else {
      ScribesScriptureSelector.show(
        context,
        colors: themeColors,
        onSelected: (book, chapter, verseStart, verseEnd) {
          String refStr = book;
          if (chapter != null) {
            refStr += ' $chapter';
            if (verseStart != null) {
              refStr += ':$verseStart';
              if (verseEnd != null && verseEnd != verseStart) {
                refStr += '-$verseEnd';
              }
            }
          }
          final offset = controller.selection.baseOffset >= 0
              ? controller.selection.baseOffset
              : controller.document.length - 1;
          controller.document.insert(offset, refStr);
          controller.updateSelection(
            TextSelection(
              baseOffset: offset,
              extentOffset: offset + refStr.length,
            ),
            ChangeSource.local,
          );
          ScribesQuillScriptureHelper.applyScriptureAttribute(
            controller,
            refStr,
          );
          controller.updateSelection(
            TextSelection.collapsed(
              offset: offset + refStr.length,
            ),
            ChangeSource.local,
          );
          ScribesToast.show(
            context,
            'Inserted Scripture: $refStr',
            themeColors,
            icon: HugeIcons.strokeRoundedBookOpen01,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = colors ?? Theme.of(context).extension<ScribesColors>()!;

    return Container(
      height: 50,
      width: double.infinity,
      color: themeColors.surfaceRaised,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Tool #1: Scripture Tag Tool (Strictly first in the row) ──
            Tooltip(
              message: 'Tag as Scripture',
              child: InkWell(
                onTap: onTagScripture ?? () => _defaultTagScripture(context, themeColors),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeColors.gold.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedBookOpen01,
                        size: 16,
                        color: themeColors.gold,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Scripture',
                        style: TextStyle(
                          color: themeColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _buildDivider(themeColors),

            // ── History: Undo / Redo ──
            QuillToolbarHistoryButton(
              isUndo: true,
              controller: controller,
            ),
            QuillToolbarHistoryButton(
              isUndo: false,
              controller: controller,
            ),

            _buildDivider(themeColors),

            // ── Headers: H1 / H2 ──
            QuillToolbarToggleStyleButton(
              attribute: Attribute.h1,
              controller: controller,
            ),
            QuillToolbarToggleStyleButton(
              attribute: Attribute.h2,
              controller: controller,
            ),

            _buildDivider(themeColors),

            // ── Formatting: Bold / Italic / Underline / Quote ──
            QuillToolbarToggleStyleButton(
              attribute: Attribute.bold,
              controller: controller,
            ),
            QuillToolbarToggleStyleButton(
              attribute: Attribute.italic,
              controller: controller,
            ),
            QuillToolbarToggleStyleButton(
              attribute: Attribute.underline,
              controller: controller,
            ),
            QuillToolbarToggleStyleButton(
              attribute: Attribute.blockQuote,
              controller: controller,
            ),

            _buildDivider(themeColors),

            // ── Lists: Ordered List (1.), Bullet List, Check List ──
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ol,
              controller: controller,
            ),
            QuillToolbarToggleStyleButton(
              attribute: Attribute.ul,
              controller: controller,
            ),
            QuillToolbarToggleCheckListButton(
              controller: controller,
            ),

            _buildDivider(themeColors),

            // ── Links & Indent ──
            QuillToolbarLinkStyleButton(
              controller: controller,
            ),
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: true,
            ),
            QuillToolbarIndentButton(
              controller: controller,
              isIncrease: false,
            ),
          ],
        ),
      ),
    );
  }
}
