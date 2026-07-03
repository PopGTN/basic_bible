import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_selection_view_models.dart';
import 'package:basic_bible/src/features/annotations/data/user_annotation_repository.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_detail_screen.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/continuous_reader_controller.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/current_chapter_view_model.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_preferences_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/chapter_bar.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_preview_sheet.dart';
import 'package:basic_bible/src/features/settings/application/view_models/reader_display_preferences_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

// File map for this reader module:
// - this file:                  shell coordinator (BibleViewerTab + _BibleViewerTabState)
// - *_text_view.dart:           _BibleTextView + _BibleTextViewState widget declaration
// - *_state_selection.dart:     copy/share/highlight/note action handlers
// - *_state_core.dart:          selection state / focus / annotation lookup helpers
// - *_state_rendering.dart:     verse-list + continuous rendering flow
// - *_state_document.dart:      document-mode rendering details
// - *_state_annotations.dart:   parser-note sheets + inline span helpers
// - *_sections.dart:            support types and shared layout helpers
part 'bible_viewer_tab_sections.dart';
part 'bible_viewer_tab_shell_snapshot.dart';
part 'bible_viewer_tab_annotation_controls.dart';
part 'bible_viewer_tab_annotation_details.dart';
part 'bible_viewer_tab_document_widgets.dart';
part 'bible_viewer_tab_personal_notes.dart';
part 'bible_viewer_tab_text_view.dart';
part 'bible_viewer_tab_state_selection.dart';
part 'bible_viewer_tab_state_core.dart';
part 'bible_viewer_tab_state_rendering.dart';
part 'bible_viewer_tab_state_document.dart';
part 'bible_viewer_tab_state_annotations.dart';

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

/// Owns the outer reader shell: loading async data, wiring reader controls,
/// and keeping the floating chapter bar in sync with what the user sees.
class _BibleViewerTabState extends ConsumerState<BibleViewerTab> {
  static const _readerBarHeight = 56.0;
  static const _readerBarBottomInset = 12.0;
  static const _readerBarBottomPadding =
      _readerBarHeight + _readerBarBottomInset + 8;
  static const _chapterTransitionDuration = Duration(milliseconds: 140);

  BibleReference? _continuousVisibleReference;

  // Cached flat list of every chapter reference across all books.
  // Rebuilt only when the books list reference changes, so prev/next taps
  // don't allocate ~1189-entry lists on every press.
  List<BibleBook>? _chapterRefCacheSource;
  List<BibleReference> _chapterRefs = const [];

  List<BibleReference> _flatChapterRefs(List<BibleBook> books) {
    if (identical(_chapterRefCacheSource, books)) return _chapterRefs;
    _chapterRefCacheSource = books;
    _chapterRefs = [
      for (final book in books)
        for (final chapter in book.chapters)
          BibleReference(bookId: book.id, chapter: chapter.number),
    ];
    return _chapterRefs;
  }

  double? _lastScroll;
  bool _isHiding = false;
  bool _selectionActionInFlight = false;

