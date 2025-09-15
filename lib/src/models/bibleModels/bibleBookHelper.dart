import 'package:basic_bible/src/models/bibleModels/bibleBook.dart';

class BibleBookHelper {
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

  static const Set<String> _oldTestamentBooks = {
    'GEN', 'EXO', 'LEV', 'NUM', 'DEU', 'JOS', 'JDG', 'RUT',
    '1SA', '2SA', '1KI', '2KI', '1CH', '2CH', 'EZR', 'NEH',
    'EST', 'JOB', 'PSA', 'PRO', 'ECC', 'SNG', 'ISA', 'JER',
    'LAM', 'EZK', 'DAN', 'HOS', 'JOL', 'AMO', 'OBA', 'JON',
    'MIC', 'NAM', 'HAB', 'ZEP', 'HAG', 'ZEC', 'MAL',
  };

  static String getBookName(String bookId) {
    return _bookNames[bookId] ?? bookId;
  }

  static BibleBookType getBookType(String bookId) {
    if (_oldTestamentBooks.contains(bookId)) {
      return BibleBookType.oldTestament;
    } else if (_bookNames.containsKey(bookId)) {
      return BibleBookType.newTestament;
    }
    return BibleBookType.other;
  }

  static int getBookNumber(String bookId) {
    final bookOrder = _bookNames.keys.toList();
    final index = bookOrder.indexOf(bookId);
    return index >= 0 ? index + 1 : 999;
  }

  static String getShortName(String fullName) {
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

  static List<String> getAllBookIds() {
    return _bookNames.keys.toList();
  }

  static List<String> getOldTestamentBooks() {
    return _oldTestamentBooks.toList();
  }

  static List<String> getNewTestamentBooks() {
    return _bookNames.keys.where((id) => !_oldTestamentBooks.contains(id)).toList();
  }
}