import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../domain/bible_models.dart';

final bibleApiProvider = Provider<BibleApi>((ref) {
  final dio = ref.watch(apiClientProvider);
  return BibleApi(dio);
});

class BibleApi {
  final Dio _dio;

  BibleApi(this._dio);

  Future<List<BibleTranslation>> getTranslations() async {
    final response = await _dio.get(Endpoints.bibleTranslations);
    final data = response.data as Map<String, dynamic>;
    final list = data['translations'] as List<dynamic>? ?? [];
    return list
        .map((e) => BibleTranslation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BibleBook>> getBooks({String translation = 'BSB'}) async {
    final response = await _dio.get(
      Endpoints.bibleBooks,
      queryParameters: {'translation': translation},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['books'] as List<dynamic>? ?? [];
    return list
        .map((b) => BibleBook.fromJson(b as Map<String, dynamic>))
        .toList();
  }

  Future<BibleChapter> getChapter(
    String book,
    int chapter, {
    String translation = 'BSB',
  }) async {
    final cleanBook = Uri.encodeComponent(
      book.toLowerCase().replaceAll(' ', '-'),
    );
    final response = await _dio.get(
      Endpoints.bibleChapter(cleanBook, chapter),
      queryParameters: {'translation': translation},
    );
    return BibleChapter.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VerseRangeResult> getVerseRange(
    String book,
    int chapter,
    String range, {
    String translation = 'BSB',
  }) async {
    final cleanBook = Uri.encodeComponent(
      book.toLowerCase().replaceAll(' ', '-'),
    );
    final response = await _dio.get(
      Endpoints.bibleVerseRange(cleanBook, chapter, range),
      queryParameters: {'translation': translation},
    );
    return VerseRangeResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<BibleSearchResult>> search(
    String query, {
    int limit = 20,
    String translation = 'BSB',
  }) async {
    final response = await _dio.get(
      Endpoints.bibleSearch,
      queryParameters: {'q': query, 'limit': limit, 'translation': translation},
    );
    final data = response.data as Map<String, dynamic>;
    final list = data['results'] as List<dynamic>? ?? [];
    return list
        .map((r) => BibleSearchResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  Future<UserReadingPosition?> getReadingPosition() async {
    try {
      final response = await _dio.get(Endpoints.bibleReadingPosition);
      return UserReadingPosition.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveReadingPosition({
    required String book,
    String? bookCode,
    required int chapter,
    int verse = 1,
    String translation = 'BSB',
  }) async {
    await _dio.post(
      Endpoints.bibleReadingPosition,
      data: {
        'book': book,
        'book_code': bookCode ?? book,
        'chapter': chapter,
        'verse': verse,
        'translation': translation,
      },
    );
  }
}
