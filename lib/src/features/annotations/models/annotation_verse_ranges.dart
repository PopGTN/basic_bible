import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

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

  /// The whole range as a passage, for previewing / opening all its verses.
  BibleReferenceRange get passage => BibleReferenceRange(
    start: first.reference,
    endVerse: isSingleVerse ? null : endVerse,
  );

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

/// [links] in reading order (book, chapter, verse; then translation), for
/// display. Stored order is whatever order verses were tapped in, which
/// scattered a passage like Luke 15:1-32 into 31 separate chips.
List<AnnotationVerseLink> sortVerseLinksInReadingOrder(
  Iterable<AnnotationVerseLink> links,
) {
  final sorted = links.toList();
  sorted.sort((a, b) {
    final byReference = compareReferencesInReadingOrder(
      a.reference,
      b.reference,
    );
    return byReference != 0
        ? byReference
        : a.translationId.compareTo(b.translationId);
  });
  return sorted;
}

extension AnnotationVerseRangesX on UserAnnotation {
  /// Every verse of the note, in reading order, grouped into ranges. The
  /// first range is the one containing [UserAnnotation.primaryVerse] — the
  /// note's heading — and the rest follow in reading order.
  List<AnnotationVerseRange> get verseRanges {
    final ranges = groupConsecutiveVerses(
      sortVerseLinksInReadingOrder(allVerses),
    );
    final headingIndex = ranges.indexWhere(
      (range) => range.verses.contains(primaryVerse),
    );
    if (headingIndex <= 0) return ranges;
    return [ranges[headingIndex], ...ranges]..removeAt(headingIndex + 1);
  }
}
