import 'package:pdf/pdf.dart';

enum ScribesTheme { parchment, night, silver }

class PdfThemeTokens {
  final PdfColor background;
  final PdfColor surface;
  final PdfColor primaryText;
  final PdfColor secondaryText;
  final PdfColor gold;
  final PdfColor goldMuted;
  final PdfColor border;

  const PdfThemeTokens({
    required this.background,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.gold,
    required this.goldMuted,
    required this.border,
  });

  static PdfThemeTokens forTheme(ScribesTheme theme) {
    switch (theme) {
      case ScribesTheme.night:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#0A0A0A'),
          surface: PdfColor.fromHex('#111111'),
          primaryText: PdfColor.fromHex('#F0EDE6'),
          secondaryText: PdfColor.fromHex('#8A8070'),
          gold: PdfColor.fromHex('#C9A84C'),
          goldMuted: PdfColor.fromHex('#7A6230'),
          border: PdfColor.fromHex('#2A2520'),
        );
      case ScribesTheme.parchment:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#F5F0E8'),
          surface: PdfColor.fromHex('#FDFAF4'),
          primaryText: PdfColor.fromHex('#1A1612'),
          secondaryText: PdfColor.fromHex('#6B6055'),
          gold: PdfColor.fromHex('#9A7020'),
          goldMuted: PdfColor.fromHex('#C8B070'),
          border: PdfColor.fromHex('#DDD5C0'),
        );
      case ScribesTheme.silver:
        return PdfThemeTokens(
          background: PdfColor.fromHex('#F2F2F4'),
          surface: PdfColor.fromHex('#FFFFFF'),
          primaryText: PdfColor.fromHex('#111116'),
          secondaryText: PdfColor.fromHex('#72727A'),
          gold: PdfColor.fromHex('#B08A2A'),
          goldMuted: PdfColor.fromHex('#D4C080'),
          border: PdfColor.fromHex('#E0E0E6'),
        );
    }
  }
}
