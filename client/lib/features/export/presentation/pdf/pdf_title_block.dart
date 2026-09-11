import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/export_asset_bundle.dart';
import 'pdf_theme.dart';

pw.Widget buildPdfTitleBlock(
  ExportAssetBundle assets,
) {
  final doc = assets.document;
  final tokens = PdfThemeTokens.forTheme(assets.activeTheme);
  final formattedDate = DateFormat('MMMM d, y').format(doc.date);
  final title = doc.title;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // 1. Cover Image (if present)
      if (assets.coverImageBytes != null) ...[
        pw.Container(
          width: double.infinity,
          height: 180,
          margin: const pw.EdgeInsets.only(bottom: 18),
          decoration: pw.BoxDecoration(
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: tokens.border, width: 0.5),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 6,
            verticalRadius: 6,
            child: pw.Image(
              pw.MemoryImage(assets.coverImageBytes!),
              fit: pw.BoxFit.cover,
            ),
          ),
        ),
      ],

      // Document Type Badge if Draft or Study Note
      if (doc.documentTypeBadge != 'MANUSCRIPT') ...[
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: pw.BoxDecoration(
            color: tokens.surface,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            border: pw.Border.all(color: tokens.goldMuted, width: 0.5),
          ),
          child: pw.Text(
            doc.documentTypeBadge,
            style: pw.TextStyle(
              font: assets.dmSansBold,
              fontSize: 8.5,
              color: tokens.gold,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],

      // 2. Title
      pw.Text(
        title,
        style: pw.TextStyle(
          font: assets.cormorantBold,
          fontSize: 26,
          lineSpacing: 1.15,
          color: tokens.primaryText,
        ),
      ),
      pw.SizedBox(height: 10),

      // 3. Author & Meta Line
      pw.Row(
        children: [
          pw.Text(
            doc.authorDisplayName.isNotEmpty
                ? doc.authorDisplayName
                : '@${doc.authorHandle}',
            style: pw.TextStyle(
              font: assets.dmSansBold,
              fontSize: 10.5,
              color: tokens.primaryText,
            ),
          ),
          if (doc.authorHandle.isNotEmpty) ...[
            pw.Text(
              '  |  @${doc.authorHandle}',
              style: pw.TextStyle(
                font: assets.dmSansRegular,
                fontSize: 9.5,
                color: tokens.secondaryText,
              ),
            ),
          ],
          pw.Text(
            '  |  $formattedDate',
            style: pw.TextStyle(
              font: assets.dmSansRegular,
              fontSize: 9.5,
              color: tokens.secondaryText,
            ),
          ),
        ],
      ),

      // Sermon Source Info (if applicable)
      if (doc.sermonSource != null && doc.sermonSource!.isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Text(
          'Sermon: ${doc.sermonSource}',
          style: pw.TextStyle(
            font: assets.cormorantItalic,
            fontSize: 11,
            color: tokens.gold,
          ),
        ),
      ],

      // 4. Scripture Reference Cards
      if (doc.scriptureRefs.isNotEmpty) ...[
        pw.SizedBox(height: 14),
        ...doc.scriptureRefs.map((ref) {
          final refStr = ref.verseEnd != null && ref.verseEnd != ref.verseStart
              ? '${ref.book} ${ref.chapter}:${ref.verseStart}-${ref.verseEnd}'
              : '${ref.book} ${ref.chapter}:${ref.verseStart}';
          final verseText = assets.resolvedVerses?[refStr];

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: pw.BoxDecoration(
              color: tokens.surface,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              border: pw.Border.all(color: tokens.goldMuted, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      margin: const pw.EdgeInsets.only(right: 6),
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: tokens.gold,
                      ),
                    ),
                    pw.Text(
                      refStr,
                      style: pw.TextStyle(
                        font: assets.dmSansBold,
                        fontSize: 9.5,
                        color: tokens.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                if (verseText != null && verseText.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '"$verseText"',
                    style: pw.TextStyle(
                      font: assets.cormorantItalic,
                      fontSize: 11,
                      lineSpacing: 1.3,
                      color: tokens.primaryText,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],

      // 5. Ornate Hairline Divider
      pw.SizedBox(height: 14),
      pw.Container(
        height: 0.5,
        color: tokens.border,
      ),
      pw.SizedBox(height: 18),
    ],
  );
}
