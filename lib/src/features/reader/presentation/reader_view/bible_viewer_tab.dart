import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/annotation_providers.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/application/current_chapter_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_bar.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_screen.dart';
import 'package:basic_bible/src/features/settings/application/app_preferences_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/font_size_service.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/gestures.dart'
    show PointerScrollEvent, TapGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

// File map for this reader module:
// - this file: top-level reader coordinators and shell widgets
// - *_state_core.dart: selection state / focus / annotation lookup helpers
// - *_state_rendering.dart: verse-list + continuous rendering flow
// - *_state_document.dart: document-mode rendering details
// - *_state_annotations.dart: parser-note sheets + inline span helpers
// - *_widgets.dart / *_sections.dart: extracted local widgets and support types
part 'bible_viewer_tab_sections.dart';
part 'bible_viewer_tab_shell_snapshot.dart';
part 'bible_viewer_tab_annotation_widgets.dart';
part 'bible_viewer_tab_document_widgets.dart';
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

  final ScrollController _scrollController = ScrollController();
  BibleReference? _continuousVisibleReference;
  // Removed local constants; layout spacing is handled by widgets directly.
  //TODO: Make The Text Size Changeable through Settings
  // Font size is now provided by FontSizeService; listen to changes in build

  double? _lastScroll;
  bool _isHiding = false;
  bool _selectionActionInFlight = false;

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

  void _setSelectionActionInFlight(bool value) {
    if (!mounted || _selectionActionInFlight == value) return;
    setState(() {
      _selectionActionInFlight = value;
    });
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
    final readerState = _watchReaderShellState();
    final contentBottomPadding = _contentBottomPadding(
      hasSelection: readerState.selectedVerses.isNotEmpty,
      showHighlightPalette: readerState.showHighlightPalette,
    );
    final displayReference = _displayReferenceFor(
      currentReference: readerState.currentReference,
      continuousScrolling: readerState.continuousScrolling,
    );

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
          books: readerState.booksAsync.value ?? const [],
          showVerseSelector: readerState.showVerseSelector,
          continuousScrolling: readerState.continuousScrolling,
        ),

        // Selection action tray for highlight / note / copy / share.
        if (readerState.selectedVerses.isNotEmpty &&
            readerState.selectedVerse != null)
          _buildSelectionOverlay(
            selectedVerses: readerState.selectedVerses,
            books: readerState.booksAsync.value ?? const [],
            selectedVerseAnnotations: readerState.selectedVerseAnnotations,
            showHighlightPalette: readerState.showHighlightPalette,
          ),

        // Translation selector removed — translations are selected from HomeScreen
      ],
    );
  }

  _ReaderShellStateSnapshot _watchReaderShellState() {
    final continuousScrolling = ref.watch(continuousScrollingProvider);
    // The outer shell intentionally snapshots all watched reader state in one
    // place so `build()` reads like screen composition instead of a long list
    // of interleaved provider lookups and layout math.
    return _ReaderShellStateSnapshot(
      layoutMode: ref.watch(readerLayoutModeProvider),
      continuousScrolling: continuousScrolling,
      booksAsync: continuousScrolling
          ? ref.watch(bibleBooksProvider)
          : ref.watch(bibleBooksShellProvider),
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
        return readerState.booksAsync.when(
          data: (books) => readerState.chapterAsync.when(
            data: (chapter) => chapter != null
                ? _BibleTextView(
                    controller: _scrollController,
                    books: books,
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

  void _clearSelectionUi(WidgetRef ref) {
    ref.read(selectedVersesProvider.notifier).clear();
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  Widget _buildChapterNavigationBar({
    required double readerBarHeight,
    required BibleReference displayReference,
    required List<BibleBook> books,
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
    _clearSelectionUi(ref);
    if (continuousScrolling) {
      setState(() {
        _continuousVisibleReference = reference;
      });
    }
    ref.read(currentReferenceProvider.notifier).setReference(reference);
  }

  void _handleAdjacentChapter(
    List<BibleBook> books,
    BibleReference displayReference, {
    required bool continuousScrolling,
    required int direction,
  }) {
    _clearSelectionUi(ref);
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
              _clearSelectionUi(ref);
            },
            onHighlightPressed: _toggleHighlightPalette,
            onHighlightSelected: _handleHighlightColorSelected,
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

  void _toggleHighlightPalette() {
    if (_selectionActionInFlight) return;
    final notifier = ref.read(highlightPaletteExpandedProvider.notifier);
    notifier.state = !notifier.state;
  }

  Future<void> _handleHighlightColorSelected(Color color) async {
    if (_selectionActionInFlight) return;
    final selectedReferences = [...ref.read(selectedVersesProvider)];
    if (selectedReferences.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    final existingAnnotations = [...ref.read(selectedVerseAnnotationsProvider)];
    _setSelectionActionInFlight(true);

    try {
      final translation = await resolveCurrentTranslation(ref);
      if (!mounted) return;
      if (translation == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Translation not available.')),
        );
        return;
      }

      for (final reference in selectedReferences) {
        final link = buildAnnotationVerseLink(
          reference: reference,
          translation: translation,
        );
        final existing = existingAnnotations
            .where(
              (annotation) => annotation.touchesReference(
                reference,
                translationId: translation.id,
              ),
            )
            .firstOrNull;
        final annotationToSave = existing != null
            ? existing.copyWith(highlightColorValue: color.toARGB32())
            : UserAnnotation(
                type: UserAnnotationType.highlight,
                primaryVerse: link,
                highlightColorValue: color.toARGB32(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
        await ref
            .read(userAnnotationRepositoryProvider)
            .saveAnnotation(annotationToSave);
      }

      if (!mounted) return;
      ref.read(highlightPaletteExpandedProvider.notifier).state = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            selectedReferences.length == 1
                ? 'Highlight saved.'
                : 'Highlights saved for ${selectedReferences.length} verses.',
          ),
        ),
      );
    } finally {
      _setSelectionActionInFlight(false);
    }
  }

  Future<void> _handleNotePressed() async {
    if (_selectionActionInFlight) return;
    final selectedReferences = [...ref.read(selectedVersesProvider)];
    if (selectedReferences.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final selectedAnnotations = [...ref.read(selectedVerseAnnotationsProvider)];
    _setSelectionActionInFlight(true);

    try {
      final translation = await resolveCurrentTranslation(ref);
      if (!mounted) return;
      if (translation == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Translation not available.')),
        );
        return;
      }
      final selectedLinks = [
        for (final reference in selectedReferences)
          buildAnnotationVerseLink(
            reference: reference,
            translation: translation,
          ),
      ];
      final primaryLink = selectedLinks.first;

      // Promote an existing highlight into the editor only when a single
      // selected verse matches the annotation's primary verse. Multi-select
      // still creates a new note draft anchored by the first selected verse.
      final selectedRef = selectedReferences.length == 1
          ? selectedReferences.first
          : null;
      final existingNote = selectedRef != null
          ? (selectedAnnotations
                .where(
                  (annotation) =>
                      !annotation.hasNoteText &&
                      annotation.primaryVerse.bookId == selectedRef.bookId &&
                      annotation.primaryVerse.chapter == selectedRef.chapter &&
                      annotation.primaryVerse.verse == selectedRef.verse,
                )
                .toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
          : <UserAnnotation>[];

      final saved = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(
            primaryVerse: primaryLink,
            initialLinkedVerses: selectedLinks.skip(1).toList(),
            existingAnnotation: existingNote.isEmpty
                ? null
                : existingNote.first,
          ),
        ),
      );
      if (saved == true && mounted) {
        _clearSelectionUi(ref);
      }
    } finally {
      _setSelectionActionInFlight(false);
    }
  }

  Future<void> _handleSelectionCopy(
    List<BibleBook> books, {
    required String copiedMessage,
  }) async {
    if (_selectionActionInFlight) return;
    final selectedReferences = [...ref.read(selectedVersesProvider)];
    if (selectedReferences.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    _setSelectionActionInFlight(true);

    final text = _selectedVersesText(selectedReferences, books);
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
      }
    } finally {
      _setSelectionActionInFlight(false);
    }
  }

  String _selectedVersesText(
    List<BibleReference> references,
    List<BibleBook> books,
  ) {
    return references
        .map((reference) {
          final verse = _findVerseInBooks(books, reference);
          final bookName = displayBookNameForReference(books, reference.bookId);
          return verse == null
              ? '$bookName ${reference.chapter}:${reference.verse}'
              : '$bookName ${reference.chapter}:${reference.verse} ${verse.text}';
        })
        .join('\n');
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

BibleVerse? _findVerseInBooks(List<BibleBook> books, BibleReference reference) {
  final book = resolveBookFromReference(books, reference.bookId);
  final chapter = book?.chapters
      .where((item) => item.number == reference.chapter)
      .firstOrNull;
  return _findVerseInChapter(chapter, reference.verse);
}

/// Bible text display widget
class _BibleTextView extends ConsumerStatefulWidget {
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
  ConsumerState<_BibleTextView> createState() => _BibleTextViewState();
}

class _BibleTextViewState extends ConsumerState<_BibleTextView> {
  final Map<String, GlobalKey> _verseKeys = <String, GlobalKey>{};
  final Map<String, GlobalKey> _chapterSectionKeys = <String, GlobalKey>{};
  final Map<String, TapGestureRecognizer> _verseTapRecognizers =
      <String, TapGestureRecognizer>{};
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
      _resetVerseTapRecognizers();
    } else if (!widget.continuousScrolling &&
        (oldWidget.book.id != widget.book.id ||
            oldWidget.chapter.number != widget.chapter.number)) {
      _resetVerseTapRecognizers();
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

  void _setSelectedVerseFocusVisible(bool value) {
    if (!mounted || _showSelectedVerseFocus == value) return;
    setState(() {
      _showSelectedVerseFocus = value;
    });
  }

  @override
  void dispose() {
    _resetVerseTapRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listener catches mouse-wheel scroll (PointerScrollEvent) on desktop,
    // which does not set dragDetails on ScrollStartNotification.
    return Listener(
      onPointerDown: (event) {
        final focusedVerseRect = _focusedVerseHitRect();
        if (focusedVerseRect != null &&
            !focusedVerseRect.contains(event.position)) {
          _dismissSelectedVerseFocus();
        }
      },
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) _dismissSelectedVerseFocus();
      },
      child: NotificationListener<ScrollStartNotification>(
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
      ),
    );
  }
}
