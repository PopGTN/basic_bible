import 'package:basic_bible/src/models/bible_models.dart';

/// Parse a reference string like "John 3:16" into a [BibleReference].
BibleReference? parseReferenceString(String refString) {
  final parts = refString.split(' ');
  if (parts.length < 2) return null;

  String bookName = parts[0];
  int? chapter;
  int? verse;

  if (parts.length > 2 &&
      (parts[0].startsWith('1') ||
          parts[0].startsWith('2') ||
          parts[0].startsWith('3'))) {
    bookName = '${parts[0]} ${parts[1]}';
    final chapterVerse = parts[2].split(':');
    chapter = int.tryParse(chapterVerse[0]);
    if (chapterVerse.length > 1) verse = int.tryParse(chapterVerse[1]);
  } else {
    final chapterVerse = parts[1].split(':');
    chapter = int.tryParse(chapterVerse[0]);
    if (chapterVerse.length > 1) verse = int.tryParse(chapterVerse[1]);
  }

  final mapped = _mapBookNameToId(bookName);
  if (mapped != null && chapter != null) {
    return BibleReference(bookId: mapped, chapter: chapter, verse: verse);
  }
  return null;
}

/// Parse a structured parser target like `JHN.3.16` or `John.3.16`.
BibleReference? parseStructuredReferenceTarget(String? target) {
  if (target == null || target.trim().isEmpty) return null;

  final cleanedTarget = target.trim().split(RegExp(r'[\s-]')).first;
  final parts = cleanedTarget.split('.');
  if (parts.length < 2) return null;

  final rawBookId = parts[0];
  final bookId = _normalizeStructuredBookId(rawBookId);
  final chapter = int.tryParse(parts[1]);
  final verse = parts.length > 2 ? int.tryParse(parts[2]) : null;

  if (bookId == null || chapter == null) return null;
  return BibleReference(bookId: bookId, chapter: chapter, verse: verse);
}

/// Prefer parser-provided targets and only fall back to display-label parsing.
BibleReference? parseAnyReference({String? target, required String label}) {
  return parseStructuredReferenceTarget(target) ?? parseReferenceString(label);
}

/// Resolve a reference book ID against the books currently available in the
/// loaded translation. This keeps the reader usable when translations expose
/// the same book with a slightly different source-specific ID or casing.
BibleBook? resolveBookFromReference(
  List<BibleBook> books,
  String referenceBookId,
) {
  if (books.isEmpty) return null;

  final exactMatch = books.where((book) => book.id == referenceBookId);
  if (exactMatch.isNotEmpty) {
    return exactMatch.first;
  }

  final referenceTokens = _bookMatchTokens(referenceBookId);
  for (final book in books) {
    final bookTokens = {
      ..._bookMatchTokens(book.id),
      ..._bookMatchTokens(book.shortName),
      ..._bookMatchTokens(book.name),
    };
    if (bookTokens.any(referenceTokens.contains)) {
      return book;
    }
  }

  return null;
}

String? _mapBookNameToId(String bookName) {
  const bookNameToIdMap = {
    'Genesis': 'GEN',
    'Exodus': 'EXO',
    'Leviticus': 'LEV',
    'Numbers': 'NUM',
    'Deuteronomy': 'DEU',
    'Joshua': 'JOS',
    'Judges': 'JDG',
    'Ruth': 'RUT',
    '1 Samuel': '1SA',
    '2 Samuel': '2SA',
    '1 Kings': '1KI',
    '2 Kings': '2KI',
    '1 Chronicles': '1CH',
    '2 Chronicles': '2CH',
    'Ezra': 'EZR',
    'Nehemiah': 'NEH',
    'Esther': 'EST',
    'Job': 'JOB',
    'Psalms': 'PSA',
    'Proverbs': 'PRO',
    'Ecclesiastes': 'ECC',
    'Song of Solomon': 'SNG',
    'Isaiah': 'ISA',
    'Jeremiah': 'JER',
    'Lamentations': 'LAM',
    'Ezekiel': 'EZK',
    'Daniel': 'DAN',
    'Hosea': 'HOS',
    'Joel': 'JOL',
    'Amos': 'AMO',
    'Obadiah': 'OBA',
    'Jonah': 'JON',
    'Micah': 'MIC',
    'Nahum': 'NAM',
    'Habakkuk': 'HAB',
    'Zephaniah': 'ZEP',
    'Haggai': 'HAG',
    'Zechariah': 'ZEC',
    'Malachi': 'MAL',
    'Matthew': 'MAT',
    'Mark': 'MRK',
    'Luke': 'LUK',
    'John': 'JHN',
    'Acts': 'ACT',
    'Romans': 'ROM',
    '1 Corinthians': '1CO',
    '2 Corinthians': '2CO',
    'Galatians': 'GAL',
    'Ephesians': 'EPH',
    'Philippians': 'PHP',
    'Colossians': 'COL',
    '1 Thessalonians': '1TH',
    '2 Thessalonians': '2TH',
    '1 Timothy': '1TI',
    '2 Timothy': '2TI',
    'Titus': 'TIT',
    'Philemon': 'PHM',
    'Hebrews': 'HEB',
    'James': 'JAS',
    '1 Peter': '1PE',
    '2 Peter': '2PE',
    '1 John': '1JN',
    '2 John': '2JN',
    '3 John': '3JN',
    'Jude': 'JUD',
    'Revelation': 'REV',
  };
  return bookNameToIdMap[bookName];
}

