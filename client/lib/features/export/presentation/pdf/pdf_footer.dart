import 'package:pdf/widgets.dart' as pw;

import '../../domain/export_asset_bundle.dart';
import 'pdf_theme.dart';

pw.Widget buildPdfFooter(
  pw.Context context,
  ExportAssetBundle assets,
) {
  final tokens = PdfThemeTokens.forTheme(assets.activeTheme);
  final isLastPage = context.pageNumber == context.pagesCount;

  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 16),
    child: pw.Column(
      children: [
        pw.Container(
          height: 0.5,
          color: tokens.border,
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              isLastPage
                  ? 'Preserved in Scribes | Berean Standard Bible (BSB)'
                  : 'Scribes Manuscript',
              style: pw.TextStyle(
                font: assets.dmSansRegular,
                fontSize: 8,
                color: tokens.secondaryText,
              ),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                font: assets.dmSansRegular,
                fontSize: 8,
                color: tokens.secondaryText,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
