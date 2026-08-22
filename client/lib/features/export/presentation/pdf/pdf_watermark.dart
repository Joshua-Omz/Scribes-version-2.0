import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildWatermarkLayer(
  Uint8List? watermarkBytes,
  double pageWidth,
) {
  if (watermarkBytes == null) {
    return pw.SizedBox();
  }

  return pw.Positioned(
    top: 180,
    left: pageWidth * 0.12,
    right: pageWidth * 0.12,
    child: pw.Opacity(
      opacity: 0.07,
      child: pw.Image(
        pw.MemoryImage(watermarkBytes),
        fit: pw.BoxFit.contain,
      ),
    ),
  );
}
