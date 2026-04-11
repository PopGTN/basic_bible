import 'reference_screen.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/annotation_providers.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/note_editor_screen.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/application/current_chapter_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/widgets/reference_bar.dart';
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
    // Example: if you want to read a provider in here:
    // final someValue = ref.watch(someProvider);
    final layoutMode = ref.watch(readerLayoutModeProvider);
    final continuousScrolling = ref.watch(continuousScrollingProvider);

    // In continuous scroll mode, load all verses for pre-rendering.
    // Otherwise, use shell loading for fast navigation UI.
    final booksAsync = continuousScrolling
        ? ref.watch(bibleBooksProvider)
        : ref.watch(bibleBooksShellProvider);

    final currentReference = ref.watch(currentReferenceProvider);
    final chapterAsync = ref.watch(currentChapterProvider);
    final showBookIntroductions = ref.watch(showBookIntroductionsProvider);
    final showVerseSelector = ref.watch(showVerseSelectorProvider);
    final selectedVerses = ref.watch(selectedVersesProvider);
    final selectedVerse = ref.watch(selectedVerseProvider);
    final showHighlightPalette = ref.watch(highlightPaletteExpandedProvider);
    final selectedVerseAnnotations = ref.watch(
      selectedVerseAnnotationsProvider,
    );
    const readerBarHeight = 56.0;
    const readerBarBottomInset = 12.0;
    const readerBarBottomPadding = readerBarHeight + readerBarBottomInset + 8;
    final selectionBarHeight = selectedVerses.isEmpty
        ? 0.0
        : showHighlightPalette
        ? 140.0
        : 92.0;
    final contentBottomPadding =
        readerBarBottomPadding +
        selectionBarHeight +
        (selectedVerses.isEmpty ? 0 : 12);

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
                ref.read(selectedVersesProvider.notifier).clear();
                ref.read(highlightPaletteExpandedProvider.notifier).state =
                    false;
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
                ref.read(selectedVersesProvider.notifier).clear();
                ref.read(highlightPaletteExpandedProvider.notifier).state =
                    false;
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
                ref.read(selectedVersesProvider.notifier).clear();
                ref.read(highlightPaletteExpandedProvider.notifier).state =
                    false;
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
        if (selectedVerses.isNotEmpty && selectedVerse != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                child: _VerseSelectionBar(
                  references: selectedVerses,
                  books: booksAsync.value ?? const [],
                  existingAnnotations: selectedVerseAnnotations,
                  showHighlightPalette: showHighlightPalette,
                  isBusy: _selectionActionInFlight,
                  onDismiss: () {
                    if (_selectionActionInFlight) return;
                    ref.read(selectedVersesProvider.notifier).clear();
                    ref.read(highlightPaletteExpandedProvider.notifier).state =
                        false;
                  },
                  onHighlightPressed: () {
                    if (_selectionActionInFlight) return;
                    final notifier = ref.read(
                      highlightPaletteExpandedProvider.notifier,
                    );
                    notifier.state = !notifier.state;
                  },
                  onHighlightSelected: (color) async {
                    if (_selectionActionInFlight) return;
                    final selectedReferences = [
                      ...ref.read(selectedVersesProvider),
                    ];
                    if (selectedReferences.isEmpty) return;
                    // Snapshot existing annotations before any async gap so we
                    // can merge the new color into them instead of creating a
                    // second orphan entry for the same verse.
                    final existingAnnotations = [
                      ...ref.read(selectedVerseAnnotationsProvider),
                    ];
                    _setSelectionActionInFlight(true);

                    try {
                      final translation = await resolveCurrentTranslation(ref);
                      if (!context.mounted) return;
                      if (translation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Translation not available.'),
                          ),
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
                              (a) => a.touchesReference(
                                reference,
                                translationId: translation.id,
                              ),
                            )
                            .firstOrNull;
                        final annotationToSave = existing != null
                            ? existing.copyWith(
                                highlightColorValue: color.toARGB32(),
                              )
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
                      if (!context.mounted) return;
                      ref
                              .read(highlightPaletteExpandedProvider.notifier)
                              .state =
                          false;
                      ScaffoldMessenger.of(context).showSnackBar(
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
                  },
                  onNotePressed: () async {
                    if (_selectionActionInFlight) return;
                    final selectedReferences = [
                      ...ref.read(selectedVersesProvider),
                    ];
                    if (selectedReferences.isEmpty) return;
                    final selectedAnnotations = [
                      ...ref.read(selectedVerseAnnotationsProvider),
                    ];
                    _setSelectionActionInFlight(true);

                    try {
                      final translation = await resolveCurrentTranslation(ref);
                      if (!context.mounted) return;
                      if (translation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Translation not available.'),
                          ),
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
                      final link = selectedLinks.first;
                      // Promote an existing annotation into the editor only
                      // when ALL of these are true:
                      //  1. Single verse selected (multi-select always creates new)
                      //  2. The annotation has no text yet (pure highlight) —
                      //     merges the highlight + first note into one entry
                      //  3. The selected verse is the annotation's PRIMARY verse,
                      //     not just a linked verse — so notes on verse 1 don't
                      //     accidentally open an unrelated annotation that merely
                      //     has verse 1 in its linked-verse list.
                      final selectedRef = selectedReferences.length == 1
                          ? selectedReferences.first
                          : null;
                      final existingNote = selectedRef != null
                          ? (selectedAnnotations
                                .where(
                                  (a) =>
                                      !a.hasNoteText &&
                                      a.primaryVerse.bookId ==
                                          selectedRef.bookId &&
                                      a.primaryVerse.chapter ==
                                          selectedRef.chapter &&
                                      a.primaryVerse.verse == selectedRef.verse,
                                )
                                .toList()
                              ..sort(
                                (a, b) => b.updatedAt.compareTo(a.updatedAt),
                              ))
                          : <UserAnnotation>[];
                      final saved = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(
                            primaryVerse: link,
                            initialLinkedVerses: selectedLinks.skip(1).toList(),
                            existingAnnotation: existingNote.isEmpty
                                ? null
                                : existingNote.first,
                          ),
                        ),
                      );
                      if (saved == true && context.mounted) {
                        ref.read(selectedVersesProvider.notifier).clear();
                        ref
                                .read(highlightPaletteExpandedProvider.notifier)
                                .state =
                            false;
                      }
                    } finally {
                      _setSelectionActionInFlight(false);
                    }
                  },
                  onCopyPressed: () async {
                    if (_selectionActionInFlight) return;
                    final selectedReferences = [
                      ...ref.read(selectedVersesProvider),
                    ];
                    if (selectedReferences.isEmpty) return;
                    _setSelectionActionInFlight(true);
                    final books = booksAsync.value ?? const <BibleBook>[];
                    final text = selectedReferences
                        .map((reference) {
                          final verse = _findVerseInBooks(books, reference);
                          final bookName = displayBookNameForReference(
                            books,
                            reference.bookId,
                          );
                          return verse == null
                              ? '$bookName ${reference.chapter}:${reference.verse}'
                              : '$bookName ${reference.chapter}:${reference.verse} ${verse.text}';
                        })
                        .join('\n');
                    try {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verse copied.')),
                        );
                      }
                    } finally {
                      _setSelectionActionInFlight(false);
                    }
                  },
                  onSharePressed: () async {
                    if (_selectionActionInFlight) return;
                    final selectedReferences = [
                      ...ref.read(selectedVersesProvider),
                    ];
                    if (selectedReferences.isEmpty) return;
                    _setSelectionActionInFlight(true);
                    final books = booksAsync.value ?? const <BibleBook>[];
                    final text = selectedReferences
                        .map((reference) {
                          final verse = _findVerseInBooks(books, reference);
                          final bookName = displayBookNameForReference(
                            books,
                            reference.bookId,
                          );
                          return verse == null
                              ? '$bookName ${reference.chapter}:${reference.verse}'
                              : '$bookName ${reference.chapter}:${reference.verse} ${verse.text}';
                        })
                        .join('\n');
                    try {
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Share text copied. Native share can be added later without changing your notes data.',
                            ),
                          ),
                        );
                      }
                    } finally {
                      _setSelectionActionInFlight(false);
                    }
                  },
                ),
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

  void _resetVerseTapRecognizers() {
    for (final recognizer in _verseTapRecognizers.values) {
      recognizer.dispose();
    }
    _verseTapRecognizers.clear();
  }

  GlobalKey _verseKey(String bookId, int chapterNumber, int verseNumber) {
    final key = '$bookId:$chapterNumber:$verseNumber';
    return _verseKeys.putIfAbsent(key, GlobalKey.new);
  }

  GlobalKey _chapterSectionKey(String bookId, int chapterNumber) {
    final key = '$bookId:$chapterNumber';
    return _chapterSectionKeys.putIfAbsent(key, GlobalKey.new);
  }

  TapGestureRecognizer _verseTapRecognizer(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final key = '$bookId:$chapterNumber:${verse.number}';
    final recognizer = _verseTapRecognizers.putIfAbsent(
      key,
      TapGestureRecognizer.new,
    );
    recognizer.onTap = () => _selectVerse(bookId, chapterNumber, verse);
    return recognizer;
  }

  bool _isFocusedVerse(String bookId, int chapterNumber, BibleVerse verse) =>
      _hasActiveVerseFocus &&
      widget.reference.bookId == bookId &&
      widget.reference.chapter == chapterNumber &&
      widget.reference.verse == verse.number;

  BibleReference _verseReference(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    return BibleReference(
      bookId: bookId,
      chapter: chapterNumber,
      verse: verse.number,
    );
  }

  bool _isSelectedVerse(String bookId, int chapterNumber, BibleVerse verse) {
    final selectedVerses = ref.watch(selectedVersesProvider);
    return selectedVerses.any(
      (reference) =>
          reference.bookId == bookId &&
          reference.chapter == chapterNumber &&
          reference.verse == verse.number,
    );
  }

  List<UserAnnotation> _annotationsForVerse(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final translationId = ref.watch(currentTranslationProvider);
    final annotations = ref.watch(visibleChapterAnnotationsProvider);
    final reference = _verseReference(bookId, chapterNumber, verse);
    return annotations
        .where(
          (annotation) => annotation.touchesReference(
            reference,
            translationId: translationId,
          ),
        )
        .toList();
  }

  bool _hasPersonalNotes(List<UserAnnotation> verseAnnotations) {
    return verseAnnotations.any((annotation) => annotation.hasNoteText);
  }

  List<UserAnnotation> _personalNoteAnnotations(
    List<UserAnnotation> verseAnnotations,
  ) {
    final notes = verseAnnotations
        .where((annotation) => annotation.hasNoteText)
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Color? _highlightColorForVerse(
    BuildContext context,
    List<UserAnnotation> verseAnnotations,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    final matches = verseAnnotations
        .where(
          (annotation) =>
              annotation.highlightColorValue != null &&
              annotation.touchesReference(
                _verseReference(bookId, chapterNumber, verse),
                translationId: ref.watch(currentTranslationProvider),
              ),
        )
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    Color? blendedColor;
    final fallback = Theme.of(context).colorScheme.secondary;
    for (final annotation in matches) {
      final layer = annotationColorFromValue(
        annotation.highlightColorValue,
        fallback,
      ).withValues(alpha: 0.24);
      blendedColor = blendedColor == null
          ? layer
          : Color.alphaBlend(layer, blendedColor);
    }

    return blendedColor;
  }

  // Convenience wrappers used inside collection-literal for-loops (paragraph
  // and poetry document sections) where Dart does not allow intermediate local
  // variable declarations. Each wrapper calls _annotationsForVerse once.
  bool _docVerseHasPersonalNotes(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) => _hasPersonalNotes(_annotationsForVerse(bookId, chapterNumber, verse));

  Color? _docVerseHighlightColor(
    BuildContext context,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) => _highlightColorForVerse(
    context,
    _annotationsForVerse(bookId, chapterNumber, verse),
    bookId,
    chapterNumber,
    verse,
  );

  BibleChapter? _chapterForReference(String bookId, int chapterNumber) {
    for (final book in widget.books) {
      if (book.id != bookId) continue;
      for (final chapter in book.chapters) {
        if (chapter.number == chapterNumber) return chapter;
      }
    }
    return null;
  }

  bool _chapterHasVerse(BibleChapter? chapter, int verseNumber) =>
      chapter?.verses.any((verse) => verse.number == verseNumber) ?? false;

  bool _sharesHighlightedAnnotationWithVerse(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
    int otherVerseNumber,
  ) {
    final chapter = _chapterForReference(bookId, chapterNumber);
    if (!_chapterHasVerse(chapter, otherVerseNumber)) return false;

    final translationId = ref.watch(currentTranslationProvider);
    final annotations = ref.watch(visibleChapterAnnotationsProvider);
    final currentReference = _verseReference(bookId, chapterNumber, verse);
    final otherReference = BibleReference(
      bookId: bookId,
      chapter: chapterNumber,
      verse: otherVerseNumber,
    );

    return annotations.any(
      (annotation) =>
          annotation.highlightColorValue != null &&
          annotation.touchesReference(
            currentReference,
            translationId: translationId,
          ) &&
          annotation.touchesReference(
            otherReference,
            translationId: translationId,
          ),
    );
  }

  bool _joinsHighlightedRunWithPrevious(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) => _sharesHighlightedAnnotationWithVerse(
    bookId,
    chapterNumber,
    verse,
    verse.number - 1,
  );

  bool _joinsHighlightedRunWithNext(
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) => _sharesHighlightedAnnotationWithVerse(
    bookId,
    chapterNumber,
    verse,
    verse.number + 1,
  );

  Color _selectionTint(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final alpha = Theme.of(context).brightness == Brightness.dark ? 0.16 : 0.1;
    return colors.secondary.withValues(alpha: alpha);
  }

  Color? _selectionAwareBackground(
    BuildContext context, {
    required bool isSelected,
    Color? baseBackground,
  }) {
    if (!isSelected) return baseBackground;
    final selectionTint = _selectionTint(context);
    if (baseBackground == null) return selectionTint;
    return Color.alphaBlend(selectionTint, baseBackground);
  }

  void _selectVerse(String bookId, int chapterNumber, BibleVerse verse) {
    ref
        .read(selectedVersesProvider.notifier)
        .toggle(_verseReference(bookId, chapterNumber, verse));
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  Future<void> _showPersonalNotesSheet(
    BuildContext context, {
    required String bookId,
    required int chapterNumber,
    required BibleVerse verse,
    required List<UserAnnotation> verseAnnotations,
  }) async {
    final noteAnnotations = _personalNoteAnnotations(verseAnnotations);
    if (noteAnnotations.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _PersonalNotesSheet(
          referenceLabel:
              '${displayBookNameForReference(widget.books, bookId)} '
              '$chapterNumber:${verse.number}',
          verseText: verse.text,
          books: widget.books,
          annotations: noteAnnotations,
          onOpenReference: (annotation) async {
            if (!context.mounted) return;
            final translationId = annotation.primaryVerse.translationId;
            final available = await ref.read(
              availableTranslationsProvider.future,
            );
            if (!context.mounted) return;
            final exists = available.any((t) => t.id == translationId);
            if (exists) {
              await ref
                  .read(currentTranslationProvider.notifier)
                  .setTranslation(translationId);
            }
            if (!context.mounted) return;
            await ref
                .read(currentReferenceProvider.notifier)
                .setReference(annotation.primaryVerse.reference);
            if (context.mounted) Navigator.of(context).pop();
          },
          onEdit: (annotation) async {
            if (!context.mounted) return;
            final translationId = annotation.primaryVerse.translationId;
            final available = await ref.read(
              availableTranslationsProvider.future,
            );
            if (!context.mounted) return;
            final exists = available.any((t) => t.id == translationId);
            if (exists) {
              await ref
                  .read(currentTranslationProvider.notifier)
                  .setTranslation(translationId);
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(
                  primaryVerse: annotation.primaryVerse,
                  existingAnnotation: annotation,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _dismissSelectedVerseFocus() {
    if (!_hasActiveVerseFocus || !mounted) return;
    setState(() {
      _showSelectedVerseFocus = false;
    });
  }

  Rect? _focusedVerseHitRect() {
    if (!_hasActiveVerseFocus) return null;
    final verseNumber = widget.reference.verse;
    if (verseNumber == null) return null;

    final targetContext = _verseKey(
      widget.reference.bookId,
      widget.reference.chapter,
      verseNumber,
    ).currentContext;
    final renderBox = targetContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;

    final size = renderBox.size;
    if (size.isEmpty) return null;

    final topLeft = renderBox.localToGlobal(Offset.zero);
    return topLeft & size;
  }

  @override
  void dispose() {
    _resetVerseTapRecognizers();
    super.dispose();
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
    final base =
        Color.lerp(colors.onSurfaceVariant, colors.onSurface, 0.3) ??
        colors.onSurfaceVariant;
    if (!_hasActiveVerseFocus ||
        _isFocusedVerse(bookId, chapterNumber, verse)) {
      return base;
    }
    return base.withValues(alpha: 0.58);
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

  Widget _buildVerse(BuildContext context, BibleVerse verse) {
    final verseKey = _verseKey(
      widget.book.id,
      widget.chapter.number,
      verse.number,
    );
    final hasAnnotations = _hasParserNotes(verse);
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
    final verseAnnotations = _annotationsForVerse(
      widget.book.id,
      widget.chapter.number,
      verse,
    );
    final hasPersonalNotes = _hasPersonalNotes(verseAnnotations);
    final noteAnnotations = _personalNoteAnnotations(verseAnnotations);
    final highlightColor = _highlightColorForVerse(
      context,
      verseAnnotations,
      widget.book.id,
      widget.chapter.number,
      verse,
    );
    final isSelected = _isSelectedVerse(
      widget.book.id,
      widget.chapter.number,
      verse,
    );
    final containerColor = _selectionAwareBackground(
      context,
      isSelected: isSelected,
      baseBackground: highlightColor,
    );

    return Padding(
      key: verseKey,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () => _selectVerse(widget.book.id, widget.chapter.number, verse),
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
                        backgroundColor: containerColor,
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
                      bookId: widget.book.id,
                      chapterNumber: widget.chapter.number,
                      verse: verse,
                      verseAnnotations: noteAnnotations,
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
                        backgroundColor: containerColor,
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
                  onTap: () => _selectVerse(bookId, chapterNumber, verse),
                ),
              ),
            ),
            ..._buildVerseContentSpans(
              context,
              verse,
              bodyColor: _verseTextColor(context, bookId, chapterNumber, verse),
              isSelectedVerse: _isSelectedVerse(bookId, chapterNumber, verse),
              backgroundColor: _selectionAwareBackground(
                context,
                isSelected: _isSelectedVerse(bookId, chapterNumber, verse),
                baseBackground: _docVerseHighlightColor(
                  context,
                  bookId,
                  chapterNumber,
                  verse,
                ),
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
              child: Container(
                decoration: BoxDecoration(
                  color: _selectionAwareBackground(
                    context,
                    isSelected: _isSelectedVerse(bookId, chapterNumber, verse),
                    baseBackground: _docVerseHighlightColor(
                      context,
                      bookId,
                      chapterNumber,
                      verse,
                    ),
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      _joinsHighlightedRunWithPrevious(
                            bookId,
                            chapterNumber,
                            verse,
                          )
                          ? 4
                          : 12,
                    ),
                    bottom: Radius.circular(
                      _joinsHighlightedRunWithNext(bookId, chapterNumber, verse)
                          ? 4
                          : 12,
                    ),
                  ),
                  border: _isSelectedVerse(bookId, chapterNumber, verse)
                      ? Border(
                          bottom: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2.5,
                          ),
                        )
                      : null,
                ),
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
                        backgroundColor: _selectionAwareBackground(
                          context,
                          isSelected: _isSelectedVerse(
                            bookId,
                            chapterNumber,
                            verse,
                          ),
                          baseBackground: _docVerseHighlightColor(
                            context,
                            bookId,
                            chapterNumber,
                            verse,
                          ),
                        ),
                        applySelectionTint: false,
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

  /// Returns true when the verse has parser-originated footnotes or
  /// cross-references. This is entirely separate from personal user annotations
  /// ([_annotationsForVerse]) and drives the source-content details sheet only.
  bool _hasParserNotes(BibleVerse verse) {
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
    bool isSelectedVerse = false,
    Color? backgroundColor,
    bool applySelectionTint = true,
    TapGestureRecognizer? recognizer,
  }) {
    final spans = _displaySpans(verse);
    final effectiveBackgroundColor = applySelectionTint
        ? _selectionAwareBackground(
            context,
            isSelected: isSelectedVerse,
            baseBackground: backgroundColor,
          )
        : backgroundColor;
    if (spans.isEmpty) {
      return [
        TextSpan(
          text: verse.text,
          recognizer: recognizer,
          style: TextStyle(
            color: bodyColor,
            backgroundColor: effectiveBackgroundColor,
          ),
        ),
      ];
    }

    final baseColor = bodyColor ?? Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);

    final inlineSpans = <InlineSpan>[];

    for (final span in spans) {
      inlineSpans.add(
        TextSpan(
          text: _spanText(span),
          recognizer: recognizer,
          style: TextStyle(
            color: _spanColor(span.kind, baseColor, secondaryColor),
            fontStyle: _spanFontStyle(span.kind),
            fontWeight: _spanFontWeight(
              span.kind,
              boldDivineName: boldDivineName,
            ),
            decoration: _spanDecoration(
              span.kind,
              underlineProperNames: underlineProperNames,
            ),
            backgroundColor: effectiveBackgroundColor,
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
    // Carry the dimming alpha from baseColor so verse-focus fading applies
    // uniformly to all span kinds, including red-letter and word spans.
    final alpha = baseColor?.a ?? 1.0;
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return Colors.red.shade700.withValues(alpha: alpha);
      case BibleVerseSpanKind.word:
        return secondaryColor.withValues(alpha: alpha);
      default:
        return baseColor;
    }
  }

  FontStyle _spanFontStyle(BibleVerseSpanKind kind) {
    switch (kind) {
      case BibleVerseSpanKind.translatorAddition:
      case BibleVerseSpanKind.quote:
      case BibleVerseSpanKind.poetry:
      case BibleVerseSpanKind.selah:
      case BibleVerseSpanKind.emphasis:
      case BibleVerseSpanKind.italic:
      case BibleVerseSpanKind.foreignLanguage:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(
    BibleVerseSpanKind kind, {
    bool boldDivineName = false,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.divineNameTag:
        return boldDivineName ? FontWeight.w700 : FontWeight.normal;
      case BibleVerseSpanKind.acrosticHeading:
      case BibleVerseSpanKind.bold:
      case BibleVerseSpanKind.keyword:
        return FontWeight.w700;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(
    BibleVerseSpanKind kind, {
    bool underlineProperNames = true,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.word:
      case BibleVerseSpanKind.properName:
        return underlineProperNames ? TextDecoration.underline : null;
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

class _VerseDetailsSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
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
                  children: versePreview.inlineSpans(
                    colors,
                    boldDivineName: boldDivineName,
                    underlineProperNames: underlineProperNames,
                  ),
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
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: l10n.readerFootnotesTooltip,
      child: Material(
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
      ),
    );
  }
}

class _VerseNoteButton extends StatelessWidget {
  const _VerseNoteButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: l10n.readerNotesTooltip,
      child: Material(
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
              Icons.sticky_note_2_outlined,
              size: compact ? 14 : 18,
              color: colors.secondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineVerseSelector extends StatelessWidget {
  const _InlineVerseSelector({
    required this.verseNumber,
    required this.color,
    required this.isSelected,
    required this.hasNote,
    required this.onTap,
  });

  final int verseNumber;
  final Color color;
  final bool isSelected;
  final bool hasNote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withValues(alpha: 0.16)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$verseNumber',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            if (hasNote) ...[
              const SizedBox(width: 3),
              Icon(
                Icons.bookmark_rounded,
                size: 12,
                color: theme.colorScheme.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerseSelectionBar extends StatelessWidget {
  const _VerseSelectionBar({
    required this.references,
    required this.books,
    required this.existingAnnotations,
    required this.showHighlightPalette,
    required this.isBusy,
    required this.onDismiss,
    required this.onHighlightPressed,
    required this.onHighlightSelected,
    required this.onNotePressed,
    required this.onCopyPressed,
    required this.onSharePressed,
  });

  final List<BibleReference> references;
  final List<BibleBook> books;
  final List<UserAnnotation> existingAnnotations;
  final bool showHighlightPalette;
  final bool isBusy;
  final VoidCallback onDismiss;
  final VoidCallback onHighlightPressed;
  final ValueChanged<Color> onHighlightSelected;
  final VoidCallback onNotePressed;
  final VoidCallback onCopyPressed;
  final VoidCallback onSharePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstReference = references.first;
    final referenceLabel = references.length == 1
        ? '${displayBookNameForReference(books, firstReference.bookId)} '
              '${firstReference.chapter}:${firstReference.verse ?? ''}'
        : '${references.length} verses selected';
    final hasSavedNote = existingAnnotations.any(
      (annotation) => annotation.hasNoteText,
    );
    final hasHighlight = existingAnnotations.any(
      (annotation) => annotation.highlightColorValue != null,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    referenceLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasSavedNote || hasHighlight)
                  Text(
                    [
                      if (hasSavedNote) 'saved note',
                      if (hasHighlight) 'saved highlight',
                    ].join(' • '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                IconButton(
                  onPressed: isBusy ? null : onDismiss,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SelectionActionButton(
                    icon: Icons.highlight_alt_rounded,
                    label: 'Highlight',
                    onPressed: isBusy ? null : onHighlightPressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.note_alt_outlined,
                    label: 'Note',
                    onPressed: isBusy ? null : onNotePressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.copy_all_outlined,
                    label: 'Copy',
                    onPressed: isBusy ? null : onCopyPressed,
                  ),
                  _SelectionActionButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: isBusy ? null : onSharePressed,
                  ),
                ],
              ),
            ),
            if (showHighlightPalette) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in annotationHighlightPalette)
                    InkWell(
                      onTap: isBusy ? null : () => onHighlightSelected(color),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.onSurface,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SelectionActionButton extends StatelessWidget {
  const _SelectionActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
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

  List<InlineSpan> inlineSpans(
    ColorScheme colors, {
    bool boldDivineName = false,
    bool underlineProperNames = true,
  }) {
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
            fontWeight: _spanFontWeight(
              span.kind,
              boldDivineName: boldDivineName,
            ),
            decoration: _spanDecoration(
              span.kind,
              underlineProperNames: underlineProperNames,
            ),
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
      case BibleVerseSpanKind.selah:
      case BibleVerseSpanKind.emphasis:
      case BibleVerseSpanKind.italic:
      case BibleVerseSpanKind.foreignLanguage:
        return FontStyle.italic;
      default:
        return FontStyle.normal;
    }
  }

  FontWeight _spanFontWeight(
    BibleVerseSpanKind kind, {
    bool boldDivineName = false,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.wordsOfJesus:
        return FontWeight.w600;
      case BibleVerseSpanKind.divineNameTag:
        return boldDivineName ? FontWeight.w700 : FontWeight.normal;
      case BibleVerseSpanKind.acrosticHeading:
      case BibleVerseSpanKind.bold:
      case BibleVerseSpanKind.keyword:
        return FontWeight.w700;
      case BibleVerseSpanKind.word:
        return FontWeight.w500;
      default:
        return FontWeight.normal;
    }
  }

  TextDecoration? _spanDecoration(
    BibleVerseSpanKind kind, {
    bool underlineProperNames = true,
  }) {
    switch (kind) {
      case BibleVerseSpanKind.word:
      case BibleVerseSpanKind.properName:
        return underlineProperNames ? TextDecoration.underline : null;
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

class _PersonalNotesSheet extends StatelessWidget {
  const _PersonalNotesSheet({
    required this.referenceLabel,
    required this.verseText,
    required this.books,
    required this.annotations,
    required this.onOpenReference,
    required this.onEdit,
  });

  final String referenceLabel;
  final String verseText;
  final List<BibleBook> books;
  final List<UserAnnotation> annotations;
  final ValueChanged<UserAnnotation> onOpenReference;
  final ValueChanged<UserAnnotation> onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.18,
        maxChildSize: 0.96,
        snap: true,
        snapSizes: const [0.5, 0.96],
        shouldCloseOnMinExtent: true,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: ListView(
              controller: controller,
              children: [
                Text(
                  referenceLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    verseText,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  annotations.length == 1
                      ? l10n.savedNoteLabel
                      : l10n.savedNotesLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final annotation in annotations) ...[
                  _PersonalNoteCard(
                    annotation: annotation,
                    books: books,
                    onOpenReference: () => onOpenReference(annotation),
                    onEdit: () => onEdit(annotation),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PersonalNoteCard extends StatelessWidget {
  const _PersonalNoteCard({
    required this.annotation,
    required this.books,
    required this.onOpenReference,
    required this.onEdit,
  });

  final UserAnnotation annotation;
  final List<BibleBook> books;
  final VoidCallback onOpenReference;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final highlightColor = annotation.highlightColorValue == null
        ? null
        : annotationColorFromValue(
            annotation.highlightColorValue,
            theme.colorScheme.secondary,
          );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  annotation.primaryVerse.translationName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (highlightColor != null)
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: highlightColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            annotation.noteText ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          if (annotation.linkedVerses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final link in annotation.linkedVerses)
                  Chip(
                    label: Text(
                      '${displayBookNameForReference(books, link.bookId)} '
                      '${link.chapter}:${link.verse}',
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onOpenReference,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.openAction),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editAction),
              ),
            ],
          ),
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
      BibleDocumentBlockKind.preface => theme.textTheme.bodyLarge,
      BibleDocumentBlockKind.introduction =>
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      BibleDocumentBlockKind.poetry => theme.textTheme.bodyLarge?.copyWith(
        fontStyle: FontStyle.italic,
      ),
      _ => theme.textTheme.bodyMedium,
    };

    final isIntro = block.kind == BibleDocumentBlockKind.introduction;
    return Padding(
      padding: EdgeInsets.only(
        bottom: block.kind == BibleDocumentBlockKind.heading ? 12 : 10,
        left: isIntro ? 12 : 0,
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

class _TableBlockSection extends StatelessWidget {
  const _TableBlockSection({required this.rows, required this.fontSize});

  final List<BibleDocumentBlock> rows;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Filter to only tableRow blocks (skip the table container block).
    final dataRows = rows
        .where((b) => b.kind == BibleDocumentBlockKind.tableRow)
        .toList();
    if (dataRows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < dataRows.length; i++)
            _buildRow(context, dataRows[i], i, colors),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    BibleDocumentBlock row,
    int index,
    ColorScheme colors,
  ) {
    final isHeader = row.metadata['role'] == 'label';
    final cellsRaw = row.metadata['cells'] ?? row.text;
    final cells = cellsRaw.split('\t');

    return Container(
      color: isHeader
          ? colors.surfaceContainerHighest.withValues(alpha: 0.6)
          : index.isOdd
          ? colors.surfaceContainerLow.withValues(alpha: 0.3)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          for (var c = 0; c < cells.length; c++) ...[
            if (c > 0) const SizedBox(width: 12),
            Expanded(
              child: Text(
                cells[c],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
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
    final colors = Theme.of(context).colorScheme;
    final shimmerBase = colors.surfaceContainerHigh;
    final shimmerHighlight = colors.surfaceContainerHighest;

    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: 12,
        itemBuilder: (context, index) => _SkeletonVerseRow(index: index),
      ),
    );
  }
}

class _SkeletonVerseRow extends StatelessWidget {
  const _SkeletonVerseRow({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    // Vary line counts so it looks organic, not mechanical
    final lineCount = 1 + (index % 3);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verse number badge placeholder
          Container(
            width: 22,
            height: 16,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Verse text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < lineCount; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      height: 14,
                      // Last line shorter to simulate natural text wrap
                      width: i == lineCount - 1
                          ? MediaQuery.of(context).size.width * 0.55
                          : double.infinity,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
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
