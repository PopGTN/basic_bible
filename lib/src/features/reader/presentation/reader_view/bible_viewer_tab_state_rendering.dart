part of 'bible_viewer_tab.dart';

extension _BibleTextViewStateRendering on _BibleTextViewState {
  void _queueVisibleChapterSync(BuildContext context) {
    if (_visibleSyncQueued) return;
    _visibleSyncQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Continuous mode can emit many scroll updates per frame. Coalescing the
      // visible-chapter scan keeps the floating reference bar responsive
      // without repeatedly traversing the whole set of mounted sections.
      _visibleSyncQueued = false;
      if (!mounted) return;
      _syncVisibleChapterFromViewport(context);
    });
  }

  Widget _buildSingleChapterView(BuildContext context) {
    final contentWidgets = <Widget>[
      _buildChapterHeader(context),
      ..._buildBookIntroductionBlocks(
        context,
        showForCurrentSection: widget.chapter.number == 1,
      ),
      ..._buildChapterBlocks(context),
      if (widget.layoutMode == ReaderLayoutMode.verseList)
        ..._buildVerseListWithInlineHeadings(context, widget.chapter)
      else
        _buildDocumentReadingView(context),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        // Keep the last verses and chapter blocks clear of the floating
        // bottom reference bar on every layout size, not only on phones.
        bottom: widget.bottomOverlayPadding,
      ),
      child: ListView.builder(
        controller: widget.controller,
        itemCount: contentWidgets.length,
        itemBuilder: (context, index) => contentWidgets[index],
      ),
    );
  }

  Widget _buildChapterHeader(BuildContext context) {
    return _buildCenteredChapterHeader(
      context,
      bookName: preferredBookName(widget.book),
      chapterNumber: widget.reference.chapter,
    );
  }

  List<Widget> _buildBookIntroductionBlocks(
    BuildContext context, {
    required bool showForCurrentSection,
  }) {
    return _buildBookIntroductionBlocksForBook(
      context,
      widget.book,
      showForCurrentSection: showForCurrentSection,
    );
  }

  List<Widget> _buildBookIntroductionBlocksForBook(
    BuildContext context,
    BibleBook book, {
    required bool showForCurrentSection,
  }) {
    final visibleBlocks = book.introductionBlocks
        .where((block) => block.text.trim().isNotEmpty)
        .toList();
    if (!widget.showBookIntroductions ||
        !showForCurrentSection ||
        visibleBlocks.isEmpty) {
      return const [];
    }

    // Book introductions are only shown at the start of the book to avoid
    // repeating long front-matter blocks on every chapter view.
    return [
      _DocumentBlockSection(
        title: preferredBookName(book),
        eyebrow: 'Introduction',
        blocks: visibleBlocks,
        fontSize: widget.fontSize,
      ),
    ];
  }

  List<Widget> _buildChapterBlocks(BuildContext context) {
    return _buildChapterBlocksFor(context, widget.chapter);
  }

  Widget _buildVerse(BuildContext context, BibleVerse verse) {
    return _buildVerseCard(
      context,
      bookId: widget.book.id,
      chapterNumber: widget.chapter.number,
      verse: verse,
    );
  }

  Widget _buildContinuousReadingView(BuildContext context) {
    // Continuous mode reuses the same chapter-section widget shape for every
    // chapter so the reader can switch between verse-list and document layouts
    // without maintaining two separate "whole Bible" rendering trees.
    return ListView.builder(
      controller: widget.controller,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: widget.bottomOverlayPadding,
      ),
      itemCount: _continuousSections.length,
      itemBuilder: (context, index) {
        final section = _continuousSections[index];
        return Padding(
          key: _chapterSectionKey(section.book.id, section.chapter.number),
          padding: const EdgeInsets.only(bottom: 28),
          child: _ChapterSectionView(
            book: section.book,
            chapter: section.chapter,
            reference: widget.reference,
            fontSize: widget.fontSize,
            layoutMode: widget.layoutMode,
            buildChapterBlocks: (chapter) =>
                _buildChapterBlocksFor(context, chapter),
            buildVerse: (verse) => _buildVerseForChapter(
              context,
              section.book.id,
              section.chapter.number,
              verse,
            ),
            buildDocumentView: () => _buildDocumentReadingViewForChapter(
              context,
              section.book.id,
              section.chapter,
            ),
            buildInlineHeading: (block) => _buildInlineSectionHeading(
              context,
              block,
            ),
            introBuilder: section.chapter.number == 1
                ? () => Column(
                    children: _buildBookIntroductionBlocksForBook(
                      context,
                      section.book,
                      showForCurrentSection: true,
                    ),
                  )
                : null,
            headerBuilder: () => _buildChapterHeaderForChapter(
              context,
              section.book,
              section.chapter.number,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChapterHeaderForChapter(
    BuildContext context,
    BibleBook book,
    int chapterNumber,
  ) {
    return _buildCenteredChapterHeader(
      context,
      bookName: preferredBookName(book),
      chapterNumber: chapterNumber,
    );
  }

  Widget _buildCenteredChapterHeader(
    BuildContext context, {
    required String bookName,
    required int chapterNumber,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  letterSpacing: 0.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$chapterNumber',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: widget.fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncVisibleChapterFromViewport(BuildContext context) {
    if (!widget.continuousScrolling || !mounted) return;

    final threshold = widget.isSmallDevice ? 140.0 : 96.0;
    var visibleReference = widget.displayReference;
    var bestTop = -double.infinity;

    for (final section in _continuousSections) {
      final sectionContext = _chapterSectionKey(
        section.book.id,
        section.chapter.number,
      ).currentContext;
      if (sectionContext == null) continue;
      final renderBox = sectionContext.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached) continue;

      final top = renderBox.localToGlobal(Offset.zero).dy;
      if (top <= threshold && top > bestTop) {
        bestTop = top;
        visibleReference = BibleReference(
          bookId: section.book.id,
          chapter: section.chapter.number,
        );
      }
    }

    if (visibleReference == widget.displayReference) return;

    _suppressNextChapterAutoScroll = true;
    widget.onVisibleReferenceChanged(visibleReference);
  }

  List<Widget> _buildChapterBlocksFor(
    BuildContext context,
    BibleChapter chapter,
  ) {
    final visibleBlocks = _visibleChapterSupportBlocks(chapter);
    if (visibleBlocks.isEmpty) return const [];

    final headings = visibleBlocks
        .where((block) => block.kind == BibleDocumentBlockKind.heading)
        .toList();
    final tableRows = visibleBlocks
        .where(
          (block) =>
              block.kind == BibleDocumentBlockKind.table ||
              block.kind == BibleDocumentBlockKind.tableRow,
        )
        .toList();
    final supportingBlocks = visibleBlocks
        .where(
          (block) =>
              block.kind != BibleDocumentBlockKind.heading &&
              block.kind != BibleDocumentBlockKind.table &&
              block.kind != BibleDocumentBlockKind.tableRow,
        )
        .toList();

    return [
      for (final block in headings)
        _DocumentBlockView(
          block: block,
          fontSize: widget.fontSize,
          isEmphasized: true,
        ),
      if (tableRows.isNotEmpty)
        _TableBlockSection(rows: tableRows, fontSize: widget.fontSize),
      if (supportingBlocks.isNotEmpty)
        _DocumentBlockSection(
          title: 'Chapter Notes',
          eyebrow: 'Document',
          blocks: supportingBlocks,
          fontSize: widget.fontSize,
        ),
    ];
  }

  Widget _buildVerseForChapter(
    BuildContext context,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    return _buildVerseCard(
      context,
      bookId: bookId,
      chapterNumber: chapterNumber,
      verse: verse,
    );
  }

  List<BibleDocumentBlock> _visibleChapterSupportBlocks(BibleChapter chapter) {
    // Paragraph/poetry blocks are rendered by document-mode section builders.
    // Heading blocks with `beforeVerse` are also rendered inline by those
    // section builders — exclude them here to avoid double-rendering.
    // Only chapter-top headings (no `beforeVerse`) stay here.
    return chapter.blocks
        .where(
          (block) =>
              block.kind != BibleDocumentBlockKind.paragraph &&
              block.text.trim().isNotEmpty &&
              !(block.kind == BibleDocumentBlockKind.heading &&
                  block.metadata.containsKey('beforeVerse')),
        )
        .toList();
  }

  Widget _buildVerseCard(
    BuildContext context, {
    required String bookId,
    required int chapterNumber,
    required BibleVerse verse,
  }) {
    // Single-chapter and continuous verse-list modes now share the exact same
    // verse-card rendering so annotation buttons, selection styling, and
    // highlight treatment stay consistent across both layouts.
    final verseKey = _verseKey(bookId, chapterNumber, verse.number);
    final hasAnnotations = _hasParserNotes(verse);
    final bodyColor = _verseTextColor(context, bookId, chapterNumber, verse);
    final numberColor = _verseNumberColor(
      context,
      bookId,
      chapterNumber,
      verse,
    );
    final verseAnnotations = _annotationsForVerse(bookId, chapterNumber, verse);
    final hasPersonalNotes = _hasPersonalNotes(verseAnnotations);
    final noteAnnotations = _personalNoteAnnotations(verseAnnotations);
    final highlightColor = _highlightColorForVerse(
      context,
      verseAnnotations,
      bookId,
      chapterNumber,
      verse,
    );
    final isSelected = _isSelectedVerse(bookId, chapterNumber, verse);
    final containerColor = _selectionAwareBackground(
      context,
      isSelected: isSelected,
      baseBackground: highlightColor,
    );

    return Padding(
      key: verseKey,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _selectVerse(bookId, chapterNumber, verse),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      color: bodyColor,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: '${verse.number} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: numberColor,
                          fontSize: widget.fontSize - 2,
                        ),
                      ),
                      ..._buildVerseContentSpans(
                        context,
                        verse,
                        bodyColor: bodyColor,
                        isSelectedVerse: isSelected,
                        // Verse-list mode should use the card highlight only.
                        // Document mode owns the inline text highlighting style.
                        backgroundColor: null,
                        applySelectionTint: false,
                      ),
                    ],
                  ),
                ),
              ),
              if (hasPersonalNotes)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: _VerseNoteButton(
                    onPressed: () => _showPersonalNotesSheet(
                      context,
                      bookId: bookId,
                      chapterNumber: chapterNumber,
                      verse: verse,
                      verseAnnotations: noteAnnotations,
                    ),
                  ),
                ),
              if (hasAnnotations) ...[
                const SizedBox(width: 10),
                _VerseAnnotationButton(
                  onPressed: () =>
                      _showVerseDetailsSheet(context, chapterNumber, verse),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildVerseListWithInlineHeadings(
    BuildContext context,
    BibleChapter chapter,
  ) {
    return _interleaveVerseListWithHeadings(
      chapter: chapter,
      buildVerse: (verse) => _buildVerse(context, verse),
      buildInlineHeading: (block) => _buildInlineSectionHeading(context, block),
    );
  }

  Widget _buildInlineSectionHeading(
    BuildContext context,
    BibleDocumentBlock block,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: _DocumentBlockView(
        block: block,
        fontSize: widget.fontSize,
        isEmphasized: true,
      ),
    );
  }
}
