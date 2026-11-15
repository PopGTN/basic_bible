import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';

/// Parses every passage a source cross-reference points at.
///
/// Source labels are lists, not single references: `"Ps 33:6; 104:30"`,
/// `"Mat 5:3-5, 9; Luk 6:20"`, `"Gen 1:31–2:3"`. Treating them as one
/// `Book C:V` (the old behaviour) kept only the first verse and dropped
/// ranges entirely (issues #35 / #75).
///
/// A structured [target] (`"GEN.1.1-GEN.1.3"`, `"Matt.5.3 Luke.6.20"`) wins
/// when it parses; otherwise the human-readable [label] is used. Unparseable
/// fragments are skipped rather than failing the whole list.
List<BibleReferenceRange> parseReferenceRanges({
  String? target,
  required String label,
}) {
  final structured = parseStructuredReferenceRanges(target);
  if (structured.isNotEmpty) return structured;
  return parseReferenceRangeList(label);
}

/// Parses OSIS/USFX-style targets: space-separated items, each `B.C.V` or
/// `B.C.V-B.C.V` (the end may also be the bare `C.V` / `V`).
List<BibleReferenceRange> parseStructuredReferenceRanges(String? target) {
  if (target == null || target.trim().isEmpty) return const [];

  final ranges = <BibleReferenceRange>[];
  for (final item in target.trim().split(RegExp(r'\s+'))) {
    final bounds = item.split('-');
    final start = parseStructuredReferenceTarget(bounds.first);
    if (start == null) continue;
    if (bounds.length < 2) {
      ranges.add(BibleReferenceRange.single(start));
      continue;
    }

    final endParts = bounds[1].split('.');
    final endNumbers = endParts
        .map(int.tryParse)
        .whereType<int>()
        .toList(growable: false);
    int? endChapter;
    int? endVerse;
    if (endNumbers.length >= 2) {
      endChapter = endNumbers[endNumbers.length - 2];
      endVerse = endNumbers.last;
    } else if (endNumbers.length == 1) {
      endVerse = endNumbers.single;
    }
    ranges.add(
      BibleReferenceRange(
        start: start,
        endChapter: endChapter,
        endVerse: endVerse,
      ),
    );
  }
  return ranges;
}

// One list item: optional book, chapter, optional :verse, optional range end
// (`-V` or `-C:V`). Trailing verse-part letters ("5a") are tolerated.
final RegExp _itemPattern = RegExp(
  r'^(?:(?<book>(?:[1-3]\s*)?[A-Za-z][A-Za-z. ]*?)\s*)?'
  r'(?<c1>\d+)(?::(?<v1>\d+)[a-z]?)?'
  r'(?:\s*[-–—]\s*(?:(?<c2>\d+):)?(?<v2>\d+)[a-z]?)?$',
);

const _singleChapterBooks = {'OBA', 'PHM', '2JN', '3JN', 'JUD'};

/// Parses a human-readable reference list. Book and chapter carry forward:
/// after `"Ps 33:6"`, `"; 104:30"` stays in Psalms and `", 9"` means verse 9
/// of chapter 33.
List<BibleReferenceRange> parseReferenceRangeList(String label) {
  final ranges = <BibleReferenceRange>[];
  String? bookId;
  int? chapter;

  for (final group in label.split(';')) {
    var previousHadVerse = false;
    for (final rawItem in group.split(',')) {
      final item = rawItem.trim().replaceAll(RegExp(r'[.\s]+$'), '');
      if (item.isEmpty) continue;
      final match = _itemPattern.firstMatch(item);
      if (match == null) {
        previousHadVerse = false;
        continue;
      }

      final bookName = match.namedGroup('book');
      if (bookName != null && bookName.trim().isNotEmpty) {
        final resolved = resolveBookIdFromName(bookName);
        if (resolved == null) {
          // Unknown book: don't let later items inherit the wrong one.
          bookId = null;
          previousHadVerse = false;
          continue;
        }
        if (resolved != bookId) chapter = null;
        bookId = resolved;
      }
      final currentBook = bookId;
      if (currentBook == null) continue;

      final first = int.parse(match.namedGroup('c1')!);
      final verse = int.tryParse(match.namedGroup('v1') ?? '');
      final rangeChapter = int.tryParse(match.namedGroup('c2') ?? '');
      final rangeEnd = int.tryParse(match.namedGroup('v2') ?? '');
      final hasBook = bookName != null && bookName.trim().isNotEmpty;

      int startChapter;
      int? startVerse;
      if (verse != null) {
        startChapter = first;
        startVerse = verse;
      } else if (!hasBook && previousHadVerse && chapter != null) {
        // ", 9" after "33:6" -> verse 9 of the same chapter.
        startChapter = chapter;
        startVerse = first;
      } else if (_singleChapterBooks.contains(currentBook)) {
        // "Jude 3" -> Jude 1:3.
        startChapter = 1;
        startVerse = first;
      } else {
        // "Ps 23" or "; 24" -> whole chapter.
        startChapter = first;
        startVerse = null;
      }

      chapter = startChapter;
      previousHadVerse = startVerse != null;
      final start = BibleReference(
        bookId: currentBook,
        chapter: startChapter,
        verse: startVerse,
      );

      if (rangeEnd == null) {
        ranges.add(BibleReferenceRange.single(start));
      } else if (startVerse == null) {
        // "Ps 23-24" -> chapters 23 through 24.
        ranges.add(BibleReferenceRange(start: start, endChapter: rangeEnd));
        chapter = rangeEnd;
      } else {
        ranges.add(
          BibleReferenceRange(
            start: start,
            endChapter: rangeChapter ?? startChapter,
            endVerse: rangeEnd,
          ),
        );
        if (rangeChapter != null) chapter = rangeChapter;
      }
    }
  }
  return ranges;
}
