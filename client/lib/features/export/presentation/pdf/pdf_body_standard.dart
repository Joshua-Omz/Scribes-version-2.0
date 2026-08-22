import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/export_asset_bundle.dart';
import 'pdf_theme.dart';
import 'pdf_title_block.dart';

/// Builds the standard body widgets for a PDF export by parsing Quill Delta operations.
List<pw.Widget> buildPdfStandardBody(ExportAssetBundle assets) {
  final tokens = PdfThemeTokens.forTheme(assets.activeTheme);
  final widgets = <pw.Widget>[];

  // 1. Title Block (Header on First Page)
  widgets.add(buildPdfTitleBlock(assets));

  // 2. Parse Delta and render structured PDF widgets
  final content = assets.post.content;
  final deltaOps = _extractDeltaOps(content);

  final bodyWidgets = deltaToPdfWidgets(
    ops: deltaOps,
    assets: assets,
    tokens: tokens,
  );

  widgets.addAll(bodyWidgets);
  return widgets;
}

/// Extracts a List of Delta operations from a Post content payload.
List<Map<String, dynamic>> _extractDeltaOps(dynamic content) {
  if (content == null) return [];

  if (content is Map) {
    if (content['ops'] is List) {
      return (content['ops'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (content['body'] != null) {
      return _extractDeltaOps(content['body']);
    }
  }

  if (content is List) {
    return content
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  if (content is String) {
    final trimmed = content.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        return _extractDeltaOps(decoded);
      } catch (_) {}
    }
    // Fallback: wrap raw text in a single delta insert
    return [
      {'insert': '$content\n'}
    ];
  }

  return [];
}

/// Converts a stream of Quill Delta operations into structured PDF widgets.
List<pw.Widget> deltaToPdfWidgets({
  required List<Map<String, dynamic>> ops,
  required ExportAssetBundle assets,
  required PdfThemeTokens tokens,
}) {
  final widgets = <pw.Widget>[];
  var currentSpans = <pw.InlineSpan>[];
  int orderedListCounter = 1;

  void flushLine(Map<String, dynamic>? blockAttrs) {
    if (currentSpans.isEmpty) {
      // Empty line / paragraph gap
      widgets.add(pw.SizedBox(height: 8));
      return;
    }

    final attrs = blockAttrs ?? const <String, dynamic>{};
    final header = attrs['header'];
    final isBlockquote = attrs['blockquote'] == true;
    final isCodeBlock = attrs['code-block'] == true;
    final listType = attrs['list'];
    final indentLevel = (attrs['indent'] as num?)?.toInt() ?? 0;

    // Reset ordered list counter if current line is not an ordered list
    if (listType != 'ordered') {
      orderedListCounter = 1;
    }

    if (header == 1) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.cormorantBold,
                fontSize: 18,
                color: tokens.primaryText,
              ),
            ),
          ),
        ),
      );
    } else if (header == 2) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 13, bottom: 4),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.cormorantBold,
                fontSize: 15,
                color: tokens.primaryText,
              ),
            ),
          ),
        ),
      );
    } else if (header == 3) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.cormorantBold,
                fontSize: 13,
                color: tokens.primaryText,
              ),
            ),
          ),
        ),
      );
    } else if (isBlockquote) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 6),
          padding: const pw.EdgeInsets.only(left: 12, top: 4, bottom: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(color: tokens.gold, width: 2.0),
            ),
          ),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.cormorantItalic,
                fontSize: 12.5,
                lineSpacing: 1.4,
                color: tokens.primaryText,
              ),
            ),
          ),
        ),
      );
    } else if (isCodeBlock) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 4),
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: tokens.surface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: tokens.border, width: 0.5),
          ),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.dmSansRegular,
                fontSize: 10,
                lineSpacing: 1.3,
                color: tokens.secondaryText,
              ),
            ),
          ),
        ),
      );
    } else if (listType == 'bullet' || listType == 'ordered') {
      final prefix = listType == 'ordered'
          ? '${orderedListCounter++}. '
          : '• ';

      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(
            left: 12.0 + (indentLevel * 14.0),
            bottom: 4,
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: listType == 'ordered' ? 18 : 12,
                child: pw.Text(
                  prefix,
                  style: pw.TextStyle(
                    font: assets.dmSansBold,
                    fontSize: 11,
                    color: tokens.gold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: currentSpans,
                    style: pw.TextStyle(
                      font: assets.cormorantRegular,
                      fontSize: 12,
                      lineSpacing: 1.4,
                      color: tokens.primaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Standard paragraph
      final leftPadding = indentLevel > 0 ? indentLevel * 14.0 : 0.0;
      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(left: leftPadding, bottom: 8),
          child: pw.RichText(
            text: pw.TextSpan(
              children: currentSpans,
              style: pw.TextStyle(
                font: assets.cormorantRegular,
                fontSize: 12.5,
                lineSpacing: 1.5,
                color: tokens.primaryText,
              ),
            ),
          ),
        ),
      );
    }

    currentSpans = <pw.InlineSpan>[];
  }

  void renderDivider() {
    if (currentSpans.isNotEmpty) {
      flushLine(null);
    }
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.symmetric(vertical: 12),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                height: 0.5,
                color: tokens.goldMuted.shade(0.5),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8),
              child: pw.Container(
                width: 4,
                height: 4,
                decoration: pw.BoxDecoration(
                  color: tokens.gold,
                  shape: pw.BoxShape.circle,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 0.5,
                color: tokens.goldMuted.shade(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  for (final op in ops) {
    final insert = op['insert'];
    final attrs = (op['attributes'] as Map?)?.cast<String, dynamic>() ?? {};

    if (insert is Map) {
      // Embed Block handling (e.g. divider, hr, image)
      if (insert.containsKey('divider') ||
          insert.containsKey('hr') ||
          insert.containsKey('thematicBreak')) {
        renderDivider();
      }
      continue;
    }

    if (insert is! String) continue;

    // Check for explicit text-based divider conventions (e.g., '---', '───', '***')
    final trimmed = insert.trim();
    if ((trimmed == '---' || trimmed == '───' || trimmed == '***' || trimmed == '___') &&
        currentSpans.isEmpty) {
      renderDivider();
      continue;
    }

    // Process text stream by splitting at newlines
    final lines = insert.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final lineText = lines[i];

      if (lineText.isNotEmpty) {
        currentSpans.add(
          _buildStyledSpan(
            text: lineText,
            attrs: attrs,
            assets: assets,
            tokens: tokens,
          ),
        );
      }

      // If this is not the last split segment, we encountered a '\n'
      if (i < lines.length - 1) {
        flushLine(attrs);
      }
    }
  }

  // Flush any trailing line content without newline
  if (currentSpans.isNotEmpty) {
    flushLine(null);
  }

  return widgets;
}

/// Builds an individual styled `pw.InlineSpan` based on inline Delta attributes.
pw.InlineSpan _buildStyledSpan({
  required String text,
  required Map<String, dynamic> attrs,
  required ExportAssetBundle assets,
  required PdfThemeTokens tokens,
}) {
  final isBold = attrs['bold'] == true;
  final isItalic = attrs['italic'] == true;
  final isUnderline = attrs['underline'] == true;
  final isStrike = attrs['strike'] == true;
  final isScripture = attrs.containsKey('scripture');
  final isCode = attrs['code'] == true;

  pw.Font selectedFont;
  if (isCode) {
    selectedFont = assets.dmSansRegular;
  } else if (isScripture) {
    selectedFont = assets.cormorantItalic;
  } else if (isBold && isItalic) {
    selectedFont = assets.cormorantBold;
  } else if (isBold) {
    selectedFont = assets.cormorantBold;
  } else if (isItalic) {
    selectedFont = assets.cormorantItalic;
  } else {
    selectedFont = assets.cormorantRegular;
  }

  var textColor = tokens.primaryText;
  if (isScripture) {
    textColor = tokens.gold;
  } else if (isCode) {
    textColor = tokens.secondaryText;
  }

  return pw.TextSpan(
    text: text,
    style: pw.TextStyle(
      font: selectedFont,
      color: textColor,
      decoration: isUnderline
          ? pw.TextDecoration.underline
          : (isStrike ? pw.TextDecoration.lineThrough : pw.TextDecoration.none),
      decorationColor: isScripture ? tokens.gold : tokens.primaryText,
    ),
  );
}