Set<String> _bookMatchTokens(String rawValue) {
  final trimmed = rawValue.trim();
  if (trimmed.isEmpty) return const {};

  final collapsed = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  final uppercase = collapsed.toUpperCase();
  final normalizedStructured = _normalizeStructuredBookId(uppercase);
  final mappedName = _mapBookNameToId(trimmed);

  return {
    trimmed,
    trimmed.toUpperCase(),
    collapsed,
    uppercase,
    if (normalizedStructured != null) normalizedStructured,
    if (mappedName != null) mappedName,
  };
}

String? _normalizeStructuredBookId(String rawBookId) {
  final normalized = rawBookId.trim();
  if (normalized.isEmpty) return null;

  const structuredBookIdMap = {
    'GEN': 'GEN',
    'EXOD': 'EXO',
    'EXO': 'EXO',
    'LEV': 'LEV',
    'NUM': 'NUM',
    'DEUT': 'DEU',
    'DEU': 'DEU',
    'JOSH': 'JOS',
    'JOS': 'JOS',
    'JUDG': 'JDG',
    'JDG': 'JDG',
    'RUTH': 'RUT',
    'RUT': 'RUT',
    '1SAM': '1SA',
    '2SAM': '2SA',
    '1KGS': '1KI',
    '2KGS': '2KI',
    '1KI': '1KI',
    '2KI': '2KI',
    '1CHR': '1CH',
    '2CHR': '2CH',
    'EZRA': 'EZR',
    'EZR': 'EZR',
    'NEH': 'NEH',
    'ESTH': 'EST',
    'EST': 'EST',
    'JOB': 'JOB',
    'PS': 'PSA',
    'PSA': 'PSA',
    'PROV': 'PRO',
    'PRO': 'PRO',
    'ECCL': 'ECC',
    'ECC': 'ECC',
    'SONG': 'SNG',
    'SNG': 'SNG',
    'ISA': 'ISA',
    'JER': 'JER',
    'LAM': 'LAM',
    'EZEK': 'EZK',
    'EZK': 'EZK',
    'DAN': 'DAN',
    'HOS': 'HOS',
    'JOEL': 'JOL',
    'JOL': 'JOL',
    'AMOS': 'AMO',
    'AMO': 'AMO',
    'OBAD': 'OBA',
    'OBA': 'OBA',
    'JONAH': 'JON',
    'JON': 'JON',
    'MIC': 'MIC',
    'NAH': 'NAM',
    'NAM': 'NAM',
    'HAB': 'HAB',
    'ZEPH': 'ZEP',
    'ZEP': 'ZEP',
    'HAG': 'HAG',
    'ZECH': 'ZEC',
    'ZEC': 'ZEC',
    'MAL': 'MAL',
    'MATT': 'MAT',
    'MAT': 'MAT',
    'MARK': 'MRK',
    'MRK': 'MRK',
    'LUKE': 'LUK',
    'LUK': 'LUK',
    'JOHN': 'JHN',
    'JHN': 'JHN',
    'ACTS': 'ACT',
    'ACT': 'ACT',
    'ROM': 'ROM',
    '1COR': '1CO',
    '2COR': '2CO',
    'GAL': 'GAL',
    'EPH': 'EPH',
    'PHIL': 'PHP',
    'PHP': 'PHP',
    'COL': 'COL',
    '1THESS': '1TH',
    '2THESS': '2TH',
    '1TIM': '1TI',
    '2TIM': '2TI',
    'TITUS': 'TIT',
    'TIT': 'TIT',
    'PHLM': 'PHM',
    'PHILEM': 'PHM',
    'HEB': 'HEB',
    'JAS': 'JAS',
    '1PET': '1PE',
    '2PET': '2PE',
    '1JOHN': '1JN',
    '2JOHN': '2JN',
    '3JOHN': '3JN',
    'JUDE': 'JUD',
    'JUD': 'JUD',
    'REV': 'REV',
  };

  return structuredBookIdMap[normalized.toUpperCase()];
}

