import 'package:basic_bible/src/models/bibleModels/bibleBookHelper.dart';

class BibleReference {
  final String bookId;
  final int chapter;
  final int? verse;
  final int? endVerse; // For verse ranges

  BibleReference({
    required this.bookId,
    required this.chapter,
    this.verse,
    this.endVerse,
  });

  @override
  String toString() {
    if (verse != null) {
      if (endVerse != null && endVerse != verse) {
        return '$bookId $chapter:$verse-$endVerse';
      }
      return '$bookId $chapter:$verse';
    }
    return '$bookId $chapter';
  }

  String toDisplayString() {
    final bookName = BibleBookHelper.getBookName(bookId);
    if (verse != null) {
      if (endVerse != null && endVerse != verse) {
        return '$bookName $chapter:$verse-$endVerse';
      }
      return '$bookName $chapter:$verse';
    }
    return '$bookName $chapter';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BibleReference &&
        other.bookId == bookId &&
        other.chapter == chapter &&
        other.verse == verse &&
        other.endVerse == endVerse;
  }

  @override
  int get hashCode => bookId.hashCode ^ chapter.hashCode ^ verse.hashCode ^ endVerse.hashCode;
}
