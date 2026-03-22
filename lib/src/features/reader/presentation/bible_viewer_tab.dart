import 'reference_screen.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/application/current_chapter_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/widgets/reference_bar.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BibleViewerTab extends ConsumerStatefulWidget {
  final VoidCallback showBottomNav;
  final VoidCallback hideBottomNav;
  final VoidCallback showAppBar;
  final VoidCallback hideAppBar;
  final bool isSmallDevice;

  const BibleViewerTab({
    super.key,
    required this.showBottomNav,
    required this.hideBottomNav,
    required this.showAppBar,
    required this.hideAppBar,
    required this.isSmallDevice,
  });

  @override
  ConsumerState<BibleViewerTab> createState() => _BibleViewerTabState();
}

class _BibleViewerTabState extends ConsumerState<BibleViewerTab> {
  final ScrollController _scrollController = ScrollController();
  BibleReference? _continuousVisibleReference;
  // Removed local constants; layout spacing is handled by widgets directly.
  //TODO: Make The Text Size Changeable through Settings
  // Font size is now provided by FontSizeService; listen to changes in build

  double? _lastScroll;
  bool _isHiding = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final current = _scrollController.position.pixels;
    final max = _scrollController.position.maxScrollExtent;
    final delta = current - (_lastScroll ?? current);
    _lastScroll = current;

    if (delta.abs() < 1) return;

    // Always show bars when at the bottom
    if (current >= max) {
      if (_isHiding) _toggleBars(show: true);
      return;
    }

    if (delta > 0 && !_isHiding) {
      _toggleBars(show: false); // scrolling down → hide
    } else if (delta < 0 && _isHiding) {
      _toggleBars(show: true); // scrolling up → show
    }
  }

  void _toggleBars({required bool show}) {
    if (show) {
      widget.showBottomNav();
      if (widget.isSmallDevice) widget.showAppBar();
    } else {
      widget.hideBottomNav();
      if (widget.isSmallDevice) widget.hideAppBar();
    }
    _isHiding = !show;
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Example: if you want to read a provider in here:
    // final someValue = ref.watch(someProvider);
    final booksAsync = ref.watch(bibleBooksProvider);
    final currentReference = ref.watch(currentReferenceProvider);
    final chapterAsync = ref.watch(currentChapterProvider);
    final layoutMode = ref.watch(readerLayoutModeProvider);
    final continuousScrolling = ref.watch(continuousScrollingProvider);
    final showBookIntroductions = ref.watch(showBookIntroductionsProvider);
    final showVerseSelector = ref.watch(showVerseSelectorProvider);
    const readerBarHeight = 56.0;
    const readerBarBottomInset = 12.0;
    const readerBarBottomPadding = readerBarHeight + readerBarBottomInset + 8;

    final displayReference =
        continuousScrolling && _continuousVisibleReference != null
        ? _continuousVisibleReference!
        : currentReference;

    return Stack(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: FontSizeService.instance.notifier,
          builder: (context, size, child) {
            return booksAsync.when(
              data: (books) => chapterAsync.when(
                data: (chapter) => chapter != null
                    ? _BibleTextView(
                        controller: _scrollController,
                        books: books,
                        book: _resolveCurrentBook(
                          books,
                          currentReference.bookId,
                        ),
                        chapter: chapter,
                        reference: currentReference,
                        displayReference: displayReference,
                        fontSize: size,
                        layoutMode: layoutMode,
                        continuousScrolling: continuousScrolling,
                        showBookIntroductions: showBookIntroductions,
                        isSmallDevice: widget.isSmallDevice,
                        bottomOverlayPadding: readerBarBottomPadding,
                        onVisibleReferenceChanged: (reference) {
                          if (_continuousVisibleReference == reference) return;
                          setState(() {
                            _continuousVisibleReference = reference;
                          });
                        },
                      )
                    : const _ErrorView(message: 'Chapter not found'),
                loading: () => const _LoadingView(),
                error: (error, stack) => _ErrorView(message: 'Error: $error'),
              ),
              loading: () => const _LoadingView(),
              error: (error, stack) =>
                  _ErrorView(message: 'Failed to load Bible: $error'),
            );
          },
        ),
        /*        ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            isSmall ? 16 : _chapterBarHeight + 16,
            16,
            bottomPadding,
          ),
          itemCount: 100,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Verse line ${i + 1} — sample Bible text.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),*/
        // Bible content is provided below and listens to global font-size

        // Chapter navigation bar
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            bottom: true,
            child: ChapterBar(
              barHeight: readerBarHeight,
              isFloating: true,
              reference: displayReference,
              books: booksAsync.value ?? const [],
              showVerseSelector: showVerseSelector,
              onReferenceChanged: (reference) {
                if (continuousScrolling) {
                  setState(() {
                    _continuousVisibleReference = reference;
                  });
                }
                ref
                    .read(currentReferenceProvider.notifier)
                    .setReference(reference);
              },
              onPreviousChapter: () {
                if (booksAsync.value != null) {
                  if (continuousScrolling) {
                    _jumpToAdjacentContinuousChapter(
                      ref,
                      booksAsync.value!,
                      displayReference,
                      direction: -1,
                    );
                  } else {
                    ref
                        .read(currentReferenceProvider.notifier)
                        .goToPreviousChapter(booksAsync.value!);
                  }
                }
              },
              onNextChapter: () {
                if (booksAsync.value != null) {
                  if (continuousScrolling) {
                    _jumpToAdjacentContinuousChapter(
                      ref,
                      booksAsync.value!,
                      displayReference,
                      direction: 1,
                    );
                  } else {
                    ref
                        .read(currentReferenceProvider.notifier)
                        .goToNextChapter(booksAsync.value!);
                  }
                }
              },
            ),
          ),
        ),

        // Translation selector removed — translations are selected from HomeScreen
      ],
    );
  }

  void _jumpToAdjacentContinuousChapter(
    WidgetRef ref,
    List<BibleBook> books,
    BibleReference baseReference, {
    required int direction,
  }) {
    final chapterReferences = <BibleReference>[
      for (final book in books)
        for (final chapter in book.chapters)
          BibleReference(bookId: book.id, chapter: chapter.number),
    ];
    if (chapterReferences.isEmpty) return;

    final currentIndex = chapterReferences.indexWhere(
      (reference) =>
          reference.bookId == baseReference.bookId &&
          reference.chapter == baseReference.chapter,
    );
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    final targetIndex = safeIndex + direction;
    if (targetIndex < 0 || targetIndex >= chapterReferences.length) return;

    final targetReference = chapterReferences[targetIndex];

    setState(() {
      _continuousVisibleReference = targetReference;
    });
    ref.read(currentReferenceProvider.notifier).setReference(targetReference);
  }
}

