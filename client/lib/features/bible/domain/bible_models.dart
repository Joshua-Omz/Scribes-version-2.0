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
  final String text;

  const BibleVerse({
    this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      book: json['book'] as String?,
      chapter: json['chapter'] as int? ?? 1,
      verse: json['verse'] as int? ?? 1,
      text: json['text'] as String? ?? '',
    );
  }
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

class BibleReadingPosition {
  final String book;
  final int chapter;
  final DateTime? updatedAt;

  const BibleReadingPosition({
    required this.book,
    required this.chapter,
    this.updatedAt,
  });

  factory BibleReadingPosition.fromJson(Map<String, dynamic> json) {
    return BibleReadingPosition(
      book: json['book'] as String? ?? 'Genesis',
      chapter: json['chapter'] as int? ?? 1,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