  void _handleScrollNotification(ScrollNotification notification) {
    final current = notification.metrics.pixels;
    final max = notification.metrics.maxScrollExtent;
    final delta = current - (_lastScroll ?? current);
    _lastScroll = current;

    if (delta.abs() < 1) return;

    // A large single-notification jump is a programmatic reposition (chapter
    // navigation, continuous-list key reset), not the user scrolling. Only
    // rebaseline — toggling the bars here would hide them when the user taps
    // next/previous chapter.
    if (delta.abs() > 400) return;

    // Always show bars when at the bottom.
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

  void _setSelectionActionInFlight(bool value) {
    if (!mounted || _selectionActionInFlight == value) return;
    setState(() {
      _selectionActionInFlight = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final readerState = _watchReaderShellState();
    final contentBottomPadding = _contentBottomPadding(
      hasSelection: readerState.selectedVerses.isNotEmpty,
      showHighlightPalette: readerState.showHighlightPalette,
    );
    final displayReference = _displayReferenceFor(
      currentReference: readerState.currentReference,
      continuousScrolling: readerState.continuousScrolling,
    );

    // Shell books are always available quickly (metadata only, no verses).
    // Use them for the nav bar and picker so they work instantly regardless
    // of whether the full verse data has finished loading in continuous mode.
    final navBooks = readerState.shellBooksAsync.value ?? const [];
    final canOpenReferencePicker =
        !readerState.shellBooksAsync.isLoading &&
        !readerState.chapterAsync.isLoading &&
        navBooks.isNotEmpty;

    return Stack(
      children: [
        // Main Bible content layer.
        _buildReaderContentLayer(
          readerState,
          displayReference,
          contentBottomPadding,
        ),

        // Floating chapter/reference controls.
        _buildChapterNavigationBar(
          readerBarHeight: _readerBarHeight,
          displayReference: displayReference,
          books: navBooks,
          canOpenReferencePicker: canOpenReferencePicker,
          showVerseSelector: readerState.showVerseSelector,
          continuousScrolling: readerState.continuousScrolling,
        ),

        // Selection action tray for highlight / note / copy / share.
        // Selection actions use shell books for labels while verse text is
        // resolved lazily from chapter storage when needed.
        if (readerState.selectedVerses.isNotEmpty &&
            readerState.selectedVerse != null)
          _buildSelectionOverlay(
            selectedVerses: readerState.selectedVerses,
            books: navBooks,
            selectedVerseAnnotations: readerState.selectedVerseAnnotations,
            showHighlightPalette: readerState.showHighlightPalette,
          ),

        // Translation selector removed — translations are selected from HomeScreen
      ],
    );
  }

  _ReaderShellStateSnapshot _watchReaderShellState() {
    final continuousScrolling = ref.watch(continuousScrollingProvider);
    // Shell books always watch the fast metadata-only provider so the reference
    // bar and picker are populated immediately, regardless of scroll mode.
    // Full books (with verses) are only needed in continuous mode for content
    // rendering and are watched separately.
    final shellBooksAsync = ref.watch(bibleBooksShellProvider);
    return _ReaderShellStateSnapshot(
      layoutMode: ref.watch(readerLayoutModeProvider),
      continuousScrolling: continuousScrolling,
      shellBooksAsync: shellBooksAsync,
      currentReference: ref.watch(currentReferenceProvider),
      chapterAsync: ref.watch(currentChapterProvider),
      showBookIntroductions: ref.watch(showBookIntroductionsProvider),
      showVerseSelector: ref.watch(showVerseSelectorProvider),
      selectedVerses: ref.watch(selectedVersesProvider),
      selectedVerse: ref.watch(selectedVerseProvider),
      showHighlightPalette: ref.watch(highlightPaletteExpandedProvider),
      selectedVerseAnnotations: ref.watch(selectedVerseAnnotationsProvider),
    );
  }

  double _contentBottomPadding({
    required bool hasSelection,
    required bool showHighlightPalette,
  }) {
    // The reader has two independent bottom overlays:
    // 1. the floating chapter/reference bar
    // 2. the verse-selection action tray
    // This helper keeps the content padding rule in one place so scrollable
    // content does not get hidden behind either overlay as the UI state changes.
    final selectionBarHeight = !hasSelection
        ? 0.0
        : showHighlightPalette
        ? 140.0
        : 92.0;
    return _readerBarBottomPadding +
        selectionBarHeight +
        (hasSelection ? 12 : 0);
  }

  BibleReference _displayReferenceFor({
    required BibleReference currentReference,
    required bool continuousScrolling,
  }) {
    return continuousScrolling && _continuousVisibleReference != null
        ? _continuousVisibleReference!
        : currentReference;
  }

  Widget _buildReaderContentLayer(
    _ReaderShellStateSnapshot readerState,
    BibleReference displayReference,
    double contentBottomPadding,
  ) {
    // The async content layer is isolated here so loading/error/data branching
    // stays separate from the shell overlays above it.
    return ValueListenableBuilder<double>(
      valueListenable: FontSizeService.instance.notifier,
      builder: (context, size, child) {
        final translationId = ref.read(currentTranslationProvider);
        return readerState.shellBooksAsync.when(
          data: (books) => readerState.chapterAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            data: (chapter) => chapter != null
                ? AnimatedSwitcher(
                    duration: _chapterTransitionDuration,
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      fit: StackFit.expand,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.012),
                        end: Offset.zero,
                      ).animate(fade);
                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: _BibleTextView(
                      key: ValueKey(
                        [
                          translationId,
                          // In continuous mode the reference changes as the user
                          // scrolls — don't include book/chapter in the key or
                          // _BibleTextViewState is destroyed (losing all hydrated
                          // chapters and scroll position) every time the visible
                          // chapter changes via navigation.
                          if (!readerState.continuousScrolling) ...[
                            readerState.currentReference.bookId,
                            readerState.currentReference.chapter,
                          ],
                          readerState.layoutMode.name,
                          readerState.continuousScrolling,
                        ].join(':'),
                      ),
                      onScrollNotification: _handleScrollNotification,
                      books: books,
                      translationId: translationId,
                      book: _resolveCurrentBook(
                        books,
                        readerState.currentReference.bookId,
                      ),
                      chapter: chapter,
                      reference: readerState.currentReference,
                      displayReference: displayReference,
                      fontSize: size,
                      layoutMode: readerState.layoutMode,
                      continuousScrolling: readerState.continuousScrolling,
                      showBookIntroductions: readerState.showBookIntroductions,
                      isSmallDevice: widget.isSmallDevice,
                      bottomOverlayPadding: contentBottomPadding,
                      onVisibleReferenceChanged: (reference) {
                        if (_continuousVisibleReference == reference) return;
                        setState(() {
                          _continuousVisibleReference = reference;
                        });
                        ref
                                .read(visibleReaderReferenceProvider.notifier)
                                .state =
                            reference;
                      },
                    ),
                  )
                : const _ErrorView(message: 'Chapter not found'),
            loading: () => const _LoadingView(),
            error: (error, stack) => _ErrorView(message: 'Error: $error'),
          ),
          loading: () => const _LoadingView(),
          error: (error, stack) => _ErrorView(message: 'Failed to load Bible: $error'),
        );
      },
    );
  }

