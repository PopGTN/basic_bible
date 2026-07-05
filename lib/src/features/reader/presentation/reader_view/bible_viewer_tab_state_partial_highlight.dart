part of 'bible_viewer_tab.dart';

// One verse's rendered character-offset range [start, end) within a
// document-mode section's shared RichText, recorded as the section's
// children are actually built (see _buildDocumentParagraphSection /
// _buildDocumentPoetrySection) so it can't drift out of sync with what's
// really on screen.
class _ParagraphVerseOffset {
  const _ParagraphVerseOffset({
    required this.verse,
    required this.start,
    required this.end,
  });

  final BibleVerse verse;
  final int start;
  final int end;
}

// Advanced Mode > Partial Highlights: renders a highlight over only the
// display spans a highlight annotation's range covers, instead of the whole
// verse. See AnnotationVerseLink's doc comment (user_annotations.dart) for
// why the range is anchored by span index *and* canonical text rather than
// character offsets.
extension _BibleTextViewStatePartialHighlight on _BibleTextViewState {
  // Cosmetic-transform-free text for a display span: no bracket-wrapping for
  // translator additions, no quote-level indentation, no inserted
  // leading space/newline. Stable regardless of display settings and
  // comparable across translations, unlike the rendered text `_spanText`
  // produces.
  String _canonicalSpanText(BibleVerseSpan span) => span.text.trim();

  String _canonicalSpanRangeText(
    List<BibleVerseSpan> displaySpans,
    int start,
    int end,
  ) {
    if (start < 0 || end >= displaySpans.length || start > end) return '';
    final buffer = StringBuffer();
    for (var i = start; i <= end; i++) {
      if (i > start) buffer.write(' ');
      buffer.write(_canonicalSpanText(displaySpans[i]));
    }
    return buffer.toString();
  }

  // Finds a contiguous run of spans in [displaySpans] whose canonical joined
  // text equals [anchorText]. Used to re-locate a partial highlight when the
  // verse's span list no longer matches at the stored indices (source data
  // changed since the highlight was made) or when rendering the annotation on
  // a different translation (Show Notes On Other Translations).
  List<int>? _findSpanRangeForAnchor(
    List<BibleVerseSpan> displaySpans,
    String anchorText,
  ) {
    if (anchorText.isEmpty) return null;
    for (var start = 0; start < displaySpans.length; start++) {
      final buffer = StringBuffer(_canonicalSpanText(displaySpans[start]));
      if (buffer.toString() == anchorText) return [start, start];
      for (var end = start + 1; end < displaySpans.length; end++) {
        buffer
          ..write(' ')
          ..write(_canonicalSpanText(displaySpans[end]));
        if (buffer.length > anchorText.length) break;
        if (buffer.toString() == anchorText) return [start, end];
      }
    }
    return null;
  }

  // Resolves [link]'s partial-highlight range against [displaySpans] — the
  // verse currently being rendered, which may be a different translation
  // than the one the highlight was created on. Returns null when the link is
  // a whole-verse highlight (unaffected, existing behavior) or when the
  // anchor text can't be found anywhere in this verse at all; callers should
  // treat a null result the same as a whole-verse highlight rather than
  // dropping the highlight entirely.
  List<int>? _resolveHighlightSpanRange(
    List<BibleVerseSpan> displaySpans,
    AnnotationVerseLink link,
  ) {
    if (!link.hasPartialHighlight) return null;
    final start = link.highlightSpanStart!;
    final end = link.highlightSpanEnd!;
    if (start >= 0 &&
        end < displaySpans.length &&
        start <= end &&
        _canonicalSpanRangeText(displaySpans, start, end) ==
            link.highlightAnchorText) {
      return [start, end];
    }
    return _findSpanRangeForAnchor(displaySpans, link.highlightAnchorText!);
  }

  // The verse-link (primary or linked) within [annotation] that corresponds
  // to this exact bookId/chapter/verse, regardless of which translation it
  // was recorded under — matches how cross-translation display already
  // resolves annotations elsewhere (annotationTranslationFilterProvider).
  AnnotationVerseLink? _verseLinkForReference(
    UserAnnotation annotation,
    BibleReference reference,
  ) {
    return annotation.allVerses
        .where(
          (link) => annotationVerseLinkMatchesReference(
            link,
            reference,
            translationId: null,
          ),
        )
        .firstOrNull;
  }

