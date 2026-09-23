class BibleTranslation {
  final String id;
  final String code;
  final String name;
  final String language;
  final String attributionText;
  final String source;
  final bool isDefault;
  final bool isBundled;
  final bool isDownloaded;
  final int fileSizeBytes;
  final String? downloadUrl;
  final int version;

  const BibleTranslation({
    required this.id,
    required this.code,
    required this.name,
    required this.language,
    required this.attributionText,
    required this.source,
    required this.isDefault,
    this.isBundled = false,
    this.isDownloaded = false,
    this.fileSizeBytes = 0,
    this.downloadUrl,
    this.version = 1,
  });

  factory BibleTranslation.fromJson(Map<String, dynamic> json) {
    return BibleTranslation(
      id: json['id'] as String? ?? json['code'] as String? ?? '',
      code: (json['code'] as String? ?? '').toUpperCase(),
      name: json['name'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      attributionText: json['attribution_text'] as String? ??
          json['attribution'] as String? ??
          '',
      source: json['source'] as String? ?? 'edge_download',
      isDefault: json['is_default'] as bool? ?? false,
      isBundled: json['is_bundled'] as bool? ?? false,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ??
          (json['compressed_bytes'] as num?)?.toInt() ??
          0,
      downloadUrl: json['download_url'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  BibleTranslation copyWith({
    bool? isDownloaded,
    bool? isDefault,
  }) {
    return BibleTranslation(
      id: id,
      code: code,
      name: name,
      language: language,
      attributionText: attributionText,
      source: source,
      isDefault: isDefault ?? this.isDefault,
      isBundled: isBundled,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      fileSizeBytes: fileSizeBytes,
      downloadUrl: downloadUrl,
      version: version,
    );
  }
}

class BibleBook {
  final String id;
  final String name;
  final String shortName;
  final String testament; // "old" | "new"
  final int order;
  final int chapterCount;

  const BibleBook({
    required this.id,
    required this.name,
    required this.shortName,
    required this.testament,
    required this.order,
    required this.chapterCount,
  });

  String get code => shortName;

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      testament: json['testament'] as String? ?? 'old',
      order: json['order'] as int? ?? 1,
      chapterCount: json['chapter_count'] as int? ?? 1,
    );
  }
}

class BibleVerse {
  final String? book;
  final int chapter;
  final int verse;
  final int? verseEnd;
  final String text;
  final bool isOmitted;

  const BibleVerse({
    this.book,
    required this.chapter,
    required this.verse,
    this.verseEnd,
    required this.text,
    this.isOmitted = false,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      book: json['book'] as String?,
      chapter: json['chapter'] as int? ?? 1,
      verse: json['verse'] as int? ?? 1,
      verseEnd: json['verse_end'] as int?,
      text: json['text'] as String? ?? '',
      isOmitted: json['is_omitted'] as bool? ?? false,
    );
  }
}

class BibleComparisonResult {
  final String translation;
  final String translationName;
  final String reference;
  final String text;
  final String attribution;

  const BibleComparisonResult({
    required this.translation,
    required this.translationName,
    required this.reference,
    required this.text,
    required this.attribution,
  });
}

class BibleChapter {
  final String translation;
  final String book;
  final int chapter;
  final List<BibleVerse> verses;

  const BibleChapter({
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verses,
  });

  factory BibleChapter.fromJson(Map<String, dynamic> json) {
    final list = json['verses'] as List<dynamic>? ?? [];
    return BibleChapter(
      translation: json['translation'] as String? ?? 'BSB',
      book: json['book'] as String? ?? '',
      chapter: json['chapter'] as int? ?? 1,
      verses: list
          .map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VerseRangeResult {
  final String translation;
  final String reference;
  final List<BibleVerse> verses;

  const VerseRangeResult({
    required this.translation,
    required this.reference,
    required this.verses,
  });

  factory VerseRangeResult.fromJson(Map<String, dynamic> json) {
    final list = json['verses'] as List<dynamic>? ?? [];
    return VerseRangeResult(
      translation: json['translation'] as String? ?? 'BSB',
      reference: json['reference'] as String? ?? '',
      verses: list
          .map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  String get fullText => verses.map((v) => v.text).join(' ');
}

class BibleSearchResult {
  final String book;
  final int chapter;
  final int verse;
  final String text;

  const BibleSearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory BibleSearchResult.fromJson(Map<String, dynamic> json) {
    return BibleSearchResult(
      book: json['book'] as String? ?? '',
      chapter: json['chapter'] as int? ?? 1,
      verse: json['verse'] as int? ?? 1,
      text: json['text'] as String? ?? '',
    );
  }

  String get reference => '$book $chapter:$verse';
}

class UserReadingPosition {
  final String book;
  final String bookCode;
  final int chapter;
  final int verse;
  final String preferredTranslation;
  final DateTime? updatedAt;

  const UserReadingPosition({
    required this.book,
    this.bookCode = '',
    required this.chapter,
    this.verse = 1,
    this.preferredTranslation = 'BSB',
    this.updatedAt,
  });

  factory UserReadingPosition.fromJson(Map<String, dynamic> json) {
    final rawBook = json['book'] as String? ?? json['book_code'] as String? ?? 'Genesis';
    return UserReadingPosition(
      book: rawBook,
      bookCode: json['book_code'] as String? ?? '',
      chapter: json['chapter'] as int? ?? 1,
      verse: json['verse'] as int? ?? 1,
      preferredTranslation: json['preferred_translation'] as String? ?? 'BSB',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'book_code': bookCode,
      'chapter': chapter,
      'verse': verse,
      'preferred_translation': preferredTranslation,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