BibleBook _resolveCurrentBook(List<BibleBook> books, String bookId) {
  if (books.isEmpty) {
    return BibleBook(
      id: bookId,
      name: humanizeBookId(bookId),
      shortName: bookId,
      bookNumber: 0,
    );
  }

  return resolveBookFromReference(books, bookId) ?? books.first;
}

/// Bible text display widget
class _BibleTextView extends StatefulWidget {
  const _BibleTextView({
    required this.controller,
    required this.books,
    required this.book,
    required this.chapter,
    required this.reference,
    required this.displayReference,
    required this.fontSize,
    required this.layoutMode,
    required this.continuousScrolling,
    required this.showBookIntroductions,
    required this.isSmallDevice,
    required this.bottomOverlayPadding,
    required this.onVisibleReferenceChanged,
  });

  final ScrollController controller;
  final List<BibleBook> books;
  final BibleBook book;
  final BibleChapter chapter;
  final BibleReference reference;
  final BibleReference displayReference;
  final double fontSize;
  final ReaderLayoutMode layoutMode;
  final bool continuousScrolling;
  final bool showBookIntroductions;
  final bool isSmallDevice;
  final double bottomOverlayPadding;
  final ValueChanged<BibleReference> onVisibleReferenceChanged;

  @override
  State<_BibleTextView> createState() => _BibleTextViewState();
}

class _BibleTextViewState extends State<_BibleTextView> {
  final Map<String, GlobalKey> _verseKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _chapterSectionKeys = <String, GlobalKey>{};
  List<_ContinuousChapterSection> _continuousSections =
      <_ContinuousChapterSection>[];
  bool _showSelectedVerseFocus = true;
  bool _suppressNextChapterAutoScroll = false;
  bool _visibleSyncQueued = false;

  @override
  void initState() {
    super.initState();
    _rebuildContinuousSections();
    _scheduleVerseFocus();
    if (widget.continuousScrolling && widget.reference.verse == null) {
      _scheduleChapterFocus();
    }
  }

