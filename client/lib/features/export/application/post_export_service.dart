import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../posts/domain/post.dart';
import '../data/export_repository.dart';
import '../presentation/pdf/pdf_body_standard.dart';
import '../presentation/pdf/pdf_footer.dart';
import '../presentation/pdf/pdf_header.dart';
import '../presentation/pdf/pdf_theme.dart';

final postExportServiceProvider = Provider<PostExportService>((ref) {
  final repository = ref.watch(exportRepositoryProvider);
  return PostExportService(repository);
});

class PostExportService {
  final ExportRepository _repository;

  PostExportService(this._repository);

  Future<void> exportPost({
    required Post post,
    required ScribesTheme theme,
    bool preview = true,
  }) async {
    // 1. Gather Assets (Network + Fonts + BSB Verses)
    final assets = await _repository.gatherAssets(post, theme);
    final tokens = PdfThemeTokens.forTheme(theme);
    final title = post.content['title'] as String? ?? 'Untitled';

    // 2. Build Document
    final pdf = pw.Document(
      title: title,
      author: post.authorName.isNotEmpty ? post.authorName : post.authorHandle,
      creator: 'Scribes Sacred Manuscript Archive',
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
          theme: pw.ThemeData.withFont(
            base: assets.dmSansRegular,
            bold: assets.dmSansBold,
            italic: assets.cormorantItalic,
            boldItalic: assets.cormorantBold,
            fontFallback: [
              pw.Font.helvetica(),
              pw.Font.times(),
              pw.Font.zapfDingbats(),
            ],
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: tokens.background),
          ),
        ),
        header: (context) => buildPdfHeader(context, assets),
        footer: (context) => buildPdfFooter(context, assets),
        build: (context) => buildPdfStandardBody(assets),
      ),
    );

    // 3. Serialize to Bytes
    final bytes = await pdf.save();
    final filename = '${_sanitizeFilename(title)}.pdf';

    // 4. Hand off to System Print Preview or Share Sheet
    if (preview) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: filename,
      );
    } else {
      await Printing.sharePdf(
        bytes: bytes,
        filename: filename,
      );
    }
  }

  String _sanitizeFilename(String title) {
    final sanitized = title.replaceAll(RegExp(r'[^\w\s\-]'), '').trim();
    if (sanitized.isEmpty) return 'manuscript';
    return sanitized.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
  }
}
