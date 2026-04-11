part of 'bible_viewer_tab.dart';

class _ParagraphSection {
  const _ParagraphSection({required this.leadingBlocks, required this.verses});

  final List<BibleDocumentBlock> leadingBlocks;
  final List<BibleVerse> verses;
}

class _ContinuousChapterSection {
  const _ContinuousChapterSection({required this.book, required this.chapter});

  final BibleBook book;
  final BibleChapter chapter;
}

/// Interleaves inline section headings between the verse widgets they precede.
///
/// Scans [chapter.blocks] for heading blocks that carry a `beforeVerse` key,
/// then inserts the result of [buildInlineHeading] immediately before the
/// matching verse widget. Verses with no preceding heading are passed directly
/// to [buildVerse] with no wrapping.
List<Widget> _interleaveVerseListWithHeadings({
  required BibleChapter chapter,
  required Widget Function(BibleVerse) buildVerse,
  required Widget Function(BibleDocumentBlock) buildInlineHeading,
}) {
  final headingsByVerse = <int, List<BibleDocumentBlock>>{};
  for (final block in chapter.blocks) {
    if (block.kind != BibleDocumentBlockKind.heading) continue;
    final beforeVerse = int.tryParse(block.metadata['beforeVerse'] ?? '');
    if (beforeVerse == null) continue;
    headingsByVerse
        .putIfAbsent(beforeVerse, () => <BibleDocumentBlock>[])
        .add(block);
  }

  if (headingsByVerse.isEmpty) {
    return chapter.verses.map(buildVerse).toList();
  }

  final widgets = <Widget>[];
  for (final verse in chapter.verses) {
    final headings = headingsByVerse[verse.number];
    if (headings != null) {
      for (final heading in headings) {
        widgets.add(buildInlineHeading(heading));
      }
    }
    widgets.add(buildVerse(verse));
  }
  return widgets;
}

class _ChapterSectionView extends StatelessWidget {
  const _ChapterSectionView({
    required this.book,
    required this.chapter,
    required this.reference,
    required this.fontSize,
    required this.layoutMode,
    required this.buildChapterBlocks,
    required this.buildVerse,
    required this.buildDocumentView,
    this.introBuilder,
    this.headerBuilder,
    this.buildInlineHeading,
  });

  final BibleBook book;
  final BibleChapter chapter;
  final BibleReference reference;
  final double fontSize;
  final ReaderLayoutMode layoutMode;
  final List<Widget> Function(BibleChapter chapter) buildChapterBlocks;
  final Widget Function(BibleVerse verse) buildVerse;
  final Widget Function() buildDocumentView;
  final Widget Function()? introBuilder;
  final Widget Function()? headerBuilder;
  /// Called for each heading block that precedes a specific verse in
  /// verse-list mode. If null, inline headings are not rendered.
  final Widget Function(BibleDocumentBlock block)? buildInlineHeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerBuilder != null) headerBuilder!(),
        if (introBuilder != null) introBuilder!(),
        ...buildChapterBlocks(chapter),
        if (layoutMode == ReaderLayoutMode.verseList)
          ..._verseList()
        else
          buildDocumentView(),
      ],
    );
  }

  List<Widget> _verseList() {
    final headingBuilder = buildInlineHeading;
    if (headingBuilder == null) {
      return chapter.verses.map(buildVerse).toList();
    }
    return _interleaveVerseListWithHeadings(
      chapter: chapter,
      buildVerse: buildVerse,
      buildInlineHeading: headingBuilder,
    );
  }
}