/// Public helper to map book id to human name (used by the viewer title).
String bookIdToName(String bookId) {
  const map = {
    'GEN': 'Genesis',
    'EXO': 'Exodus',
    'LEV': 'Leviticus',
    'NUM': 'Numbers',
    'DEU': 'Deuteronomy',
    'JOS': 'Joshua',
    'JDG': 'Judges',
    'RUT': 'Ruth',
    '1SA': '1 Samuel',
    '2SA': '2 Samuel',
    '1KI': '1 Kings',
    '2KI': '2 Kings',
    '1CH': '1 Chronicles',
    '2CH': '2 Chronicles',
    'EZR': 'Ezra',
    'NEH': 'Nehemiah',
    'EST': 'Esther',
    'JOB': 'Job',
    'PSA': 'Psalms',
    'PRO': 'Proverbs',
    'ECC': 'Ecclesiastes',
    'SNG': 'Song of Songs',
    'ISA': 'Isaiah',
    'JER': 'Jeremiah',
    'LAM': 'Lamentations',
    'EZK': 'Ezekiel',
    'DAN': 'Daniel',
    'HOS': 'Hosea',
    'JOL': 'Joel',
    'AMO': 'Amos',
    'OBA': 'Obadiah',
    'JON': 'Jonah',
    'MIC': 'Micah',
    'NAM': 'Nahum',
    'HAB': 'Habakkuk',
    'ZEP': 'Zephaniah',
    'HAG': 'Haggai',
    'ZEC': 'Zechariah',
    'MAL': 'Malachi',
    'MAT': 'Matthew',
    'MRK': 'Mark',
    'LUK': 'Luke',
    'JHN': 'John',
    'ACT': 'Acts',
    'ROM': 'Romans',
    '1CO': '1 Corinthians',
    '2CO': '2 Corinthians',
    'GAL': 'Galatians',
    'EPH': 'Ephesians',
    'PHP': 'Philippians',
    'COL': 'Colossians',
    '1TH': '1 Thessalonians',
    '2TH': '2 Thessalonians',
    '1TI': '1 Timothy',
    '2TI': '2 Timothy',
    'TIT': 'Titus',
    'PHM': 'Philemon',
    'HEB': 'Hebrews',
    'JAS': 'James',
    '1PE': '1 Peter',
    '2PE': '2 Peter',
    '1JN': '1 John',
    '2JN': '2 John',
    '3JN': '3 John',
    'JUD': 'Jude',
    'REV': 'Revelation',
  };
  return map[bookId] ?? bookId;
}

BibleBookType getBookType(String bookId) {
  // This is a simplified list. You can expand it.
  const newTestamentIds = {
    'MAT',
    'MRK',
    'LUK',
    'JHN',
    'ACT',
    'ROM',
    '1CO',
    '2CO',
    'GAL',
    'EPH',
    'PHP',
    'COL',
    '1TH',
    '2TH',
    '1TI',
    '2TI',
    'TIT',
    'PHM',
    'HEB',
    'JAS',
    '1PE',
    '2PE',
    '1JN',
    '2JN',
    '3JN',
    'JUD',
    'REV',
  };
  return newTestamentIds.contains(bookId.toUpperCase())
      ? BibleBookType.newTestament
      : BibleBookType.oldTestament;
}
