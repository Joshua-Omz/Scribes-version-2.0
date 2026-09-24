import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:scribes/core/storage/drift_database.dart';
import 'package:scribes/core/storage/secure_storage.dart';
import 'package:scribes/features/bible/application/bible_download_service.dart';
import 'package:scribes/features/bible/application/bible_providers.dart';
import 'package:scribes/features/bible/data/bible_api.dart';
import 'package:scribes/features/bible/data/bible_repository.dart';
import 'package:scribes/features/bible/data/local/bible_local_datasource_interface.dart';
import 'package:scribes/features/bible/domain/bible_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scribes/main.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String basePath;

  MockPathProviderPlatform(this.basePath);

  @override
  Future<String?> getApplicationDocumentsPath() async => basePath;
}

class MockHttpAdapter implements HttpClientAdapter {
  final List<int> responseBytes;
  bool shouldFail;

  MockHttpAdapter(this.responseBytes, {this.shouldFail = false});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (shouldFail) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        message: 'Simulated network connection drop',
      );
    }

    return ResponseBody.fromBytes(
      responseBytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/octet-stream'],
        Headers.contentLengthHeader: ['${responseBytes.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeBibleApi extends Fake implements BibleApi {}

class MockBibleLocalDatasource implements BibleLocalDatasource {
  final List<String> evictedTranslations = [];

  @override
  Future<void> ensureTranslationAvailable(String translationCode) async {}

  @override
  Future<void> evictTranslation(String translationCode) async {
    evictedTranslations.add(translationCode.toUpperCase());
  }

  @override
  Future<List<BibleTranslation>> getTranslations() async => [];

  @override
  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) async => [];

  @override
  Future<BibleChapter> getChapter(
    String bookName,
    int chapter, {
    String translation = 'BSB',
  }) async =>
      const BibleChapter(
        translation: 'BSB',
        book: 'Genesis',
        chapter: 1,
        verses: [],
      );

  @override
  Future<VerseRangeResult> getVerseRange(
    String bookName,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) async =>
      const VerseRangeResult(
        translation: 'BSB',
        reference: 'Genesis 1:1',
        verses: [],
      );

  @override
  Future<List<BibleSearchResult>> search(
    String query, {
    String translation = 'BSB',
    int limit = 20,
  }) async =>
      [];

  @override
  Future<List<BibleComparisonResult>> compareVerse(
    String bookName,
    int chapter,
    int verse, {
    List<String>? translations,
  }) async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ScribesDatabase db;
  late MockBibleLocalDatasource mockLocal;
  late BibleRepository repository;
  late ProviderContainer container;

  // Test data: dummy SQLite content
  final dummySqliteBytes = utf8.encode('SQLite format 3\x00Dummy Test Database Content');
  final dummyGzBytes = gzip.encode(dummySqliteBytes);
  final expectedSqliteSha256 = sha256.convert(dummySqliteBytes).toString();
  final expectedGzSha256 = sha256.convert(dummyGzBytes).toString();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('scribes_bible_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);

    // Mock MethodChannel for path_provider fallback
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tempDir.path;
      }
      return null;
    });

    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    FlutterSecureStorage.setMockInitialValues({});

    db = ScribesDatabase.forTesting(NativeDatabase.memory());
    mockLocal = MockBibleLocalDatasource();
    repository = BibleRepository(
      FakeBibleApi(),
      mockLocal,
      db.bibleDao,
      SecureStorage(),
      'test_user',
    );

    container = ProviderContainer(
      overrides: [
        bibleRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Dio createTestDio(List<int> bytes, {bool shouldFail = false}) {
    final dio = Dio();
    dio.httpClientAdapter = MockHttpAdapter(bytes, shouldFail: shouldFail);
    return dio;
  }

  group('BibleDownloadService Tests', () {
    test('Successful download, two-phase verification, decompression, and Drift registration', () async {
      final notifier = container.read(bibleDownloadNotifierProvider.notifier);
      notifier.setDioForTesting(createTestDio(dummyGzBytes));

      final translation = BibleTranslation(
        id: 'TEST',
        code: 'TEST',
        name: 'Test Bible Translation',
        language: 'en',
        attributionText: 'Test Translation Public Domain',
        source: 'edge_download',
        isDefault: false,
        version: 1,
        compressedBytes: dummyGzBytes.length,
        uncompressedBytes: dummySqliteBytes.length,
        gzSha256: expectedGzSha256,
        sha256: expectedSqliteSha256,
        downloadUrl: 'https://cdn.scribes.app/bible/test_v1.sqlite3.gz',
      );

      await notifier.downloadTranslation(translation);

      final state = container.read(bibleDownloadNotifierProvider)['TEST'];
      expect(state, isNotNull);
      expect(state!.status, DownloadStatus.completed);
      expect(state.progress, 1.0);

      // Verify the decompressed file exists at <docs>/bible/test.sqlite3
      final targetFile = File(p.join(tempDir.path, 'bible', 'test.sqlite3'));
      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.readAsBytes(), dummySqliteBytes);

      // Verify registered in Drift
      final installed = await db.bibleDao.getDownloadedTranslations();
      expect(installed.length, 1);
      expect(installed.first.code, 'TEST');
      expect(installed.first.name, 'Test Bible Translation');
      expect(installed.first.sizeBytes, dummySqliteBytes.length);
    });

    test('Phase 1 failure: GZip checksum mismatch stops download and removes temp files', () async {
      final notifier = container.read(bibleDownloadNotifierProvider.notifier);
      notifier.setDioForTesting(createTestDio(dummyGzBytes));

      final translation = BibleTranslation(
        id: 'CORRUPT_GZ',
        code: 'CORRUPT_GZ',
        name: 'Corrupt GZip Translation',
        language: 'en',
        attributionText: 'Test Attribution',
        source: 'edge_download',
        isDefault: false,
        version: 1,
        compressedBytes: dummyGzBytes.length,
        uncompressedBytes: dummySqliteBytes.length,
        gzSha256: '0000000000000000000000000000000000000000000000000000000000000000', // Intentionally wrong
        sha256: expectedSqliteSha256,
        downloadUrl: 'https://cdn.scribes.app/bible/corrupt_v1.sqlite3.gz',
      );

      await notifier.downloadTranslation(translation);

      final state = container.read(bibleDownloadNotifierProvider)['CORRUPT_GZ'];
      expect(state, isNotNull);
      expect(state!.status, DownloadStatus.error);
      expect(state.errorMessage, contains('GZip archive checksum mismatch'));

      // Verify target file was NEVER created
      final targetFile = File(p.join(tempDir.path, 'bible', 'corrupt_gz.sqlite3'));
      expect(await targetFile.exists(), isFalse);

      // Verify not registered in Drift
      final installed = await db.bibleDao.getDownloadedTranslations();
      expect(installed.isEmpty, isTrue);
    });

    test('Phase 2 failure: SQLite checksum mismatch stops registration and deletes temp files', () async {
      final notifier = container.read(bibleDownloadNotifierProvider.notifier);
      notifier.setDioForTesting(createTestDio(dummyGzBytes));

      final translation = BibleTranslation(
        id: 'CORRUPT_SQLITE',
        code: 'CORRUPT_SQLITE',
        name: 'Corrupt SQLite Translation',
        language: 'en',
        attributionText: 'Test Attribution',
        source: 'edge_download',
        isDefault: false,
        version: 1,
        compressedBytes: dummyGzBytes.length,
        uncompressedBytes: dummySqliteBytes.length,
        gzSha256: expectedGzSha256, // GZip matches
        sha256: 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', // Uncompressed mismatch
        downloadUrl: 'https://cdn.scribes.app/bible/corrupt_sqlite_v1.sqlite3.gz',
      );

      await notifier.downloadTranslation(translation);

      final state = container.read(bibleDownloadNotifierProvider)['CORRUPT_SQLITE'];
      expect(state, isNotNull);
      expect(state!.status, DownloadStatus.error);
      expect(state.errorMessage, contains('SQLite checksum mismatch'));

      // Verify target file was not placed
      final targetFile = File(p.join(tempDir.path, 'bible', 'corrupt_sqlite.sqlite3'));
      expect(await targetFile.exists(), isFalse);

      // Verify not registered in Drift
      final installed = await db.bibleDao.getDownloadedTranslations();
      expect(installed.isEmpty, isTrue);
    });

    test('deleteTranslation removes physical file and Drift record', () async {
      final notifier = container.read(bibleDownloadNotifierProvider.notifier);
      notifier.setDioForTesting(createTestDio(dummyGzBytes));

      final translation = BibleTranslation(
        id: 'KJV',
        code: 'KJV',
        name: 'King James Version',
        language: 'en',
        attributionText: 'Public Domain',
        source: 'edge_download',
        isDefault: false,
        downloadUrl: 'https://cdn.scribes.app/bible/kjv_v1.sqlite3.gz',
      );

      // 1. Download
      await notifier.downloadTranslation(translation);
      final targetFile = File(p.join(tempDir.path, 'bible', 'kjv.sqlite3'));
      expect(await targetFile.exists(), isTrue);
      expect((await db.bibleDao.getDownloadedTranslations()).length, 1);

      // 2. Delete
      await notifier.deleteTranslation('KJV');

      // 3. Verify file deleted, Drift cleared, and datasource evicted
      expect(await targetFile.exists(), isFalse);
      expect((await db.bibleDao.getDownloadedTranslations()).isEmpty, isTrue);
      expect(mockLocal.evictedTranslations, contains('KJV'));
    });

    test('deleteTranslation protects bundled BSB from being deleted', () async {
      final notifier = container.read(bibleDownloadNotifierProvider.notifier);
      expect(
        () => notifier.deleteTranslation('BSB'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
