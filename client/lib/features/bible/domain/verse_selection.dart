import '../../posts/domain/scripture_ref.dart';

/// Immutable domain entity representing a contiguous selection of verses
/// in a specific Bible book and chapter.
class VerseSelection {
  final String book;
  final int chapter;
  final int verseStart;
  final int verseEnd;

  const VerseSelection({
    required this.book,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
  }) : assert(verseStart <= verseEnd, 'verseStart must be <= verseEnd');

  VerseSelection copyWith({
    String? book,
    int? chapter,
    int? verseStart,
    int? verseEnd,
  }) {
    return VerseSelection(
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseStart: verseStart ?? this.verseStart,
      verseEnd: verseEnd ?? this.verseEnd,
    );
  }

  /// Whether a specific verse number falls inside this selected range.
  bool contains(int verse) => verse >= verseStart && verse <= verseEnd;

  /// Whether exactly one verse is selected.
  bool get isSingleVerse => verseStart == verseEnd;

  /// Human-readable scripture reference string, e.g. "John 3:16" or "John 3:16-18".
  String get displayLabel {
    if (verseStart == verseEnd) {
      return '$book $chapter:$verseStart';
    }
    return '$book $chapter:$verseStart-$verseEnd';
  }

  /// Converts this selection into the platform-standard [ScriptureRef].
  ScriptureRef toReference() {
    return ScriptureRef(
      book: book,
      chapter: chapter,
      verseStart: verseStart,
      verseEnd: verseEnd != verseStart ? verseEnd : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseSelection &&
          runtimeType == other.runtimeType &&
          book.toLowerCase() == other.book.toLowerCase() &&
          chapter == other.chapter &&
          verseStart == other.verseStart &&
          verseEnd == other.verseEnd;

  @override
  int get hashCode =>
      book.toLowerCase().hashCode ^
      chapter.hashCode ^
      verseStart.hashCode ^
      verseEnd.hashCode;

  @override
  String toString() => 'VerseSelection($displayLabel)';
}
