import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../posts/domain/post.dart';
import '../data/export_repository.dart';
import '../domain/exportable_document.dart';
import '../presentation/pdf/pdf_body_standard.dart';
import '../presentation/pdf/pdf_footer.dart';
import '../presentation/pdf/pdf_header.dart';
import '../presentation/pdf/pdf_theme.dart';

final documentExportServiceProvider = Provider<DocumentExportService>((ref) {
  final repository = ref.watch(exportRepositoryProvider);
  return DocumentExportService(repository);
});

// Backward-compatibility alias
final postExportServiceProvider = documentExportServiceProvider;

class DocumentExportService {
  final ExportRepository _repository;

  DocumentExportService(this._repository);

  /// Backward-compatible method for exporting a single [Post]
  Future<void> exportPost({
    required Post post,
    required ScribesTheme theme,
    bool preview = true,
  }) async {
    if (post.postType != 'standard') {
      throw UnsupportedError('Only standard posts can be exported as manuscripts');
    }
    await exportDocument(
      document: PostExportAdapter(post),
      theme: theme,
      preview: preview,
    );
  }

  /// Exports any single [ExportableDocument] (Standard Post, Standard Draft, or Study Note)
  Future<void> exportDocument({
    required ExportableDocument document,
    required ScribesTheme theme,
    bool preview = true,
  }) async {
    if (!document.isExportable) {
      throw UnsupportedError('This document type cannot be exported as a manuscript');
    }

    // 1. Gather Assets (Network/Local Files + Fonts + BSB Verses)
    final assets = await _repository.gatherAssets(document, theme);
    final tokens = PdfThemeTokens.forTheme(theme);
    final title = document.title;

    // 2. Build Document
    final pdf = pw.Document(
      title: title,
      author: document.authorDisplayName.isNotEmpty
          ? document.authorDisplayName
          : document.authorHandle,
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

  /// Exports multiple [ExportableDocument] items stitched into a single compendium PDF
  Future<void> exportCompendium({
    required List<ExportableDocument> documents,
    required ScribesTheme theme,
    String compendiumTitle = 'Scribes Compendium',
    bool preview = true,
  }) async {
    final exportableDocs = documents.where((d) => d.isExportable).toList();
    if (exportableDocs.isEmpty) {
      throw UnsupportedError('No exportable documents found in selection');
    }

    final tokens = PdfThemeTokens.forTheme(theme);
    final pdf = pw.Document(
      title: compendiumTitle,
      creator: 'Scribes Sacred Manuscript Archive',
    );

    for (final doc in exportableDocs) {
      final assets = await _repository.gatherAssets(doc, theme);

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
    }

    final bytes = await pdf.save();
    final filename = '${_sanitizeFilename(compendiumTitle)}.pdf';

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
