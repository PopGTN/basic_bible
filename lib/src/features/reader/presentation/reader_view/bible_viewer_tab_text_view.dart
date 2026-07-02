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

  // Upper bound on chapters kept hydrated in memory. Big enough that the
  // prefetch window (±5) plus everything near the viewport always stays
  // cached, small enough that reading straight through the Bible doesn't
  // accumulate all 1,189 chapters.
  static const int _maxHydratedContinuousChapters = 48;

  void _storeHydratedContinuousChapter(String key, BibleChapter chapter) {
    if (!mounted) return;
    // Defer to the next frame. Chapter futures can complete while
    // ScrollablePositionedList is mid-layout; a synchronous setState at that
    // point mutates the render tree and triggers the assertion:
    // "RenderIndexedSemantics was mutated in RenderSliverList.performLayout".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        // Remove-then-insert keeps the map ordered least→most recently used
        // (Dart maps preserve insertion order).
        _hydratedContinuousChapters.remove(key);
        _hydratedContinuousChapters[key] = chapter;
        while (_hydratedContinuousChapters.length >
            _maxHydratedContinuousChapters) {
          final oldestKey = _hydratedContinuousChapters.keys.first;
          _hydratedContinuousChapters.remove(oldestKey);
          // The memoized future holds the same chapter data, so it must be
          // evicted too or the memory is never actually released.
          _continuousChapterFutures.remove(oldestKey);
        }
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
