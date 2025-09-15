// lib/src/services/usfx_parser.dart
import 'dart:convert';
import 'package:xml/xml.dart';
import '../models/bibleModels/bibleBook.dart';
import '../models/bibleModels/bibleChapter.dart';
import '../models/bibleModels/bibleVersus.dart';
import '../models/bible_models.dart';

class USFXParser {
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

  static List<BibleBook> parseUSFX(String usfxContent) {
    try {
      final document = XmlDocument.parse(usfxContent);
      final usfx = document.findElements('usfx').first;

      final List<BibleBook> books = [];

      for (final bookElement in usfx.findElements('book')) {
        final bookId = bookElement.getAttribute('id') ?? '';
        final book = _parseBook(bookElement, bookId);
        if (book != null) {
          books.add(book);
        }
      }

      return books;
    } catch (e) {
      throw Exception('Failed to parse USFX: $e');
    }
  }

  static BibleBook? _parseBook(XmlElement bookElement, String bookId) {
    final bookName = _bookNames[bookId] ?? bookId;
    final bookNumber = _getBookNumber(bookId);

    final List<BibleChapter> chapters = [];
    int currentChapter = 0;
    List<BibleVerse> currentVerses = [];

    for (final child in bookElement.children) {
      if (child is XmlElement) {
        switch (child.name.local) {
          case 'c':
          // Save previous chapter if exists
            if (currentChapter > 0) {
              chapters.add(BibleChapter(
                number: currentChapter,
                verses: List.from(currentVerses),
              ));
            }

            // Start new chapter
            currentChapter = int.tryParse(child.getAttribute('n') ?? '1') ?? 1;
            currentVerses.clear();
            break;

          case 'v':
            final verseNumber = int.tryParse(child.getAttribute('n') ?? '1') ?? 1;
            final verseText = _extractText(child);

            if (verseText.isNotEmpty) {
              currentVerses.add(BibleVerse(
                number: verseNumber,
                text: verseText.trim(),
              ));
            }
            break;

          case 'p':
          case 'q':
          case 'm':
          // Handle paragraph markers - extract any verses within
            _extractVersesFromElement(child, currentVerses);
            break;
        }
      }
    }

    // Add the last chapter
    if (currentChapter > 0) {
      chapters.add(BibleChapter(
        number: currentChapter,
        verses: List.from(currentVerses),
      ));
    }

    if (chapters.isEmpty) return null;

    return BibleBook(
      id: bookId,
      name: bookName,
      shortName: _getShortName(bookName),
      bookNumber: bookNumber,
      chapters: chapters,
    );
  }

  static void _extractVersesFromElement(XmlElement element, List<BibleVerse> verses) {
    for (final child in element.children) {
      if (child is XmlElement && child.name.local == 'v') {
        final verseNumber = int.tryParse(child.getAttribute('n') ?? '1') ?? 1;
        final verseText = _extractText(child);

        if (verseText.isNotEmpty) {
          verses.add(BibleVerse(
            number: verseNumber,
            text: verseText.trim(),
          ));
        }
      }
    }
  }

  static String _extractText(XmlElement element) {
    final buffer = StringBuffer();

    for (final node in element.nodes) {
      if (node is XmlText) {
        buffer.write(node.text);
      } else if (node is XmlElement) {
        // Skip footnotes and cross-references for now
        if (!['f', 'x'].contains(node.name.local)) {
          buffer.write(_extractText(node));
        }
      }
    }

    return buffer.toString();
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
}
