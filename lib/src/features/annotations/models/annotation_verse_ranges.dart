import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';

/// A run of consecutive verses in one chapter of one translation, used to show
/// a multi-verse note as "Genesis 1:1-5" instead of five separate references.
///
/// Notes created from a reader selection store the first verse as the
/// annotation's primary verse and every other selected verse as a linked
/// verse, so without grouping a ten-verse note shows one heading and nine
/// chips (issues #50 / #82).
class AnnotationVerseRange {
  const AnnotationVerseRange(this.verses) : assert(verses.length > 0);

  /// The underlying links, in their stored order. Always non-empty.
  final List<AnnotationVerseLink> verses;

  AnnotationVerseLink get first => verses.first;
  String get bookId => first.bookId;
  int get chapter => first.chapter;
  int get startVerse => first.verse;
  int get endVerse => verses.last.verse;
  bool get isSingleVerse => verses.length == 1;

  /// `"<book> <chapter>:<start>"` or `"<book> <chapter>:<start>-<end>"`.
  String label(String bookName) => isSingleVerse
      ? '$bookName $chapter:$startVerse'
      : '$bookName $chapter:$startVerse-$endVerse';
}

/// Collapses runs of consecutive verses (same translation, book and chapter,
/// each verse exactly one after the previous) into [AnnotationVerseRange]s.
///
/// Order is preserved: only neighbours *in the given order* are merged, so a
/// hand-ordered list of linked verses is never reshuffled.
List<AnnotationVerseRange> groupConsecutiveVerses(
  Iterable<AnnotationVerseLink> links,
) {
  final ranges = <AnnotationVerseRange>[];
  var current = <AnnotationVerseLink>[];

  for (final link in links) {
    if (current.isNotEmpty && _continues(current.last, link)) {
      current.add(link);
      continue;
    }
    if (current.isNotEmpty) ranges.add(AnnotationVerseRange(current));
    current = [link];
  }
  if (current.isNotEmpty) ranges.add(AnnotationVerseRange(current));
  return ranges;
}

bool _continues(AnnotationVerseLink previous, AnnotationVerseLink next) =>
    next.translationId == previous.translationId &&
    next.bookId == previous.bookId &&
    next.chapter == previous.chapter &&
    next.verse == previous.verse + 1;

extension AnnotationVerseRangesX on UserAnnotation {
  /// Every verse of the note grouped into ranges. The first range always
  /// starts at [UserAnnotation.primaryVerse] and is the note's heading.
  List<AnnotationVerseRange> get verseRanges => groupConsecutiveVerses(allVerses);
}