  /// Per-display-span-index highlight colors for [verse], derived from any
  /// partial-highlight annotations that touch it. Spans not present in the
  /// returned map have no partial highlight — callers should keep using the
  /// verse's whole-verse highlight color (if any) for those, unchanged.
  /// Empty when Partial Highlights is off or no annotation on this verse has
  /// a partial range, which keeps existing whole-verse-only rendering intact.
  Map<int, Color> _partialHighlightSpanColors(
    BuildContext context,
    List<UserAnnotation> verseAnnotations,
    List<BibleVerseSpan> displaySpans,
    String bookId,
    int chapterNumber,
    BibleVerse verse,
  ) {
    if (displaySpans.isEmpty) return const {};
    // Turning Advanced Mode off reverts previously-made partial highlights to
    // whole-verse display (the range is only hidden, not deleted) rather than
    // leaving experimental rendering active after the user opted back out.
    if (!ref.watch(partialHighlightingActiveProvider)) return const {};

    final reference = _verseReference(bookId, chapterNumber, verse);
    final fallback = Theme.of(context).colorScheme.secondary;

    final ranges = <List<int>>[];
    final layerColors = <Color>[];
    for (final annotation in verseAnnotations) {
      if (annotation.highlightColorValue == null) continue;
      final link = _verseLinkForReference(annotation, reference);
      if (link == null || !link.hasPartialHighlight) continue;
      final range = _resolveHighlightSpanRange(displaySpans, link);
      if (range == null) continue;
      ranges.add(range);
      layerColors.add(
        annotationColorFromValue(
          annotation.highlightColorValue,
          fallback,
        ).withValues(alpha: 0.24),
      );
    }

    // Live preview of the in-progress drag selection, if any, on top of any
    // already-saved highlights on this verse.
    final draft = ref.watch(partialHighlightDraftProvider);
    if (draft != null && draft.matchesVerse(bookId, chapterNumber, verse.number)) {
      ranges.add([draft.rangeStart, draft.rangeEnd]);
      layerColors.add(Theme.of(context).colorScheme.primary.withValues(alpha: 0.35));
    }

    if (ranges.isEmpty) return const {};

    // Multiple overlapping partial highlights blend the same way overlapping
    // whole-verse highlights already do in _highlightColorForVerse, rather
    // than letting one silently win.
    final result = <int, Color>{};
    for (var spanIndex = 0; spanIndex < displaySpans.length; spanIndex++) {
      Color? blended;
      for (var i = 0; i < ranges.length; i++) {
        if (spanIndex < ranges[i][0] || spanIndex > ranges[i][1]) continue;
        blended = blended == null
            ? layerColors[i]
            : Color.alphaBlend(layerColors[i], blended);
      }
      if (blended != null) result[spanIndex] = blended;
    }
    return result;
  }

  // ---------------------------------------------------------------------
  // Drag-to-select gesture (document mode only)
  //
  // A paragraph/poetry section's verses share one RichText, so hit-testing
  // needs to know which verse — and which display span within it — a given
  // point falls on. _paragraphSectionLedgers records each verse's rendered
  // character-offset range within that section's RichText, built alongside
  // the actual children (see bible_viewer_tab_state_document.dart) so it
  // can't drift out of sync with what's really on screen. Resolving a local
  // offset *within* one verse down to a span index is a much smaller, purely
  // per-verse computation — _spanIndexForLocalVerseOffset — since it only
  // has to mirror _buildVerseContentSpans's own loop over that one verse.
  // ---------------------------------------------------------------------

  GlobalKey _paragraphSectionKey(String sectionId) =>
      _paragraphSectionKeys.putIfAbsent(sectionId, GlobalKey.new);

  String _paragraphSectionId(
    String bookId,
    int chapterNumber,
    int firstVerseNumber,
  ) => '$bookId:$chapterNumber:$firstVerseNumber';

  int _inlineSpanListLength(List<InlineSpan> spans) {
    var length = 0;
    for (final span in spans) {
      length += span is TextSpan ? (span.text?.length ?? 0) : 1;
    }
    return length;
  }

