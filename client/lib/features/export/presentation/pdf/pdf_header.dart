import 'package:pdf/widgets.dart' as pw;

import '../../domain/export_asset_bundle.dart';
import 'pdf_theme.dart';
import 'pdf_watermark.dart';

pw.Widget buildPdfHeader(
  pw.Context context,
  ExportAssetBundle assets,
) {
  final tokens = PdfThemeTokens.forTheme(assets.activeTheme);
  final pageWidth = context.page.pageFormat.width;

  return pw.Stack(
    children: [
      // 1. Watermark layer repeating across every page
      buildWatermarkLayer(assets.watermarkBytes, pageWidth),

      // 2. Running top header with Scribes mark & thin rule
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SCRIBES',
                  style: pw.TextStyle(
                    font: assets.cormorantBold,
                    fontSize: 11,
                    letterSpacing: 2.0,
                    color: tokens.gold,
                  ),
                ),
                pw.Text(
                  'SACRED MANUSCRIPT ARCHIVE',
                  style: pw.TextStyle(
                    font: assets.dmSansRegular,
                    fontSize: 7.5,
                    letterSpacing: 1.2,
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              height: 0.5,
              color: tokens.border,
            ),
          ],
        ),
      ),
    ],
  );
}