  void _jumpToAdjacentContinuousChapter(
    WidgetRef ref,
    List<BibleBook> books,
    BibleReference baseReference, {
    required int direction,
  }) {
    final chapterReferences = _flatChapterRefs(books);
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
    ref.read(visibleReaderReferenceProvider.notifier).state = targetReference;
    ref.read(currentReferenceProvider.notifier).setReference(targetReference);
  }

  void _clearSelectionUi() {
    ref.read(selectedVersesProvider.notifier).clear();
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  Widget _buildChapterNavigationBar({
    required double readerBarHeight,
    required BibleReference displayReference,
    required List<BibleBook> books,
    required bool canOpenReferencePicker,
    required bool showVerseSelector,
    required bool continuousScrolling,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        bottom: true,
        child: ChapterBar(
          barHeight: readerBarHeight,
          isFloating: true,
          reference: displayReference,
          books: books,
          canOpenReferencePicker: canOpenReferencePicker,
          showVerseSelector: showVerseSelector,
          onReferenceChanged: (reference) => _handleReferenceChanged(
            reference,
            continuousScrolling: continuousScrolling,
          ),
          onPreviousChapter: () => _handleAdjacentChapter(
            books,
            displayReference,
            continuousScrolling: continuousScrolling,
            direction: -1,
          ),
          onNextChapter: () => _handleAdjacentChapter(
            books,
            displayReference,
            continuousScrolling: continuousScrolling,
            direction: 1,
          ),
        ),
      ),
    );
  }

  void _handleReferenceChanged(
    BibleReference reference, {
    required bool continuousScrolling,
  }) {
    _clearSelectionUi();
    if (continuousScrolling) {
      setState(() {
        _continuousVisibleReference = reference;
      });
      ref.read(visibleReaderReferenceProvider.notifier).state = reference;
    }
    ref.read(currentReferenceProvider.notifier).setReference(reference);
  }

  void _handleAdjacentChapter(
    List<BibleBook> books,
    BibleReference displayReference, {
    required bool continuousScrolling,
    required int direction,
  }) {
    _clearSelectionUi();
    if (books.isEmpty) return;

    // Continuous mode navigates by jumping to the next mounted chapter section.
    // Non-continuous mode delegates to the reference notifier, which owns
    // normal chapter stepping for the single-chapter reader.
    if (continuousScrolling) {
      _jumpToAdjacentContinuousChapter(
        ref,
        books,
        displayReference,
        direction: direction,
      );
      return;
    }

    final navigator = ref.read(currentReferenceProvider.notifier);
    if (direction < 0) {
      navigator.goToPreviousChapter(books);
    } else {
      navigator.goToNextChapter(books);
    }
  }

  Widget _buildSelectionOverlay({
    required List<BibleReference> selectedVerses,
    required List<BibleBook> books,
    required List<UserAnnotation> selectedVerseAnnotations,
    required bool showHighlightPalette,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          child: _VerseSelectionBar(
            references: selectedVerses,
            books: books,
            existingAnnotations: selectedVerseAnnotations,
            showHighlightPalette: showHighlightPalette,
            isBusy: _selectionActionInFlight,
            onDismiss: () {
              if (_selectionActionInFlight) return;
              _clearSelectionUi();
            },
            onHighlightPressed: _toggleHighlightPalette,
            onHighlightSelected: _handleHighlightColorSelected,
            onClearHighlightPressed: _handleClearHighlightPressed,
            onNotePressed: _handleNotePressed,
            onCopyPressed: () =>
                _handleSelectionCopy(books, copiedMessage: 'Verse copied.'),
            onSharePressed: () => _handleSelectionCopy(
              books,
              copiedMessage:
                  'Share text copied. Native share can be added later without changing your notes data.',
            ),
          ),
        ),
      ),
    );
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

BibleVerse? _findVerseInChapter(BibleChapter? chapter, int? verseNumber) {
  if (chapter == null || verseNumber == null) return null;
  for (final verse in chapter.verses) {
    if (verse.number == verseNumber) return verse;
  }
  return null;
}

