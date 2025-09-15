// lib/src/services/usfm_parser.dart
import '../models/bibleModels/bibleBook.dart';
import '../models/bibleModels/bibleChapter.dart';
import '../models/bibleModels/bibleVersus.dart';
import '../models/bible_models.dart';

class USFMParser {
  static const Map<String, String> _bookNames = {
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

  static List<BibleBook> parseUSFM(String usfmContent) {
    try {
      final List<BibleBook> books = [];

      // Split content into individual books if multiple books are present
      final bookSections = _splitIntoBooks(usfmContent);

      for (final bookSection in bookSections) {
        final book = _parseBook(bookSection);
        if (book != null) {
          books.add(book);
        }
      }

      return books;
    } catch (e) {
      throw Exception('Failed to parse USFM: $e');
    }
  }

  static List<String> _splitIntoBooks(String content) {
    final books = <String>[];
    final lines = content.split('\n');
    String currentBook = '';

    for (final line in lines) {
      if (line.trim().startsWith('\\id ')) {
        // New book starts
        if (currentBook.isNotEmpty) {
          books.add(currentBook);
        }
        currentBook = line + '\n';
      } else {
        currentBook += line + '\n';
      }
    }

    // Add the last book
    if (currentBook.isNotEmpty) {
      books.add(currentBook);
    }

    return books;
  }

  static BibleBook? _parseBook(String bookContent) {
    final lines = bookContent.split('\n');
    String bookId = '';
    String bookName = '';
    int bookNumber = 0;

    final List<BibleChapter> chapters = [];
    int currentChapter = 0;
    List<BibleVerse> currentVerses = [];
    int currentVerseNumber = 0;
    StringBuffer currentVerseText = StringBuffer();

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      // Book identification
      if (trimmedLine.startsWith('\\id ')) {
        bookId = trimmedLine.substring(4).split(' ')[0].toUpperCase();
        bookName = _bookNames[bookId] ?? bookId;
        bookNumber = _getBookNumber(bookId);
        continue;
      }

      // Book title (alternative identification)
      if (trimmedLine.startsWith('\\h ')) {
        if (bookName.isEmpty) {
          bookName = trimmedLine.substring(3);
        }
        continue;
      }

      // Chapter markers
      if (trimmedLine.startsWith('\\c ')) {
        // Save previous chapter if exists
        if (currentChapter > 0) {
          _addCurrentVerse(currentVerses, currentVerseNumber, currentVerseText);
          chapters.add(BibleChapter(
            number: currentChapter,
            verses: List.from(currentVerses),
          ));
        }

        // Start new chapter
        currentChapter = int.tryParse(trimmedLine.substring(3)) ?? 1;
        currentVerses.clear();
        currentVerseNumber = 0;
        currentVerseText.clear();
        continue;
      }

      // Verse markers
      if (trimmedLine.startsWith('\\v ')) {
        // Save previous verse if exists
        _addCurrentVerse(currentVerses, currentVerseNumber, currentVerseText);

        // Start new verse
        final verseData = trimmedLine.substring(3);
        final spaceIndex = verseData.indexOf(' ');

        if (spaceIndex > 0) {
          currentVerseNumber = int.tryParse(verseData.substring(0, spaceIndex)) ?? 1;
          currentVerseText.clear();
          currentVerseText.write(verseData.substring(spaceIndex + 1));
        } else {
          currentVerseNumber = int.tryParse(verseData) ?? 1;
          currentVerseText.clear();
        }
        continue;
      }

      // Skip certain markers but continue processing
      if (_shouldSkipMarker(trimmedLine)) {
        continue;
      }

      // Handle paragraph and formatting markers
      if (trimmedLine.startsWith('\\')) {
        final processedText = _processFormattingMarkers(trimmedLine);
        if (processedText.isNotEmpty) {
          if (currentVerseText.isNotEmpty) {
            currentVerseText.write(' ');
          }
          currentVerseText.write(processedText);
        }
        continue;
      }

      // Regular text continuation
      if (currentVerseNumber > 0) {
        if (currentVerseText.isNotEmpty) {
          currentVerseText.write(' ');
        }
        currentVerseText.write(trimmedLine);
      }
    }

    // Add the last verse and chapter
    if (currentChapter > 0) {
      _addCurrentVerse(currentVerses, currentVerseNumber, currentVerseText);
      chapters.add(BibleChapter(
        number: currentChapter,
        verses: List.from(currentVerses),
      ));
    }

    if (bookId.isEmpty || chapters.isEmpty) return null;

    return BibleBook(
      id: bookId,
      name: bookName,
      shortName: _getShortName(bookName),
      bookNumber: bookNumber,
      chapters: chapters,
    );
  }