  // Maps a character offset local to one verse's own rendered text (i.e.
  // already relative to that verse's ledger entry) to the display-span index
  // it falls in. Mirrors _buildVerseContentSpans's per-span loop for this one
  // verse only — each TextSpan contributes its text length, each inline
  // annotation-marker WidgetSpan contributes 1.
  int? _spanIndexForLocalVerseOffset(
    BuildContext context,
    BibleVerse verse,
    int localOffset,
  ) {
    final displaySpans = _displaySpans(verse);
    if (displaySpans.isEmpty || localOffset < 0) return null;
    final bracketTranslatorAdditions = ref.read(
      bracketTranslatorAdditionsProvider,
    );
    var cursor = 0;
    for (var i = 0; i < displaySpans.length; i++) {
      final span = displaySpans[i];
      final text = _spanText(
        span,
        bracketTranslatorAdditions: bracketTranslatorAdditions,
      );
      final start = cursor;
      final end = start + text.length;
      if (localOffset >= start && localOffset < end) return i;
      cursor = end + _buildInlineAnnotationMarkers(context, span).length;
    }
    // Past the last span's text (landed on trailing whitespace/markers) —
    // clamp to the last span rather than fail the gesture.
    return displaySpans.length - 1;
  }

  // Resolves a global drag position to (verse, display-span index), clamping
  // to the nearest verse in the ledger when the point falls in a decoration
  // gap (verse-number label, note/annotation buttons, spacing) rather than
  // failing the gesture — fingers are imprecise.
  ({BibleVerse verse, int spanIndex})? _resolvePartialHighlightHit(
    BuildContext context,
    String sectionId,
    Offset globalPosition,
  ) {
    final key = _paragraphSectionKeys[sectionId];
    final renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderParagraph) return null;
    final ledger = _paragraphSectionLedgers[sectionId];
    if (ledger == null || ledger.isEmpty) return null;

    final localPosition = renderObject.globalToLocal(globalPosition);
    final absoluteOffset = renderObject
        .getPositionForOffset(localPosition)
        .offset;

    var best = ledger.first;
    var bestDistance = _offsetDistance(best, absoluteOffset);
    for (final entry in ledger.skip(1)) {
      final distance = _offsetDistance(entry, absoluteOffset);
      if (distance < bestDistance) {
        best = entry;
        bestDistance = distance;
      }
    }

