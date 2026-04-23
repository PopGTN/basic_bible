import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_selection_view_models.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_detail_screen.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
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
// - this file: top-level reader coordinators and shell widgets
// - *_state_core.dart: selection state / focus / annotation lookup helpers
// - *_state_rendering.dart: verse-list + continuous rendering flow
// - *_state_document.dart: document-mode rendering details
// - *_state_annotations.dart: parser-note sheets + inline span helpers
// - *_widgets.dart / *_sections.dart: extracted local widgets and support types
part 'bible_viewer_tab_sections.dart';
part 'bible_viewer_tab_shell_snapshot.dart';
part 'bible_viewer_tab_annotation_controls.dart';
part 'bible_viewer_tab_annotation_details.dart';
part 'bible_viewer_tab_document_widgets.dart';
part 'bible_viewer_tab_personal_notes.dart';
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
  static const _maxVersesPerNoteSelection = 250;

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
  }

  void _handleScrollNotification(ScrollNotification notification) {
    final current = notification.metrics.pixels;
    final max = notification.metrics.maxScrollExtent;
    final delta = current - (_lastScroll ?? current);
    _lastScroll = current;

    if (delta.abs() < 1) return;

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
  void dispose() {
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

    // Shell books are always available quickly (metadata only, no verses).
    // Use them for the nav bar and picker so they work instantly regardless
    // of whether the full verse data has finished loading in continuous mode.
    final navBooks = readerState.shellBooksAsync.value ?? const [];
    final canOpenReferencePicker =
        !readerState.booksAsync.isLoading &&
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
      booksAsync: shellBooksAsync,
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
        return readerState.booksAsync.when(
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
                          ref.read(currentTranslationProvider),
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
                      translationId: ref.read(currentTranslationProvider),
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
    ref.read(visibleReaderReferenceProvider.notifier).state = targetReference;
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
    _clearSelectionUi(ref);
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

  void _toggleHighlightPalette() {
    if (_selectionActionInFlight) return;
    final notifier = ref.read(highlightPaletteExpandedProvider.notifier);
    notifier.state = !notifier.state;
  }

  List<UserAnnotation> _standaloneHighlightAnnotationsForSelection({
    required List<UserAnnotation> annotations,
    required List<BibleReference> references,
    required String translationId,
  }) {
    final matchedById = <int?, UserAnnotation>{};
    for (final annotation in annotations) {
      if (!annotation.isHighlightOnly) continue;
      final touchesSelection = references.any(
        (reference) => annotation.touchesReference(
          reference,
          translationId: translationId,
        ),
      );
      if (!touchesSelection) continue;
      matchedById[annotation.id] = annotation;
    }
    return matchedById.values.toList();
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

      final repository = ref.read(userAnnotationRepositoryProvider);

      // Find all standalone highlight annotations that overlap the selection.
      final highlightAnnotations = _standaloneHighlightAnnotationsForSelection(
        annotations: existingAnnotations,
        references: selectedReferences,
        translationId: translation.id,
      );

      // Remove the selected verses from every overlapping annotation.
      // Processing each annotation ID once prevents redundant saves when multiple
      // selected verses belong to the same multi-verse annotation.
      // This also handles the "recolour a subset" case correctly: if an annotation
      // covers verses 1–5 and only verse 3 is selected, the annotation is trimmed
      // to 1–2, 4–5 (preserving the original colour there) before the new
      // per-verse annotation is created for verse 3 below.
      final processedIds = <int?>{};
      for (final annotation in highlightAnnotations) {
        final annotationId = annotation.id;
        if (processedIds.contains(annotationId)) continue;
        processedIds.add(annotationId);

        final trimmed = removeReferencesFromStandaloneHighlight(
          annotation,
          selectedReferences,
          translationId: translation.id,
        );
        if (trimmed == null) {
          if (annotationId != null) {
            await repository.deleteAnnotation(annotationId);
          }
        } else {
          await repository.saveAnnotation(trimmed);
        }
      }

      // Create one fresh per-verse annotation with the chosen colour for every
      // selected reference. We never update an existing multi-verse annotation
      // in-place because that would silently recolour unselected verses too.
      for (final reference in selectedReferences) {
        await repository.saveAnnotation(
          UserAnnotation(
            type: UserAnnotationType.highlight,
            primaryVerse: buildAnnotationVerseLink(
              reference: reference,
              translation: translation,
            ),
            highlightColorValue: color.toARGB32(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
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

  Future<void> _handleClearHighlightPressed() async {
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

      final highlightAnnotations = _standaloneHighlightAnnotationsForSelection(
        annotations: existingAnnotations,
        references: selectedReferences,
        translationId: translation.id,
      );
      if (highlightAnnotations.isEmpty) {
        ref.read(highlightPaletteExpandedProvider.notifier).state = false;
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Only standalone highlights can be removed here. Edit a note to change its highlight.',
            ),
          ),
        );
        return;
      }

      final repository = ref.read(userAnnotationRepositoryProvider);
      for (final annotation in highlightAnnotations) {
        final nextAnnotation = removeReferencesFromStandaloneHighlight(
          annotation,
          selectedReferences,
          translationId: translation.id,
        );
        if (nextAnnotation == null) {
          final annotationId = annotation.id;
          if (annotationId != null) {
            await repository.deleteAnnotation(annotationId);
          }
        } else {
          await repository.saveAnnotation(nextAnnotation);
        }
      }

      if (!mounted) return;
      ref.read(highlightPaletteExpandedProvider.notifier).state = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            highlightAnnotations.length == 1
                ? 'Highlight removed.'
                : 'Highlights removed.',
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
    _setSelectionActionInFlight(true);

    try {
      if (selectedReferences.length > _maxVersesPerNoteSelection) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Notes can be linked to up to $_maxVersesPerNoteSelection verses at once. '
              'Please select a smaller range.',
            ),
          ),
        );
        return;
      }

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

      // Always open a fresh note editor. Highlights are a separate annotation
      // type and must not be automatically merged with notes — the user must
      // explicitly edit an existing annotation to combine them.
      final saved = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(
            primaryVerse: selectedLinks.first,
            initialLinkedVerses: selectedLinks.skip(1).toList(),
          ),
        ),
      );
      if (saved == true && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _clearSelectionUi(ref);
        });
      }
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _setSelectionActionInFlight(false);
      });
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

    try {
      final text = await _selectedVersesText(selectedReferences, books);
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(copiedMessage)));
      }
    } finally {
      _setSelectionActionInFlight(false);
    }
  }

  Future<String> _selectedVersesText(
    List<BibleReference> references,
    List<BibleBook> books,
  ) async {
    final repository = ref.read(bibleRepositoryProvider);
    final translationId = ref.read(currentTranslationProvider);
    final chapterCache = <String, Future<BibleChapter?>>{};

    Future<BibleChapter?> chapterFor(BibleReference reference) {
      final key = '${reference.bookId}:${reference.chapter}';
      return chapterCache.putIfAbsent(
        key,
        () => repository.loadChapterVerses(
          translationId,
          reference.bookId,
          reference.chapter,
        ),
      );
    }

    final lines = <String>[];
    for (final reference in references) {
      final chapter = await chapterFor(reference);
      final verse = _findVerseInChapter(chapter, reference.verse);
      final bookName = displayBookNameForReference(books, reference.bookId);
      lines.add(
        verse == null
            ? '$bookName ${reference.chapter}:${reference.verse}'
            : '$bookName ${reference.chapter}:${reference.verse} ${verse.text}',
      );
    }
    return lines.join('\n');
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

/// Bible text display widget
class _BibleTextView extends ConsumerStatefulWidget {
  const _BibleTextView({
    super.key,
    required this.onScrollNotification,
    required this.books,
    required this.translationId,
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

  final void Function(ScrollNotification) onScrollNotification;
  final List<BibleBook> books;
  final String translationId;
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
  // Owned here so each _BibleTextView instance has exactly one ScrollPosition.
  // Previously it was passed from the parent, causing a brief double-attach
  // when the widget key changed and old/new instances overlapped during disposal.
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _verseKeys = <String, GlobalKey>{};
  final Map<String, TapGestureRecognizer> _verseTapRecognizers =
      <String, TapGestureRecognizer>{};
  final ItemScrollController _continuousItemScrollController =
      ItemScrollController();
  final ItemPositionsListener _continuousItemPositionsListener =
      ItemPositionsListener.create();
  List<_ContinuousChapterSection> _continuousSections =
      <_ContinuousChapterSection>[];
  final Map<String, Future<BibleChapter?>> _continuousChapterFutures =
      <String, Future<BibleChapter?>>{};
  final Map<String, BibleChapter> _hydratedContinuousChapters =
      <String, BibleChapter>{};
  BibleReference? _selectionAnchorReference;
  bool _showSelectedVerseFocus = true;
  bool _visibleSyncQueued = false;
  // Key for the ScrollablePositionedList widget. Assigning a new UniqueKey()
  // forces a full SPL rebuild, which lets us position at initialScrollIndex
  // exactly — bypassing the position estimation that accumulates error over
  // hundreds of unhydrated chapters on large jumps.
  Key _scrollableListKey = const ValueKey('continuous_list');
  int _scrollableListInitialIndex = 0;

  void _storeHydratedContinuousChapter(String key, BibleChapter chapter) {
    if (!mounted) return;
    // Defer to the next frame. Chapter futures can complete while
    // ScrollablePositionedList is mid-layout; a synchronous setState at that
    // point mutates the render tree and triggers the assertion:
    // "RenderIndexedSemantics was mutated in RenderSliverList.performLayout".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _hydratedContinuousChapters[key] = chapter;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _rebuildContinuousSections();
    final initialReference =
        widget.continuousScrolling &&
            _continuousSectionIndexFor(widget.displayReference) != null
        ? widget.displayReference
        : widget.reference;
    // Seed the initial scroll position so the list opens at the right chapter
    // without any scrollTo animation (avoids position estimation error on first
    // render).
    _scrollableListInitialIndex =
        _continuousSectionIndexFor(initialReference) ?? 0;
    // Wider radius on initial load so the surrounding chapters are ready
    // before the user starts scrolling.
    _prefetchContinuousChapterWindow(initialReference, radius: 5);
    _scheduleVerseFocus();
  }

  @override
  void didUpdateWidget(covariant _BibleTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.translationId != widget.translationId ||
        oldWidget.books != widget.books) {
      _continuousChapterFutures.clear();
      _hydratedContinuousChapters.clear();
      _rebuildContinuousSections();
      final targetReference =
          widget.continuousScrolling &&
              _continuousSectionIndexFor(widget.displayReference) != null
          ? widget.displayReference
          : widget.reference;
      if (widget.continuousScrolling) {
        final targetIndex = _continuousSectionIndexFor(targetReference);
        if (targetIndex != null) {
          _resetScrollableListAt(targetIndex);
          widget.onVisibleReferenceChanged(targetReference);
        }
      }
      _prefetchContinuousChapterWindow(targetReference, radius: 5);
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
      // Wider radius on an explicit navigation jump so surrounding chapters
      // are ready before the user starts scrolling from the new position.
      _prefetchContinuousChapterWindow(widget.reference, radius: 5);
      // Always scroll to the target chapter. In continuous mode verse
      // GlobalKeys are suppressed (SPL dual-viewport constraint), so
      // _scheduleVerseFocus is a no-op here — chapter-level positioning is the
      // best we can do.
      _scheduleChapterFocus();
    }
  }

  /// Rebuilds the ScrollablePositionedList at [targetIndex] by assigning a new
  /// key. Used for large-distance navigation where scrollTo() accumulates too
  /// much position estimation error to land reliably.
  void _resetScrollableListAt(int targetIndex) {
    setState(() {
      _scrollableListInitialIndex = targetIndex;
      _scrollableListKey = UniqueKey();
    });
  }

  void _setSelectedVerseFocusVisible(bool value) {
    if (!mounted || _showSelectedVerseFocus == value) return;
    setState(() {
      _showSelectedVerseFocus = value;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
