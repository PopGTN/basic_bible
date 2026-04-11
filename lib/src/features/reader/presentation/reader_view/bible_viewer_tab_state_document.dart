part of 'bible_viewer_tab.dart';

extension _BibleTextViewStateDocument on _BibleTextViewState {
  Widget _buildDocumentReadingView(BuildContext context) {
    final sections = _buildParagraphSectionsForChapter(widget.chapter);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final block in section.leadingBlocks)
                    if (block.text.trim().isNotEmpty)
                      _DocumentBlockView(
                        block: block,
                        fontSize: widget.fontSize,
                      ),
                  _isDocumentPoetrySection(section)
                      ? _buildDocumentPoetrySection(
                          context,
                          widget.book.id,
                          widget.chapter.number,
                          section,
                        )
                      : _buildDocumentParagraphSection(
                          context,
                          widget.book.id,
                          widget.chapter.number,
                          section,
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentReadingViewForChapter(
    BuildContext context,
    String bookId,
    BibleChapter chapter,
  ) {
    final sections = _buildParagraphSectionsForChapter(chapter);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final block in section.leadingBlocks)
                    if (block.text.trim().isNotEmpty)
                      _DocumentBlockView(
                        block: block,
                        fontSize: widget.fontSize,
                      ),
                  _isDocumentPoetrySection(section)
                      ? _buildDocumentPoetrySection(
                          context,
                          bookId,
                          chapter.number,
                          section,
                        )
                      : _buildDocumentParagraphSection(
                          context,
                          bookId,
                          chapter.number,
                          section,
                        ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_ParagraphSection> _buildParagraphSectionsForChapter(
    BibleChapter chapter,
  ) {
    if (chapter.verses.isEmpty) return const [];

    final paragraphBlocksByVerse = <int, List<BibleDocumentBlock>>{};
    for (final block in chapter.blocks) {
      // Include paragraph/poetry blocks and heading blocks that carry a
      // `beforeVerse` annotation — headings without one are rendered by
      // _visibleChapterSupportBlocks at the chapter top instead.
      final isInlineHeading =
          block.kind == BibleDocumentBlockKind.heading &&
          block.metadata.containsKey('beforeVerse');
      if (block.kind != BibleDocumentBlockKind.paragraph &&
          block.kind != BibleDocumentBlockKind.poetry &&
          !isInlineHeading) {
        continue;
      }
      final beforeVerse = int.tryParse(block.metadata['beforeVerse'] ?? '');
      if (beforeVerse == null) continue;
      paragraphBlocksByVerse
          .putIfAbsent(beforeVerse, () => <BibleDocumentBlock>[])
          .add(block);
    }

    if (paragraphBlocksByVerse.isEmpty) {
      return [
        _ParagraphSection(leadingBlocks: const [], verses: chapter.verses),
      ];
    }

    final sections = <_ParagraphSection>[];
    final firstVerseNumber = chapter.verses.first.number;
    var currentLeadingBlocks = List<BibleDocumentBlock>.from(
      paragraphBlocksByVerse[firstVerseNumber] ?? const [],
    );
    var currentVerses = <BibleVerse>[];

    for (final verse in chapter.verses) {
      final paragraphStartBlocks = paragraphBlocksByVerse[verse.number];
      if (paragraphStartBlocks != null && currentVerses.isNotEmpty) {
        // Start a new rendered paragraph only when the source says the next
        // verse begins a new paragraph. This keeps paragraph mode tied to the
        // imported document structure instead of a UI-only guess.
        sections.add(
          _ParagraphSection(
            leadingBlocks: currentLeadingBlocks,
            verses: currentVerses,
          ),
        );
        currentLeadingBlocks = List<BibleDocumentBlock>.from(
          paragraphStartBlocks,
        );
        currentVerses = <BibleVerse>[];
      }
      currentVerses.add(verse);
    }

    if (currentVerses.isNotEmpty) {
      sections.add(
        _ParagraphSection(
          leadingBlocks: currentLeadingBlocks,
          verses: currentVerses,
        ),
      );
    }

    return sections;
  }

  Widget _buildDocumentParagraphSection(
    BuildContext context,
    String bookId,
    int chapterNumber,
    _ParagraphSection section,
  ) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: widget.fontSize,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          height: 1.7,
        ),
        children: [
          const WidgetSpan(
            child: SizedBox(width: 18),
            alignment: PlaceholderAlignment.middle,
          ),
          for (final verse in section.verses) ...[
            WidgetSpan(
              child: SizedBox(
                key: _verseKey(bookId, chapterNumber, verse.number),
                width: 0,
                height: 0,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _InlineVerseSelector(
                  verseNumber: verse.number,
                  color: _verseNumberColor(
                    context,
                    bookId,
                    chapterNumber,
                    verse,
                  ),
                  isSelected: _isSelectedVerse(bookId, chapterNumber, verse),
                  hasNote: false,
                  inlineOnly: true,
                  onTap: () => _selectVerse(bookId, chapterNumber, verse),
                ),
              ),
            ),
            ..._buildVerseContentSpans(
              context,
              verse,
              bodyColor: _verseTextColor(context, bookId, chapterNumber, verse),
              isSelectedVerse: _isSelectedVerse(bookId, chapterNumber, verse),
              backgroundColor: _docVerseHighlightColor(
                context,
                bookId,
                chapterNumber,
                verse,
              ),
              recognizer: _verseTapRecognizer(bookId, chapterNumber, verse),
            ),
            if (_docVerseHasPersonalNotes(bookId, chapterNumber, verse))
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 2),
                  child: _VerseNoteButton(
                    compact: true,
                    onPressed: () => _showPersonalNotesSheet(
                      context,
                      bookId: bookId,
                      chapterNumber: chapterNumber,
                      verse: verse,
                      verseAnnotations: _annotationsForVerse(
                        bookId,
                        chapterNumber,
                        verse,
                      ),
                    ),
                  ),
                ),
              ),
            if (_hasParserNotes(verse))
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 2),
                  child: _VerseAnnotationButton(
                    compact: true,
                    onPressed: () =>
                        _showVerseDetailsSheet(context, chapterNumber, verse),
                  ),
                ),
              ),
            const TextSpan(text: ' '),
          ],
          const TextSpan(text: ' '),
        ],
      ),
    );
  }

  Widget _buildDocumentPoetrySection(
    BuildContext context,
    String bookId,
    int chapterNumber,
    _ParagraphSection section,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final verse in section.verses)
          Padding(
            key: _verseKey(bookId, chapterNumber, verse.number),
            padding: EdgeInsets.only(
              bottom: _joinsHighlightedRunWithNext(bookId, chapterNumber, verse)
                  ? 0
                  : 8,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _selectVerse(bookId, chapterNumber, verse),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.7,
                    ),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: _InlineVerseSelector(
                            verseNumber: verse.number,
                            color: _verseNumberColor(
                              context,
                              bookId,
                              chapterNumber,
                              verse,
                            ),
                            isSelected: _isSelectedVerse(
                              bookId,
                              chapterNumber,
                              verse,
                            ),
                            hasNote: false,
                            inlineOnly: true,
                            onTap: () =>
                                _selectVerse(bookId, chapterNumber, verse),
                          ),
                        ),
                      ),
                      ..._buildVerseContentSpans(
                        context,
                        verse,
                        bodyColor: _verseTextColor(
                          context,
                          bookId,
                          chapterNumber,
                          verse,
                        ),
                        isSelectedVerse: _isSelectedVerse(
                          bookId,
                          chapterNumber,
                          verse,
                        ),
                        backgroundColor: _docVerseHighlightColor(
                          context,
                          bookId,
                          chapterNumber,
                          verse,
                        ),
                        recognizer: _verseTapRecognizer(
                          bookId,
                          chapterNumber,
                          verse,
                        ),
                      ),
                      if (_docVerseHasPersonalNotes(
                        bookId,
                        chapterNumber,
                        verse,
                      ))
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _VerseNoteButton(
                              compact: true,
                              onPressed: () => _showPersonalNotesSheet(
                                context,
                                bookId: bookId,
                                chapterNumber: chapterNumber,
                                verse: verse,
                                verseAnnotations: _annotationsForVerse(
                                  bookId,
                                  chapterNumber,
                                  verse,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_hasParserNotes(verse))
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _VerseAnnotationButton(
                              compact: true,
                              onPressed: () => _showVerseDetailsSheet(
                                context,
                                chapterNumber,
                                verse,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _isDocumentPoetrySection(_ParagraphSection section) {
    if (section.leadingBlocks.any(
      (block) => block.kind == BibleDocumentBlockKind.poetry,
    )) {
      return true;
    }

    for (final verse in section.verses) {
      for (final span in verse.spans) {
        if (span.kind == BibleVerseSpanKind.poetry ||
            span.kind == BibleVerseSpanKind.quote ||
            span.metadata.containsKey('quoteLevel')) {
          return true;
        }
      }
    }

    return false;
  }
}
