import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/bible_repository.dart';
import '../domain/bible_models.dart';
import 'bible_providers.dart';

enum DownloadStatus {
  idle,
  downloading,
  verifying,
  decompressing,
  completed,
  error,
}

class TranslationDownloadState {
  final String code;
  final DownloadStatus status;
  final int receivedBytes;
  final int totalBytes;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;

  const TranslationDownloadState({
    required this.code,
    this.status = DownloadStatus.idle,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.progress = 0.0,
    this.errorMessage,
  });

  bool get isDownloading =>
      status == DownloadStatus.downloading ||
      status == DownloadStatus.verifying ||
      status == DownloadStatus.decompressing;

  bool get isCompleted => status == DownloadStatus.completed;
  bool get hasError => status == DownloadStatus.error;

  String get statusLabel {
    switch (status) {
      case DownloadStatus.idle:
        return 'Ready';
      case DownloadStatus.downloading:
        final pct = (progress * 100).toInt();
        return 'Downloading... $pct%';
      case DownloadStatus.verifying:
        return 'Verifying integrity...';
      case DownloadStatus.decompressing:
        return 'Unpacking translation...';
      case DownloadStatus.completed:
        return 'Installed';
      case DownloadStatus.error:
        return errorMessage ?? 'Download failed';
    }
  }

  TranslationDownloadState copyWith({
    DownloadStatus? status,
    int? receivedBytes,
    int? totalBytes,
    double? progress,
    String? errorMessage,
  }) {
    return TranslationDownloadState(
      code: code,
      status: status ?? this.status,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BibleDownloadNotifier
    extends Notifier<Map<String, TranslationDownloadState>> {
  late Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};

  @override
  Map<String, TranslationDownloadState> build() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
    ref.onDispose(() {
      _cancelTokens.forEach((_, token) => token.cancel('Disposed'));
      _cancelTokens.clear();
      _dio.close();
    });
    return {};
  }

  // Injectable Dio for unit testing
  void setDioForTesting(Dio dio) {
    _dio = dio;
  }

  Future<String> _getBibleDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final bibleDir = Directory(p.join(docsDir.path, 'bible'));
    if (!await bibleDir.exists()) {
      await bibleDir.create(recursive: true);
    }
    return bibleDir.path;
  }

  Future<String> _computeFileSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  void _updateState(String code, TranslationDownloadState newState) {
    state = {...state, code.toUpperCase(): newState};
  }