  static void _addCurrentVerse(List<BibleVerse> verses, int verseNumber, StringBuffer verseText) {
    if (verseNumber > 0 && verseText.isNotEmpty) {
      final cleanText = _cleanVerseText(verseText.toString());
      if (cleanText.isNotEmpty) {
        verses.add(BibleVerse(
          number: verseNumber,
          text: cleanText,
        ));
      }
    }
  }

  static bool _shouldSkipMarker(String line) {
    final markers = [
      '\\ide', '\\usfm', '\\rem', '\\sts', '\\restore',
      '\\h1', '\\h2', '\\h3', '\\toc1', '\\toc2', '\\toc3',
      '\\mt1', '\\mt2', '\\mt3', '\\mt4', '\\imt1', '\\imt2',
      '\\is1', '\\is2', '\\ip', '\\ipi', '\\im', '\\imi',
      '\\iot', '\\io1', '\\io2', '\\ior', '\\s1', '\\s2',
      '\\s3', '\\s4', '\\sr', '\\r', '\\d', '\\sp', '\\cl'
    ];

    return markers.any((marker) => line.startsWith(marker));
  }

  static String _processFormattingMarkers(String line) {
    String text = line;

    // Handle paragraph markers
    if (text.startsWith('\\p ') || text.startsWith('\\m ') ||
        text.startsWith('\\q ') || text.startsWith('\\q1 ') ||
        text.startsWith('\\q2 ') || text.startsWith('\\q3 ')) {
      return text.substring(text.indexOf(' ') + 1);
    }

    // Handle other markers that contain text
    if (text.startsWith('\\')) {
      final spaceIndex = text.indexOf(' ');
      if (spaceIndex > 0) {
        return text.substring(spaceIndex + 1);
      }
    }

    return '';
  }

  static String _cleanVerseText(String text) {
    String cleaned = text;

    // Remove common USFM formatting markers
    cleaned = cleaned.replaceAll(RegExp(r'\\f\s.*?\\f\*'), ''); // Remove footnotes
    cleaned = cleaned.replaceAll(RegExp(r'\\x\s.*?\\x\*'), ''); // Remove cross-references
    cleaned = cleaned.replaceAll(RegExp(r'\\add\s(.*?)\\add\*'), r'$1'); // Handle additions
    cleaned = cleaned.replaceAll(RegExp(r'\\nd\s(.*?)\\nd\*'), r'$1'); // Handle name of deity
    cleaned = cleaned.replaceAll(RegExp(r'\\wj\s(.*?)\\wj\*'), r'$1'); // Handle words of Jesus
    cleaned = cleaned.replaceAll(RegExp(r'\\qt\s(.*?)\\qt\*'), r'"$1"'); // Handle quoted text
    cleaned = cleaned.replaceAll(RegExp(r'\\it\s(.*?)\\it\*'), r'$1'); // Handle italics
    cleaned = cleaned.replaceAll(RegExp(r'\\bd\s(.*?)\\bd\*'), r'$1'); // Handle bold
    cleaned = cleaned.replaceAll(RegExp(r'\\bk\s(.*?)\\bk\*'), r'$1'); // Handle book names
    cleaned = cleaned.replaceAll(RegExp(r'\\pn\s(.*?)\\pn\*'), r'$1'); // Handle proper names

    // Remove any remaining USFM markers
    cleaned = cleaned.replaceAll(RegExp(r'\\[a-zA-Z0-9]+\*?'), '');

    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  static int _getBookNumber(String bookId) {
    final bookOrder = _bookNames.keys.toList();
    final index = bookOrder.indexOf(bookId);
    return index >= 0 ? index + 1 : 999;
  }

  static String _getShortName(String fullName) {
    // Simple abbreviation logic
    final words = fullName.split(' ');
    if (words.length == 1) {
      return words[0].length > 3 ? words[0].substring(0, 3) : words[0];
    } else if (words.length == 2) {
      if (words[0].length <= 2) {
        return '${words[0]} ${words[1].substring(0, 3)}';
      } else {
        return '${words[0].substring(0, 3)} ${words[1].substring(0, 3)}';
      }
    }
    return fullName.substring(0, 6);
  }

  // Utility method to detect if content is USFM format
  static bool isUSFM(String content) {
    final lines = content.split('\n');
    for (final line in lines.take(20)) { // Check first 20 lines
      final trimmed = line.trim();
      if (trimmed.startsWith('\\id ') ||
          trimmed.startsWith('\\c ') ||
          trimmed.startsWith('\\v ') ||
          trimmed.startsWith('\\usfm')) {
        return true;
      }
    }
    return false;
  }
}