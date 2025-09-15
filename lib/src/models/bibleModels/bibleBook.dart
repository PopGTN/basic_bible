import 'package:basic_bible/src/models/bibleModels/bibleChapter.dart';

enum BibleBookType {
  oldTestament,
  newTestament,
  deuterocanonical,
  other,
}

class BibleBook {
  final String id;
  final String name;
  final String shortName;
  final int bookNumber;
  final List<BibleChapter> chapters;
  final BibleBookType bookType;

  BibleBook({
    required this.id,
    required this.name,
    required this.shortName,
    required this.bookNumber,
    this.chapters = const [],
    this.bookType = BibleBookType.other,
  });

  BibleBook copyWith({
    String? id,
    String? name,
    String? shortName,
    int? bookNumber,
    List<BibleChapter>? chapters,
    BibleBookType? bookType,
  }) {
    return BibleBook(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      bookNumber: bookNumber ?? this.bookNumber,
      chapters: chapters ?? this.chapters,
      bookType: bookType ?? this.bookType,
    );
  }
}