  @override
  void didUpdateWidget(covariant _BibleTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.books != widget.books) {
      _rebuildContinuousSections();
    }
    if (oldWidget.reference != widget.reference ||
        oldWidget.chapter != widget.chapter) {
      _showSelectedVerseFocus = true;
      _scheduleVerseFocus();
    }
    if (widget.continuousScrolling &&
        (oldWidget.reference.bookId != widget.reference.bookId ||
            oldWidget.reference.chapter != widget.reference.chapter)) {
      if (_suppressNextChapterAutoScroll) {
        _suppressNextChapterAutoScroll = false;
      } else if (widget.reference.verse == null) {
        // In continuous mode a verse jump should land on the verse itself.
        // Only fall back to the chapter header when no verse was requested.
        _scheduleChapterFocus();
      }
    }
  }

  void _rebuildContinuousSections() {
    _continuousSections = <_ContinuousChapterSection>[
      for (final book in widget.books)
        for (final chapter in book.chapters)
          _ContinuousChapterSection(book: book, chapter: chapter),
    ];
  }

  void _scheduleVerseFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final verseNumber = widget.reference.verse;
      if (verseNumber == null) return;
      final targetContext = _verseKey(
        widget.reference.bookId,
        widget.reference.chapter,
        verseNumber,
      ).currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.18,
        );
      }
    });
  }

  void _scheduleChapterFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.continuousScrolling) return;
      final targetContext = _chapterSectionKey(
        widget.reference.bookId,
        widget.reference.chapter,
      ).currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.02,
        );
      }
    });
  }

  bool get _hasActiveVerseFocus =>
      _showSelectedVerseFocus && widget.reference.verse != null;

  GlobalKey _verseKey(String bookId, int chapterNumber, int verseNumber) {
    final key = '$bookId:$chapterNumber:$verseNumber';
    return _verseKeys.putIfAbsent(key, GlobalKey.new);
  }

  GlobalKey _chapterSectionKey(String bookId, int chapterNumber) {
    final key = '$bookId:$chapterNumber';
    return _chapterSectionKeys.putIfAbsent(key, GlobalKey.new);
  }

  bool _isFocusedVerse(String bookId, int chapterNumber, BibleVerse verse) =>
      _hasActiveVerseFocus &&
      widget.reference.bookId == bookId &&
      widget.reference.chapter == chapterNumber &&
      widget.reference.verse == verse.number;

  void _dismissSelectedVerseFocus() {
    if (!_hasActiveVerseFocus || !mounted) return;
    setState(() {
      _showSelectedVerseFocus = false;
    });
  }

  Color? _verseTextColor(
    BuildContext context,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final baseColor = Theme.of(context).textTheme.bodyLarge?.color;
    if (!_hasActiveVerseFocus) return baseColor;
    return _isFocusedVerse(bookId, chapterNumber, verse)
        ? baseColor
        : baseColor?.withValues(alpha: 0.5);
  }

  Color _verseNumberColor(
    BuildContext context,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final colors = Theme.of(context).colorScheme;
    // Reader numbers need their own contrast path because monochrome themes
    // intentionally set `primary` to the page background.
    final base = Color.lerp(colors.onSurfaceVariant, colors.onSurface, 0.3) ??
        colors.onSurfaceVariant;
    if (!_hasActiveVerseFocus ||
        _isFocusedVerse(bookId, chapterNumber, verse)) {
      return base;
    }
    return base.withValues(alpha: 0.58);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollStartNotification>(
      onNotification: (notification) {
        if (notification.dragDetails != null) {
          // Keep the selected-verse focus treatment only until the user starts
          // interacting with the scroll view. Programmatic scrolling from a
          // verse jump should not immediately clear the visual focus.
          _dismissSelectedVerseFocus();
        }
        return false;
      },
      child: widget.continuousScrolling
          ? NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                _queueVisibleChapterSync(context);
                return false;
              },
              child: _buildContinuousReadingView(context),
            )
          : _buildSingleChapterView(context),
    );
  }

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
        ...widget.chapter.verses.map((verse) => _buildVerse(context, verse))
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
    final visibleBlocks = widget.chapter.blocks
        .where(
          (block) =>
              block.kind != BibleDocumentBlockKind.paragraph &&
              block.text.trim().isNotEmpty,
        )
        .toList();
    if (visibleBlocks.isEmpty) return const [];

    final headings = visibleBlocks
        .where((block) => block.kind == BibleDocumentBlockKind.heading)
        .toList();
    final supportingBlocks = visibleBlocks
        .where((block) => block.kind != BibleDocumentBlockKind.heading)
        .toList();

    return [
      for (final block in headings)
        _DocumentBlockView(
          block: block,
          fontSize: widget.fontSize,
          isEmphasized: true,
        ),
      if (supportingBlocks.isNotEmpty)
        _DocumentBlockSection(
          title: 'Chapter Notes',
          eyebrow: 'Document',
          blocks: supportingBlocks,
          fontSize: widget.fontSize,
        ),
    ];
  }

  Widget _buildVerse(BuildContext context, BibleVerse verse) {
    final verseKey = _verseKey(
      widget.book.id,
      widget.chapter.number,
      verse.number,
    );
    final hasAnnotations = _hasAnnotations(verse);
    final bodyColor = _verseTextColor(
      context,
      widget.book.id,
      widget.chapter.number,
      verse,
    );
    final numberColor = _verseNumberColor(
      context,
      widget.book.id,
      widget.chapter.number,
      verse,
    );

    return Padding(
      key: verseKey,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(color: Colors.transparent),
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
                    ),
                  ],
                ),
              ),
            ),
            if (hasAnnotations) ...[
              const SizedBox(width: 10),
              _VerseAnnotationButton(
                onPressed: () => _showVerseDetailsSheet(
                  context,
                  widget.chapter.number,
                  verse,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

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

  Widget _buildContinuousReadingView(BuildContext context) {
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
    final visibleBlocks = chapter.blocks
        .where(
          (block) =>
              block.kind != BibleDocumentBlockKind.paragraph &&
              block.text.trim().isNotEmpty,
        )
        .toList();
    if (visibleBlocks.isEmpty) return const [];

    final headings = visibleBlocks
        .where((block) => block.kind == BibleDocumentBlockKind.heading)
        .toList();
    final supportingBlocks = visibleBlocks
        .where((block) => block.kind != BibleDocumentBlockKind.heading)
        .toList();

    return [
      for (final block in headings)
        _DocumentBlockView(
          block: block,
          fontSize: widget.fontSize,
          isEmphasized: true,
        ),
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
    final verseKey = _verseKey(bookId, chapterNumber, verse.number);
    final hasAnnotations = _hasAnnotations(verse);
    final bodyColor = _verseTextColor(context, bookId, chapterNumber, verse);
    final numberColor = _verseNumberColor(
      context,
      bookId,
      chapterNumber,
      verse,
    );

    return Padding(
      key: verseKey,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(color: Colors.transparent),
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
                    ),
                  ],
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
    );
  }

  List<_ParagraphSection> _buildParagraphSectionsForChapter(
    BibleChapter chapter,
  ) {
    if (chapter.verses.isEmpty) return const [];

    final paragraphBlocksByVerse = <int, List<BibleDocumentBlock>>{};
    for (final block in chapter.blocks) {
      if (block.kind != BibleDocumentBlockKind.paragraph &&
          block.kind != BibleDocumentBlockKind.poetry) {
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
            TextSpan(
              text: '${verse.number} ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _verseNumberColor(context, bookId, chapterNumber, verse),
                fontSize: widget.fontSize - 2,
              ),
            ),
            ..._buildVerseContentSpans(
              context,
              verse,
              bodyColor: _verseTextColor(context, bookId, chapterNumber, verse),
            ),
            if (_hasAnnotations(verse))
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
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: widget.fontSize,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.7,
                ),
                children: [
                  TextSpan(
                    text: '${verse.number} ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _verseNumberColor(
                        context,
                        bookId,
                        chapterNumber,
                        verse,
                      ),
                      fontSize: widget.fontSize - 2,
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
                  ),
                  if (_hasAnnotations(verse))
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

  void _showVerseDetailsSheet(
    BuildContext context,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final footnotes = _displayFootnotes(verse);
    final references = _structuredReferences(verse);
    final annotationEntries = _annotationEntries(
      footnotes: footnotes,
      references: references,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _VerseDetailsSheet(
          referenceLabel:
              '${displayBookNameForReference(widget.books, widget.reference.bookId)} $chapterNumber:${verse.number}',
          verse: verse,
          annotationEntries: annotationEntries,
          onReferenceTap: (referenceEntry) =>
              _openReferenceFromSheet(context, referenceEntry),
        );
      },
    );
  }

  void _openReferenceFromSheet(
    BuildContext context,
    BibleCrossReference referenceEntry,
  ) {
    final parsedReference = parseAnyReference(
      target: referenceEntry.target,
      label: referenceEntry.label,
    );

    if (parsedReference != null) {
      // Use the parser-provided target first so taps can go straight to the
      // intended verse instead of depending on display-label parsing.
      final referenceNotifier = ProviderScope.containerOf(
        context,
        listen: false,
      ).read(currentReferenceProvider.notifier);
      referenceNotifier.setReference(parsedReference);
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReferenceScreen(
          references: [referenceEntry],
          currentReference: widget.reference,
        ),
      ),
    );
  }

  List<BibleFootnote> _displayFootnotes(BibleVerse verse) {
    if (verse.footnotes.isNotEmpty) {
      return verse.footnotes;
    }

    return (verse.notes ?? const [])
        .map((note) => BibleFootnote(text: note))
        .toList();
  }

  List<BibleCrossReference> _structuredReferences(BibleVerse verse) {
    if (verse.crossReferences.isNotEmpty) {
      return verse.crossReferences;
    }
    return (verse.references ?? const [])
        .map((reference) => BibleCrossReference(label: reference))
        .toList();
  }

  bool _hasAnnotations(BibleVerse verse) {
    final hasFootnotes =
        verse.footnotes.isNotEmpty ||
        (verse.notes != null && verse.notes!.isNotEmpty);
    final hasReferences =
        verse.crossReferences.isNotEmpty ||
        (verse.references != null && verse.references!.isNotEmpty);
    return hasFootnotes || hasReferences;
  }

  List<_VerseAnnotationEntry> _annotationEntries({
    required List<BibleFootnote> footnotes,
    required List<BibleCrossReference> references,
  }) {
    final entries = <_VerseAnnotationEntry>[];
    var markerIndex = 0;

    String nextMarker() {
      final value = String.fromCharCode('a'.codeUnitAt(0) + markerIndex);
      markerIndex++;
      return value;
    }

    // The current shared model stores notes and references in separate lists,
    // so this sheet uses a stable generated marker order instead of pretending
    // we still know the original exact source ordering for every format.
    for (final footnote in footnotes) {
      final labelIsRef =
          footnote.label != null && footnote.label!.trim().length > 1;
      entries.add(
        _VerseAnnotationEntry(
          marker: _annotationMarker(footnote, fallback: nextMarker()),
          body: _footnoteBody(footnote),
          originRef: labelIsRef ? footnote.label!.trim() : null,
          bodyText: footnote.bodyText,
          quotedText: footnote.quotedText,
          reference: footnote.references.isNotEmpty
              ? footnote.references.first
              : null,
          relatedReferences: footnote.references,
        ),
      );
    }

    for (final reference in references) {
      final refOrigin = reference.originRef?.trim().isNotEmpty == true
          ? reference.originRef!.trim()
          : null;
      entries.add(
        _VerseAnnotationEntry(
          marker: reference.marker?.trim().isNotEmpty == true
              ? reference.marker!.trim().toLowerCase()
              : nextMarker(),
          body: reference.label,
          originRef: refOrigin,
          bodyText: refOrigin != null ? reference.label : null,
          reference: reference,
        ),
      );
    }

    return entries;
  }

  String _annotationMarker(BibleFootnote footnote, {required String fallback}) {
    final candidates = [footnote.marker?.trim(), footnote.label?.trim()];

    for (final candidate in candidates) {
      if (candidate == null || candidate.isEmpty) continue;
      // Accept any single printable character — covers letters, digits, and
      // common footnote symbols such as * + † ‡ § that USFX uses as callers.
      if (candidate.length == 1) {
        return candidate;
      }
    }

    return fallback;
  }

  // Build the display body for a footnote annotation row.
  // The label field holds the origin-verse reference from <fr> (e.g. "Gen 1:1 — ").
  // Show it as a readable prefix when it is a real reference string rather than
  // a single-character marker, which would already be shown as the marker itself.
  String _footnoteBody(BibleFootnote footnote) {
    final label = footnote.label?.trim();
    final text = footnote.text.trim();
    if (label != null && label.isNotEmpty && label.length > 1) {
      return '$label $text'.trim();
    }
    return text;
  }

  List<InlineSpan> _buildVerseContentSpans(
    BuildContext context,
    BibleVerse verse, {
    Color? bodyColor,
  }) {
    final spans = _displaySpans(verse);
    if (spans.isEmpty) {
      return [
        TextSpan(
          text: verse.text,
          style: TextStyle(color: bodyColor),
        ),
      ];
    }

    final baseColor = bodyColor ?? Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final inlineSpans = <InlineSpan>[];

    for (final span in spans) {
      inlineSpans.add(
        TextSpan(
          text: _spanText(span),
          style: TextStyle(
            color: _spanColor(span.kind, baseColor, secondaryColor),
            fontStyle: _spanFontStyle(span.kind),
            fontWeight: _spanFontWeight(span.kind),
            decoration: _spanDecoration(span.kind),
          ),
        ),
      );
      inlineSpans.addAll(_buildInlineAnnotationMarkers(context, span));
    }

    return inlineSpans;
  }

  List<BibleVerseSpan> _displaySpans(BibleVerse verse) {
    if (verse.spans.isEmpty) return const [];

    final displaySpans = <BibleVerseSpan>[];
    var previousText = '';

    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;

      final startsNewLine = span.metadata['lineStart'] == 'true';

      // Some source formats split every word into separate rich spans.
      // Reinsert display spacing here so tag-heavy sources like KJV do not
      // collapse into "wordstucktogether" when rendered span-by-span.
      if (startsNewLine) {
        text = '\n$text';
      } else if (_shouldInsertSpace(previousText, text)) {
        text = ' $text';
      }

      displaySpans.add(
        BibleVerseSpan(text: text, kind: span.kind, metadata: span.metadata),
      );
      previousText = startsNewLine ? text.trimLeft() : text;
    }

    return displaySpans;
  }

  bool _shouldInsertSpace(String previousText, String currentText) {
    if (previousText.isEmpty) return false;
    if (currentText.startsWith(RegExp(r"[.,;:!?)}\]”’]"))) return false;
    if (RegExp(r"[(\[{“‘/]$").hasMatch(previousText)) return false;
    return true;
  }

  String _spanText(BibleVerseSpan span) {
    if (span.metadata case {'quoteLevel': final levelText}) {
      final level = int.tryParse(levelText) ?? 0;
      if (level > 1) {
        return '${' ' * ((level - 1) * 2)}${span.text}';
      }
    }
    return span.text;
  }

  List<InlineSpan> _buildInlineAnnotationMarkers(
    BuildContext context,
    BibleVerseSpan span,
  ) {
    final markers = <String>[
      ..._splitAnnotationMarkers(span.metadata['footnoteMarkers']),
      ..._splitAnnotationMarkers(span.metadata['referenceMarkers']),
    ];

    if (markers.isEmpty) return const [];

    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return [
      for (final marker in markers)
        WidgetSpan(
          alignment: PlaceholderAlignment.top,
          child: Padding(
            padding: const EdgeInsets.only(left: 1),
            child: Text(
              marker,
              style: TextStyle(
                fontSize: widget.fontSize * 0.58,
                height: 1,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
    ];
  }

  List<String> _splitAnnotationMarkers(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return const [];
    return rawValue
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Color? _spanColor(
    BibleVerseSpanKind kind,
    Color? baseColor,
    Color secondaryColor,
  ) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700;
      case BibleVerseSpanKind.word:
        return secondaryColor;
      default:
        return baseColor;
    }
  }

  FontStyle _spanFontStyle(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.translatorAddition:
      case BibleVerseSpanKind.quote:
      case BibleVerseSpanKind.poetry:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.word:
        return TextDecoration.underline;
      default:
        return null;
    }
  }
}

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

class _VerseDetailsSheet extends StatelessWidget {
  const _VerseDetailsSheet({
    required this.referenceLabel,
    required this.verse,
    required this.annotationEntries,
    required this.onReferenceTap,
  });

  final String referenceLabel;
  final BibleVerse verse;
  final List<_VerseAnnotationEntry> annotationEntries;
  final ValueChanged<BibleCrossReference> onReferenceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final versePreview = _VersePreviewText(
      verse: verse,
      annotationEntries: annotationEntries,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      referenceLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: theme.textTheme.headlineSmall?.copyWith(
                    height: 1.55,
                    fontSize: 18,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  children: versePreview.inlineSpans(colors),
                ),
              ),
              const SizedBox(height: 18),
              Divider(color: colors.outlineVariant.withValues(alpha: 0.35)),
              for (final entry in annotationEntries)
                _VerseAnnotationRow(
                  entry: entry,
                  onReferenceTap: onReferenceTap,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseAnnotationButton extends StatelessWidget {
  const _VerseAnnotationButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: compact ? 22 : 30,
          height: compact ? 22 : 30,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.notes_outlined,
            size: compact ? 14 : 18,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _VerseAnnotationEntry {
  const _VerseAnnotationEntry({
    required this.marker,
    required this.body,
    this.originRef,
    this.bodyText,
    this.quotedText,
    this.reference,
    this.relatedReferences = const [],
  });

  final String marker;
  final String body; // plain fallback — used for cross-refs and OSIS/Zefania
  final String? originRef; // structured origin ref from <fr> (e.g. "Gen 1:1")
  final String? bodyText; // structured body from <ft>
  final String? quotedText; // structured quote from <fq>/<fqa>
  final BibleCrossReference? reference;
  final List<BibleCrossReference> relatedReferences;
}

class _VersePreviewText {
  const _VersePreviewText({
    required this.verse,
    required this.annotationEntries,
  });

  final BibleVerse verse;
  final List<_VerseAnnotationEntry> annotationEntries;

  List<InlineSpan> inlineSpans(ColorScheme colors) {
    final spans = _displaySpans();
    if (spans.isEmpty) {
      return _fallbackInlineSpans(colors);
    }

    final inlineSpans = <InlineSpan>[];
    var renderedInlineMarkers = false;

    // Keep the verse preview aligned with the main reader so annotation letters
    // appear beside the anchored words here too, not only in the chapter view.
    for (final span in spans) {
      inlineSpans.add(
        TextSpan(
          text: _spanText(span),
          style: TextStyle(
            color: _spanColor(span.kind, colors),
            fontStyle: _spanFontStyle(span.kind),
            fontWeight: _spanFontWeight(span.kind),
            decoration: _spanDecoration(span.kind),
          ),
        ),
      );
      final markers = _buildInlineAnnotationMarkers(colors, span);
      if (markers.isNotEmpty) {
        renderedInlineMarkers = true;
        inlineSpans.addAll(markers);
      }
    }

    // Some older or less expressive source content still has sheet entries but
    // no anchored span metadata. Keep those marker letters visible in the
    // preview instead of silently dropping them from the verse line entirely.
    if (!renderedInlineMarkers && annotationEntries.isNotEmpty) {
      inlineSpans.addAll(_fallbackMarkerSpans(colors));
    }

    return inlineSpans;
  }

  List<InlineSpan> _fallbackInlineSpans(ColorScheme colors) {
    final spans = <InlineSpan>[TextSpan(text: verse.text)];
    if (annotationEntries.isNotEmpty) {
      spans.addAll(_fallbackMarkerSpans(colors));
    }
    return spans;
  }

  List<InlineSpan> _fallbackMarkerSpans(ColorScheme colors) {
    return [
      const TextSpan(text: ' '),
      for (final entry in annotationEntries) ...[
        _markerSpan(colors, entry.marker),
        const TextSpan(text: ' '),
      ],
    ];
  }

  List<BibleVerseSpan> _displaySpans() {
    if (verse.spans.isEmpty) return const [];

    final displaySpans = <BibleVerseSpan>[];
    var previousText = '';

    for (final span in verse.spans) {
      var text = span.text.trim();
      if (text.isEmpty) continue;

      final startsNewLine = span.metadata['lineStart'] == 'true';

      if (startsNewLine) {
        text = '\n$text';
      } else if (_shouldInsertSpace(previousText, text)) {
        text = ' $text';
      }

      displaySpans.add(
        BibleVerseSpan(text: text, kind: span.kind, metadata: span.metadata),
      );
      previousText = startsNewLine ? text.trimLeft() : text;
    }

    return displaySpans;
  }

  bool _shouldInsertSpace(String previousText, String currentText) {
    if (previousText.isEmpty) return false;
    if (currentText.startsWith(RegExp(r"[.,;:!?)}\]”’]"))) return false;
    if (RegExp(r"[(\[{“‘/]$").hasMatch(previousText)) return false;
    return true;
  }

  String _spanText(BibleVerseSpan span) {
    if (span.metadata case {'quoteLevel': final levelText}) {
      final level = int.tryParse(levelText) ?? 0;
      if (level > 1) {
        return '${' ' * ((level - 1) * 2)}${span.text}';
      }
    }
    return span.text;
  }

  List<InlineSpan> _buildInlineAnnotationMarkers(
    ColorScheme colors,
    BibleVerseSpan span,
  ) {
    final markers = <String>[
      ..._splitAnnotationMarkers(span.metadata['footnoteMarkers']),
      ..._splitAnnotationMarkers(span.metadata['referenceMarkers']),
    ];

    if (markers.isEmpty) return const [];

    return [for (final marker in markers) _markerSpan(colors, marker)];
  }

  InlineSpan _markerSpan(ColorScheme colors, String marker) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.aboveBaseline,
      baseline: TextBaseline.alphabetic,
      child: Padding(
        padding: const EdgeInsets.only(left: 1),
        child: Text(
          marker,
          style: TextStyle(
            fontSize: 13,
            height: 1,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<String> _splitAnnotationMarkers(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return const [];
    return rawValue
        .split('|')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Color? _spanColor(BibleVerseSpanKind kind, ColorScheme colors) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700;
      case BibleVerseSpanKind.word:
        return colors.secondary;
      default:
        return colors.onSurface;
    }
  }

  FontStyle _spanFontStyle(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.translatorAddition:
      case BibleVerseSpanKind.quote:
      case BibleVerseSpanKind.poetry:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.word:
        return TextDecoration.underline;
      default:
        return null;
    }
  }
}

class _VerseAnnotationRow extends StatelessWidget {
  const _VerseAnnotationRow({required this.entry, this.onReferenceTap});

  final _VerseAnnotationEntry entry;
  final ValueChanged<BibleCrossReference>? onReferenceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26,
            child: Text(
              entry.marker,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                entry.bodyText != null
                    ? RichText(
                        text: TextSpan(
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: colors.onSurface,
                          ),
                          children: [
                            if (entry.originRef != null)
                              TextSpan(
                                text: '${entry.originRef} ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            TextSpan(text: entry.bodyText),
                            if (entry.quotedText != null)
                              TextSpan(
                                text: ' \u201c${entry.quotedText}\u201d',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      )
                    : Text(
                        entry.body,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                if (entry.relatedReferences.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reference in entry.relatedReferences)
                        ActionChip(
                          avatar: const Icon(Icons.link, size: 16),
                          label: Text(reference.label),
                          onPressed: onReferenceTap == null
                              ? null
                              : () => onReferenceTap!(reference),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (entry.reference != null && onReferenceTap != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onReferenceTap!(entry.reference!),
              icon: const Icon(Icons.chevron_right),
              color: colors.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentBlockView extends StatelessWidget {
  const _DocumentBlockView({
    required this.block,
    required this.fontSize,
    this.isEmphasized = false,
  });

  final BibleDocumentBlock block;
  final double fontSize;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = switch (block.kind) {
      BibleDocumentBlockKind.heading => theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      BibleDocumentBlockKind.preface ||
      BibleDocumentBlockKind.introduction => theme.textTheme.bodyLarge,
      BibleDocumentBlockKind.poetry => theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      _ => theme.textTheme.bodyMedium,
    };

    return Padding(
      padding: EdgeInsets.only(
        bottom: block.kind == BibleDocumentBlockKind.heading ? 12 : 10,
      ),
      child: Text(
        block.text,
        style: style?.copyWith(
          fontSize: (style.fontSize ?? fontSize) + (isEmphasized ? 1 : 0),
          color: isEmphasized ? theme.colorScheme.secondary : style.color,
          height: 1.5,
        ),
        textAlign: block.kind == BibleDocumentBlockKind.heading
            ? TextAlign.center
            : TextAlign.start,
      ),
    );
  }
}

class _DocumentBlockSection extends StatelessWidget {
  const _DocumentBlockSection({
    required this.title,
    required this.blocks,
    required this.fontSize,
    this.eyebrow,
  });

  final String title;
  final String? eyebrow;
  final List<BibleDocumentBlock> blocks;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Grouping front matter and supporting chapter blocks into a single
    // styled section keeps them readable without making them feel like
    // parser-debug output dumped between verses.
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null)
            Text(
              eyebrow!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final block in blocks)
            _DocumentBlockView(block: block, fontSize: fontSize),
        ],
      ),
    );
  }
}

/// Loading state widget
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading Bible...'),
        ],
      ),
    );
  }
}

/// Error state widget
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            SelectableText(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    ref.invalidate(bibleBooksProvider);
                  },
                  child: const Text('Retry'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
