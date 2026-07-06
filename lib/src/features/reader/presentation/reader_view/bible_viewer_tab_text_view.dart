part of 'bible_viewer_tab.dart';

/// Bible text display widget — renders a single chapter or the full continuous
/// scroll stream depending on [continuousScrolling].
///
/// [_BibleTextViewState] extension methods are split across:
///   - bible_viewer_tab_state_core.dart        (selection, focus, lookup helpers)
///   - bible_viewer_tab_state_rendering.dart    (verse-list + continuous view)
///   - bible_viewer_tab_state_document.dart     (document-mode rendering)
///   - bible_viewer_tab_state_annotations.dart  (parser-note sheets + spans)
///
/// Note: bible_viewer_tab_state_selection.dart extends [_BibleViewerTabState]
/// (the outer shell), not this widget — it owns the copy/share/highlight/note
/// action handlers that run from the selection tray.
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
  // Owns the continuous-mode section list, chapter hydration futures, LRU
  // cache, and prefetch policy. Kept out of the widget State so the logic is
  // unit-testable (see continuous_reader_controller.dart).
  late final ContinuousReaderController _continuousController;
  List<ContinuousChapterSection> get _continuousSections =>
      _continuousController.sections;
  BibleReference? _selectionAnchorReference;
  bool _showSelectedVerseFocus = true;
  bool _visibleSyncQueued = false;
  // True while an animated programmatic scroll (chapter navigation) is
  // running. Scroll notifications are not forwarded to the bar auto-hide
  // handler during that window, so tapping next/previous chapter doesn't
  // hide the top bar as if the user had scrolled down.
  bool _suppressChromeScrollEvents = false;
  // Key for the ScrollablePositionedList widget. Assigning a new UniqueKey()
  // forces a full SPL rebuild, which lets us position at initialScrollIndex
  // exactly — bypassing the position estimation that accumulates error over
  // hundreds of unhydrated chapters on large jumps.
  Key _scrollableListKey = const ValueKey('continuous_list');
  int _scrollableListInitialIndex = 0;
  // The one continuous section (chapter) currently allowed to attach real
  // verse GlobalKeys, or null if none. SPL briefly renders whichever section
  // is the target of scrollTo()/initialScrollIndex in two internal viewports
  // to resolve its position — a GlobalKey present in both at once crashes
  // with "Multiple widgets used the same GlobalKey" (see _verseKeySuppressed
  // in bible_viewer_tab_state_core.dart). Verse keys for a section are only
  // enabled once that positioning has fully settled, so precise verse-level
  // scrolling works in continuous mode without hitting that crash.
  int? _armedVerseSectionIndex;

  void _onContinuousControllerChanged() {
    // Safe to setState directly: the controller defers notifications to the
    // next frame, so this never fires while SPL is mid-layout.
    if (mounted) setState(() {});
  }

  void _onContinuousChapterHydrated(String bookId, int chapterNumber) {
    if (!mounted) return;
    // Retry verse focus for deep links that landed before the target chapter
    // was hydrated: the initial _scheduleVerseFocus fires before verse
    // widgets exist, so the scroll silently does nothing until now.
    if (bookId == widget.reference.bookId &&
        chapterNumber == widget.reference.chapter &&
        widget.reference.verse != null) {
      final index = _continuousSectionIndexFor(widget.reference);
      if (index != null) _armVerseSectionAfterSettle(index);
    }
  }

  @override
  void initState() {
    super.initState();
    _continuousController = ContinuousReaderController(
      loadChapter: (bookId, chapterNumber) => ref
          .read(bibleRepositoryProvider)
          .loadChapterVerses(widget.translationId, bookId, chapterNumber),
    )
      ..onChapterHydrated = _onContinuousChapterHydrated
      ..addListener(_onContinuousControllerChanged);
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
    if (widget.continuousScrolling && widget.reference.verse != null) {
      _armVerseSectionAfterSettle(_scrollableListInitialIndex);
    }
  }

  @override
  void didUpdateWidget(covariant _BibleTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.translationId != widget.translationId ||
        oldWidget.books != widget.books) {
      _continuousController.reset();
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

  void _setArmedVerseSectionIndex(int? value) {
    if (!mounted || _armedVerseSectionIndex == value) return;
    setState(() {
      _armedVerseSectionIndex = value;
    });
  }

  @override
  void dispose() {
    _continuousController
      ..removeListener(_onContinuousControllerChanged)
      ..dispose();
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
            ? NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  // Forward to the shell so the top bar and tab bar auto-hide
                  // on scroll here too — previously only single-chapter mode
                  // forwarded these, so continuous mode never hid the bars.
                  if (!_suppressChromeScrollEvents) {
                    widget.onScrollNotification(notification);
                  }
                  if (notification is ScrollUpdateNotification) {
                    _queueVisibleChapterSync(context);
                  }
                  return false;
                },
                child: _buildContinuousReadingView(context),
              )
            : _buildSingleChapterView(context),
      ),
    );
  }
}
