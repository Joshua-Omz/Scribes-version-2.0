final Map<String, int> oldTestamentBooks = {
  'Genesis': 50,
  'Exodus': 40,
  'Leviticus': 27,
  'Numbers': 36,
  'Deuteronomy': 34,
  'Joshua': 24,
  'Judges': 21,
  'Ruth': 4,
  '1 Samuel': 31,
  '2 Samuel': 24,
  '1 Kings': 22,
  '2 Kings': 25,
  '1 Chronicles': 29,
  '2 Chronicles': 36,
  'Ezra': 10,
  'Nehemiah': 13,
  'Esther': 10,
  'Job': 42,
  'Psalms': 150,
  'Proverbs': 31,
  'Ecclesiastes': 12,
  'Song of Solomon': 8,
  'Isaiah': 66,
  'Jeremiah': 52,
  'Lamentations': 5,
  'Ezekiel': 48,
  'Daniel': 12,
  'Hosea': 14,
  'Joel': 3,
  'Amos': 9,
  'Obadiah': 1,
  'Jonah': 4,
  'Micah': 7,
  'Nahum': 3,
  'Habakkuk': 3,
  'Zephaniah': 3,
  'Haggai': 2,
  'Zechariah': 14,
  'Malachi': 4,
};

final Map<String, int> newTestamentBooks = {
  'Matthew': 28,
  'Mark': 16,
  'Luke': 24,
  'John': 21,
  'Acts': 28,
  'Romans': 16,
  '1 Corinthians': 16,
  '2 Corinthians': 13,
  'Galatians': 6,
  'Ephesians': 6,
  'Philippians': 4,
  'Colossians': 4,
  '1 Thessalonians': 5,
  '2 Thessalonians': 3,
  '1 Timothy': 6,
  '2 Timothy': 4,
  'Titus': 3,
  'Philemon': 1,
  'Hebrews': 13,
  'James': 5,
  '1 Peter': 5,
  '2 Peter': 3,
  '1 John': 5,
  '2 John': 1,
  '3 John': 1,
  'Jude': 1,
  'Revelation': 22,
};

final Map<String, int> allBibleBooks = {
  ...oldTestamentBooks,
  ...newTestamentBooks,
};

const Map<String, int> canonicalBookCodes = {
  'GEN': 1, 'EXO': 2, 'LEV': 3, 'NUM': 4, 'DEU': 5,
  'JOS': 6, 'JDG': 7, 'RUT': 8, '1SA': 9, '2SA': 10,
  '1KI': 11, '2KI': 12, '1CH': 13, '2CH': 14, 'EZR': 15,
  'NEH': 16, 'EST': 17, 'JOB': 18, 'PSA': 19, 'PRO': 20,
  'ECC': 21, 'SNG': 22, 'ISA': 23, 'JER': 24, 'LAM': 25,
  'EZK': 26, 'DAN': 27, 'HOS': 28, 'JOL': 29, 'AMO': 30,
  'OBA': 31, 'JON': 32, 'MIC': 33, 'NAM': 34, 'HAB': 35,
  'ZEP': 36, 'HAG': 37, 'ZEC': 38, 'MAL': 39,
  'MAT': 40, 'MRK': 41, 'LUK': 42, 'JHN': 43, 'ACT': 44,
  'ROM': 45, '1CO': 46, '2CO': 47, 'GAL': 48, 'EPH': 49,
  'PHP': 50, 'COL': 51, '1TH': 52, '2TH': 53, '1TI': 54,
  '2TI': 55, 'TIT': 56, 'PHM': 57, 'HEB': 58, 'JAS': 59,
  '1PE': 60, '2PE': 61, '1JN': 62, '2JN': 63, '3JN': 64,
  'JUD': 65, 'REV': 66,
};

int resolveCanonicalBookId(String identifier) {
  final upper = identifier.trim().toUpperCase();
  if (canonicalBookCodes.containsKey(upper)) {
    return canonicalBookCodes[upper]!;
  }
  // Try matching by book name order
  int order = 1;
  for (final bookName in allBibleBooks.keys) {
    if (bookName.toUpperCase() == upper ||
        bookName.replaceAll(' ', '').toUpperCase() == upper.replaceAll(' ', '')) {
      return order;
    }
    order++;
  }
  return 1;
}
