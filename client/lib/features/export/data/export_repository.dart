import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../bible/data/bible_repository.dart';
import '../../posts/domain/post.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/scribes_image_resolver.dart';
import '../domain/export_asset_bundle.dart';
import '../presentation/pdf/pdf_theme.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  final bibleRepo = ref.watch(bibleRepositoryProvider);
  return ExportRepository(dio, bibleRepo);
});

class ExportRepository {
  final Dio _dio;
  final BibleRepository _bibleRepository;

  ExportRepository(this._dio, this._bibleRepository);

  Future<ExportAssetBundle> gatherAssets(
    Post post,
    ScribesTheme theme,
  ) async {
    // 1. Fetch Cover Image Bytes
    Uint8List? coverBytes;
    final imageUrl = ScribesImageResolver.extractFirstImageUrl(post);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      coverBytes = await _fetchImageBytes(imageUrl);
    }

    // 2. Fetch Watermark Bytes
    Uint8List? watermarkBytes = await _loadWatermark();

    // 3. Resolve Scripture Reference Verses
    final resolvedVerses = <String, String>{};
    for (final ref in post.scriptureRefs) {
      final rangeStr = ref.verseEnd != null && ref.verseEnd != ref.verseStart
          ? '${ref.verseStart}-${ref.verseEnd}'
          : '${ref.verseStart}';
      final refStr = '${ref.book} ${ref.chapter}:$rangeStr';
      try {
        final result = await _bibleRepository.getVerseRange(
          ref.book,
          ref.chapter,
          rangeStr,
        );
        if (result.verses.isNotEmpty) {
          final fullText = result.verses.map((v) => v.text).join(' ');
          resolvedVerses[refStr] = fullText;
        }
      } catch (_) {}
    }

    // 4. Load High-Quality Typography Fonts
    pw.Font cormorantRegular;
    pw.Font cormorantItalic;
    pw.Font cormorantBold;
    pw.Font dmSansRegular;
    pw.Font dmSansBold;

    try {
      cormorantRegular = await PdfGoogleFonts.cormorantGaramondRegular();
      cormorantItalic = await PdfGoogleFonts.cormorantGaramondItalic();
      cormorantBold = await PdfGoogleFonts.cormorantGaramondBold();
      dmSansRegular = await PdfGoogleFonts.interRegular();
      dmSansBold = await PdfGoogleFonts.interBold();
    } catch (_) {
      // Fallback for offline environments
      cormorantRegular = pw.Font.times();
      cormorantItalic = pw.Font.timesItalic();
      cormorantBold = pw.Font.timesBold();
      dmSansRegular = pw.Font.helvetica();
      dmSansBold = pw.Font.helveticaBold();
    }

    return ExportAssetBundle(
      post: post,
      coverImageBytes: coverBytes,
      resolvedVerses: resolvedVerses,
      watermarkBytes: watermarkBytes,
      cormorantRegular: cormorantRegular,
      cormorantItalic: cormorantItalic,
      cormorantBold: cormorantBold,
      dmSansRegular: dmSansRegular,
      dmSansBold: dmSansBold,
      activeTheme: theme,
    );
  }

  Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      if (url.startsWith('file://')) {
        final file = File(url.replaceFirst('file://', ''));
        if (file.existsSync()) {
          return await file.readAsBytes();
        }
      }

      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'ngrok-skip-browser-warning': 'true'},
        ),
      );
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
    } catch (_) {}
    return null;
  }

  Future<Uint8List?> _loadWatermark() async {
    for (final path in [
      'assets/branding/scribes_mark.png',
      'assets/scribes.png',
    ]) {
      try {
        final byteData = await rootBundle.load(path);
        return byteData.buffer.asUint8List();
      } catch (_) {}
    }
    return null;
  }
}
