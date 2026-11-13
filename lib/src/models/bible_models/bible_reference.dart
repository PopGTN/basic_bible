import 'package:equatable/equatable.dart';

class BibleReference extends Equatable {
  final String bookId;
  final int chapter;
  final int? verse;

  const BibleReference({
    required this.bookId,
    required this.chapter,
    this.verse,
  });

  @override
  String toString() {
    if (verse != null) {
      return '$bookId $chapter:$verse';
    }
    return '$bookId $chapter';
  }

  @override
  List<Object?> get props => [bookId, chapter, verse];
}

/// A contiguous passage such as `MAT 5:3-5`, `GEN 1:31-2:3` or a whole
/// chapter (`PSA 23`, [start.verse] == null).
///
/// Cross-reference labels routinely point at several passages and ranges
/// ("Ps 33:6; 104:30", "Mat 5:3-5"); modelling a single [BibleReference] lost
/// everything but the first verse (issues #35 / #75).
class BibleReferenceRange extends Equatable {
  const BibleReferenceRange({
    required this.start,
    int? endChapter,
    this.endVerse,
  }) : _endChapter = endChapter;

  /// A one-verse (or whole-chapter) range.
  const BibleReferenceRange.single(this.start)
    : _endChapter = null,
      endVerse = null;

  final BibleReference start;
  final int? _endChapter;

  /// Last chapter of the range; equals [start]'s chapter unless the range
  /// crosses a chapter boundary.
  int get endChapter => _endChapter ?? start.chapter;

  /// Last verse of the range, or null when the range ends on [start]'s verse
  /// (or covers whole chapters when [start] has no verse).
  final int? endVerse;

  String get bookId => start.bookId;

  bool get isWholeChapter => start.verse == null;

  bool get isSingleVerse =>
      start.verse != null &&
      endChapter == start.chapter &&
      (endVerse == null || endVerse == start.verse);

  /// Whether [chapter]:[verse] falls inside this range.
  bool contains(int chapter, int verse) {
    if (chapter < start.chapter || chapter > endChapter) return false;
    final startVerse = start.verse;
    if (startVerse == null) return true;
    if (chapter == start.chapter && verse < startVerse) return false;
    if (chapter == endChapter) {
      final last = endVerse ?? (endChapter == start.chapter ? startVerse : null);
      if (last != null && verse > last) return false;
    }
    return true;
  }

  /// `"<book> 5:3"`, `"<book> 5:3-5"`, `"<book> 1:31-2:3"` or `"<book> 23"`.
  String label(String bookName) {
    final startVerse = start.verse;
    if (startVerse == null) {
      return endChapter == start.chapter
          ? '$bookName ${start.chapter}'
          : '$bookName ${start.chapter}-$endChapter';
    }
    final head = '$bookName ${start.chapter}:$startVerse';
    if (isSingleVerse) return head;
    if (endChapter != start.chapter) return '$head-$endChapter:${endVerse ?? 1}';
    return '$head-$endVerse';
  }

  @override
  String toString() => label(bookId);

  @override
  List<Object?> get props => [start, endChapter, endVerse];
}