    final localVerseOffset = (absoluteOffset - best.start).clamp(
      0,
      best.end - best.start,
    );
    final spanIndex = _spanIndexForLocalVerseOffset(
      context,
      best.verse,
      localVerseOffset,
    );
    if (spanIndex == null) return null;
    return (verse: best.verse, spanIndex: spanIndex);
  }

  int _offsetDistance(_ParagraphVerseOffset entry, int offset) {
    if (offset < entry.start) return entry.start - offset;
    if (offset >= entry.end) return offset - entry.end + 1;
    return 0;
  }

  void _handlePartialHighlightLongPressStart(
    BuildContext context,
    String bookId,
    int chapterNumber,
    String sectionId,
    LongPressStartDetails details,
  ) {
    final hit = _resolvePartialHighlightHit(
      context,
      sectionId,
      details.globalPosition,
    );
    if (hit == null) return;
    final translationId = ref.read(currentTranslationProvider);
    final reference = _verseReference(bookId, chapterNumber, hit.verse);
    ref.read(selectedVersesProvider.notifier).setSingle(reference);
    ref.read(partialHighlightDraftProvider.notifier).state =
        PartialHighlightDraft(
          bookId: bookId,
          chapterNumber: chapterNumber,
          verseNumber: hit.verse.number,
          translationId: translationId,
          anchorSpanIndex: hit.spanIndex,
          currentSpanIndex: hit.spanIndex,
        );
  }

  void _handlePartialHighlightLongPressMoveUpdate(
    BuildContext context,
    String sectionId,
    LongPressMoveUpdateDetails details,
  ) {
    final draft = ref.read(partialHighlightDraftProvider);
    if (draft == null) return;
    final hit = _resolvePartialHighlightHit(
      context,
      sectionId,
      details.globalPosition,
    );
    if (hit == null) return;

    if (hit.verse.number == draft.verseNumber) {
      final displaySpans = _displaySpans(hit.verse);
      final clampedSpanIndex = hit.spanIndex.clamp(0, displaySpans.length - 1);
      ref.read(partialHighlightDraftProvider.notifier).state = draft.copyWith(
        currentSpanIndex: clampedSpanIndex,
      );
      return;
    }

    // v1 scope: dragging stays within the verse the gesture started on. If
    // the finger drifts into a neighboring verse, clamp to the nearest edge
    // of the origin verse (its first span if we drifted earlier, its last
    // span if later) instead of following across the boundary.
    final ledger = _paragraphSectionLedgers[sectionId];
    final originEntry = ledger
        ?.where((entry) => entry.verse.number == draft.verseNumber)
        .firstOrNull;
    if (originEntry == null) return;
    final originSpanCount = _displaySpans(originEntry.verse).length;
    if (originSpanCount == 0) return;
    final clampedSpanIndex = hit.verse.number < draft.verseNumber
        ? 0
        : originSpanCount - 1;
    ref.read(partialHighlightDraftProvider.notifier).state = draft.copyWith(
      currentSpanIndex: clampedSpanIndex,
    );
  }

  void _handlePartialHighlightLongPressEnd(
    BuildContext context,
    String sectionId,
  ) {
    final draft = ref.read(partialHighlightDraftProvider);
    if (draft == null) return;

    // Resolve the anchor text now, while this class still has the verse's
    // display spans at hand — bible_viewer_tab_state_selection.dart (a
    // different State class) can't call _displaySpans/_canonicalSpanRangeText
    // itself, so it reads the precomputed value off the draft instead.
    final entry = _paragraphSectionLedgers[sectionId]
        ?.where((candidate) => candidate.verse.number == draft.verseNumber)
        .firstOrNull;
    if (entry == null) {
      ref.read(partialHighlightDraftProvider.notifier).state = null;
      return;
    }
    final anchorText = _canonicalSpanRangeText(
      _displaySpans(entry.verse),
      draft.rangeStart,
      draft.rangeEnd,
    );
    if (anchorText.isEmpty) {
      ref.read(partialHighlightDraftProvider.notifier).state = null;
      return;
    }

    // Leave the draft + verse selection in place; opening the palette lets
    // the existing highlight-color flow (_handleHighlightColorSelected in
    // bible_viewer_tab_state_selection.dart) read the draft and save a
    // partial-range highlight instead of a whole-verse one.
    ref.read(partialHighlightDraftProvider.notifier).state = draft.copyWith(
      anchorText: anchorText,
    );
    ref.read(highlightPaletteExpandedProvider.notifier).state = true;
  }

  /// Wraps [child] (a section's RichText) with the long-press-drag gesture
  /// when Partial Highlights is active; returns [child] unchanged otherwise
  /// so verse-list/poetry rendering and existing per-span tap recognizers are
  /// completely unaffected when the feature is off.
  Widget _wrapWithPartialHighlightGesture({
    required BuildContext context,
    required String bookId,
    required int chapterNumber,
    required String sectionId,
    required Widget child,
  }) {
    if (!ref.watch(partialHighlightingActiveProvider)) return child;
    // Continuous mode can build the same chapter into two overlapping
    // viewports at once (see the GlobalKey comment on _verseKey), so the
    // section RichText doesn't get a stable GlobalKey there and hit-testing
    // has nothing to resolve against. Partial-highlight creation is
    // single-chapter-mode only for now; whole-verse tap-to-select is
    // completely unaffected either way.
    if (widget.continuousScrolling) return child;
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onLongPressStart: (details) => _handlePartialHighlightLongPressStart(
        context,
        bookId,
        chapterNumber,
        sectionId,
        details,
      ),
      onLongPressMoveUpdate: (details) =>
          _handlePartialHighlightLongPressMoveUpdate(
            context,
            sectionId,
            details,
          ),
      onLongPressEnd: (_) =>
          _handlePartialHighlightLongPressEnd(context, sectionId),
      onLongPressCancel: () =>
          ref.read(partialHighlightDraftProvider.notifier).state = null,
      child: child,
    );
  }
}
