import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'exportable_document.dart';
import '../presentation/pdf/pdf_theme.dart';

class ExportAssetBundle {
  final ExportableDocument document;
  final Uint8List? coverImageBytes;
  final List<Uint8List>? panelImageBytes;
  final Map<String, String>? resolvedVerses;
  final Uint8List? watermarkBytes;
  final pw.Font cormorantRegular;
  final pw.Font cormorantItalic;
  final pw.Font cormorantBold;
  final pw.Font dmSansRegular;
  final pw.Font dmSansBold;
  final ScribesTheme activeTheme;

  const ExportAssetBundle({
    required this.document,
    this.coverImageBytes,
    this.panelImageBytes,
    this.resolvedVerses,
    this.watermarkBytes,
    required this.cormorantRegular,
    required this.cormorantItalic,
    required this.cormorantBold,
    required this.dmSansRegular,
    required this.dmSansBold,
    required this.activeTheme,
  });
}
