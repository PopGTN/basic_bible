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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerBuilder != null) headerBuilder!(),
        if (introBuilder != null) introBuilder!(),
        ...buildChapterBlocks(chapter),
        if (layoutMode == ReaderLayoutMode.verseList)
          ...chapter.verses.map(buildVerse)
        else
          buildDocumentView(),
      ],
    );
  }
}