  Future<void> downloadTranslation(BibleTranslation translation) async {
    final code = translation.code.toUpperCase();

    if (translation.downloadUrl == null || translation.downloadUrl!.isEmpty) {
      _updateState(
        code,
        TranslationDownloadState(
          code: code,
          status: DownloadStatus.error,
          errorMessage: 'No download URL available for $code',
        ),
      );
      return;
    }

    final currentState = state[code];
    if (currentState != null && currentState.isDownloading) {
      return; // Already in progress
    }

    final cancelToken = CancelToken();
    _cancelTokens[code] = cancelToken;

    final bibleDir = await _getBibleDirectory();
    final tempGzFile = File(
      p.join(bibleDir, '${code.toLowerCase()}_v${translation.version}.sqlite3.gz.tmp'),
    );
    final tempUncompressedFile = File(
      p.join(bibleDir, '${code.toLowerCase()}_v${translation.version}.sqlite3.tmp'),
    );
    final targetDbFile = File(p.join(bibleDir, '${code.toLowerCase()}.sqlite3'));

    try {
      // 1. Initial State
      _updateState(
        code,
        TranslationDownloadState(
          code: code,
          status: DownloadStatus.downloading,
          receivedBytes: 0,
          totalBytes: translation.compressedBytes > 0
              ? translation.compressedBytes
              : translation.fileSizeBytes,
          progress: 0.05,
        ),
      );

      if (await tempGzFile.exists()) await tempGzFile.delete();
      if (await tempUncompressedFile.exists()) await tempUncompressedFile.delete();

      // 2. Stream Download via Dio
      await _dio.download(
        translation.downloadUrl!,
        tempGzFile.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          final effectiveTotal = total > 0
              ? total
              : (translation.compressedBytes > 0
                  ? translation.compressedBytes
                  : translation.fileSizeBytes);
          final ratio = effectiveTotal > 0 ? (received / effectiveTotal) : 0.5;
          final normalizedProgress = (ratio * 0.70).clamp(0.05, 0.70);

          _updateState(
            code,
            TranslationDownloadState(
              code: code,
              status: DownloadStatus.downloading,
              receivedBytes: received,
              totalBytes: effectiveTotal,
              progress: normalizedProgress,
            ),
          );
        },
      );

      // 3. Verify GZip Checksum (Phase 1)
      _updateState(
        code,
        state[code]!.copyWith(
          status: DownloadStatus.verifying,
          progress: 0.75,
        ),
      );

      if (translation.gzSha256 != null && translation.gzSha256!.isNotEmpty) {
        final gzActualHash = await _computeFileSha256(tempGzFile);
        if (gzActualHash.toLowerCase() != translation.gzSha256!.toLowerCase()) {
          throw Exception(
            'GZip archive checksum mismatch for $code. Expected ${translation.gzSha256}, got $gzActualHash',
          );
        }
      }

      // 4. Decompress GZip Stream into SQLite File
      _updateState(
        code,
        state[code]!.copyWith(
          status: DownloadStatus.decompressing,
          progress: 0.85,
        ),
      );

      final uncompressedSink = tempUncompressedFile.openWrite();
      try {
        await tempGzFile
            .openRead()
            .transform(gzip.decoder)
            .pipe(uncompressedSink);
      } catch (e) {
        throw Exception('Decompression failed for $code: $e');
      }

      // 5. Verify Uncompressed SQLite Checksum (Phase 2)
      _updateState(
        code,
        state[code]!.copyWith(
          status: DownloadStatus.verifying,
          progress: 0.95,
        ),
      );

      if (translation.sha256 != null && translation.sha256!.isNotEmpty) {
        final uncompressedActualHash =
            await _computeFileSha256(tempUncompressedFile);
        if (uncompressedActualHash.toLowerCase() !=
            translation.sha256!.toLowerCase()) {
          throw Exception(
            'SQLite checksum mismatch for $code. Expected ${translation.sha256}, got $uncompressedActualHash',
          );
        }
      }

      // 6. Evict prior cached database handle before overwriting target file
      final repo = ref.read(bibleRepositoryProvider);
      await repo.removeDownloadedTranslation(code);

      // 7. Atomic file placement
      if (await targetDbFile.exists()) {
        await targetDbFile.delete();
      }
      try {
        await tempUncompressedFile.rename(targetDbFile.path);
      } catch (_) {
        await tempUncompressedFile.copy(targetDbFile.path);
        await tempUncompressedFile.delete();
      }

      // 8. Register in Drift SQLite database
      final uncompressedBytes = await targetDbFile.length();
      await repo.registerDownloadedTranslation(
        code: code,
        name: translation.name,
        version: translation.version,
        fileSizeBytes: uncompressedBytes,
        localPath: targetDbFile.path,
      );

      // 9. Clean up compressed temp file
      if (await tempGzFile.exists()) {
        await tempGzFile.delete();
      }

      // 10. Mark completed and invalidate translations provider for UI update
      _updateState(
        code,
        TranslationDownloadState(
          code: code,
          status: DownloadStatus.completed,
          receivedBytes: uncompressedBytes,
          totalBytes: uncompressedBytes,
          progress: 1.0,
        ),
      );

      ref.invalidate(bibleTranslationsProvider);
    } catch (e) {
      // Clean up temp files on error
      if (await tempGzFile.exists()) await tempGzFile.delete();
      if (await tempUncompressedFile.exists()) await tempUncompressedFile.delete();

      if (e is DioException && CancelToken.isCancel(e)) {
        _updateState(
          code,
          TranslationDownloadState(
            code: code,
            status: DownloadStatus.idle,
          ),
        );
        return;
      }

      _updateState(
        code,
        TranslationDownloadState(
          code: code,
          status: DownloadStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _cancelTokens.remove(code);
    }
  }

  void cancelDownload(String code) {
    final upperCode = code.toUpperCase();
    if (_cancelTokens.containsKey(upperCode)) {
      _cancelTokens[upperCode]!.cancel('User cancelled download');
      _cancelTokens.remove(upperCode);
    }
  }

  Future<void> deleteTranslation(String code) async {
    final upperCode = code.toUpperCase();

    if (upperCode == 'BSB') {
      throw Exception('The bundled Berean Standard Bible (BSB) cannot be deleted.');
    }

    final repo = ref.read(bibleRepositoryProvider);

    // If currently selected, fall back to BSB
    final currentSelected = ref.read(selectedTranslationProvider);
    if (currentSelected.toUpperCase() == upperCode) {
      ref.read(selectedTranslationProvider.notifier).setTranslation('BSB');
    }

    // Evict connection and remove from Drift database
    await repo.removeDownloadedTranslation(upperCode);

    // Delete local SQLite file
    final bibleDir = await _getBibleDirectory();
    final dbFile = File(p.join(bibleDir, '${upperCode.toLowerCase()}.sqlite3'));
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    // Reset download state
    final nextState = {...state};
    nextState.remove(upperCode);
    state = nextState;

    // Refresh translations list
    ref.invalidate(bibleTranslationsProvider);
  }
}

final bibleDownloadNotifierProvider =
    NotifierProvider<BibleDownloadNotifier, Map<String, TranslationDownloadState>>(
  BibleDownloadNotifier.new,
);

final translationDownloadProgressProvider =
    Provider.family<TranslationDownloadState?, String>((ref, code) {
  final downloads = ref.watch(bibleDownloadNotifierProvider);
  return downloads[code.toUpperCase()];
});
