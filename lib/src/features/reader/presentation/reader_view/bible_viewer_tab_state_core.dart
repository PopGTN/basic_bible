part of 'bible_viewer_tab.dart';

extension _BibleTextViewStateCore on _BibleTextViewState {
  String _continuousChapterKey(String bookId, int chapterNumber) =>
      '$bookId:$chapterNumber';

  void _exitSelectionMode() {
    _selectionAnchorReference = null;
    ref.read(selectedVersesProvider.notifier).clear();
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  void _rebuildContinuousSections() {
    // Continuous mode renders a flat chapter stream so the viewport can reason
    // about "which chapter is visible now?" without walking the nested book
    // structure every time.
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
      final targetIndex = _continuousSectionIndexFor(widget.reference);
      if (targetIndex == null) return;

      // Determine how far the jump is from the current visible position.
      // ScrollablePositionedList estimates scroll offsets for unhydrated items
      // using placeholder heights. Over large distances (hundreds of chapters)
      // that estimation error compounds and scrollTo() can land far off target.
      // For jumps > 20 chapters we reset the SPL widget with a new key and
      // initialScrollIndex so it renders at the exact target position immediately.
      // _hydratedContinuousChapters is preserved — already-loaded chapters
      // stay in cache.
      final positions = _continuousItemPositionsListener.itemPositions.value;
      final currentIndex = positions.isEmpty
          ? _scrollableListInitialIndex
          : positions.reduce(
              (current, candidate) =>
                  current.itemLeadingEdge <= candidate.itemLeadingEdge
                  ? current
                  : candidate,
            ).index;
      final jumpDistance = (targetIndex - currentIndex).abs();

      if (jumpDistance > 20) {
        // Reset: rebuild the SPL widget at the target chapter.
        _resetScrollableListAt(targetIndex);
        // Prefetch again from the new center so surrounding chapters load.
        _prefetchContinuousChapterWindow(widget.reference, radius: 5);
        // The key reset repositions the list immediately but fires no
        // ScrollUpdateNotification, so _syncVisibleChapterFromViewport won't
        // update the chapter bar until the user scrolls. Notify directly.
        final targetSection = _continuousSections[targetIndex];
        widget.onVisibleReferenceChanged(
          BibleReference(
            bookId: targetSection.book.id,
            chapter: targetSection.chapter.number,
          ),
        );
      } else if (_continuousItemScrollController.isAttached) {
        // Short hop: animated scroll is accurate enough.
        _continuousItemScrollController.scrollTo(
          index: targetIndex,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.02,
        );
      }
    });
  }

  int? _continuousSectionIndexFor(BibleReference reference) {
    final index = _continuousSections.indexWhere(
      (section) =>
          section.book.id == reference.bookId &&
          section.chapter.number == reference.chapter,
    );
    return index >= 0 ? index : null;
  }

  BibleChapter? _hydratedContinuousChapter(String bookId, int chapterNumber) {
    final key = _continuousChapterKey(bookId, chapterNumber);
    final chapter = _hydratedContinuousChapters.remove(key);
    if (chapter == null) return null;
    // Re-insert so chapters still being rendered count as recently used and
    // aren't evicted while visible.
    _hydratedContinuousChapters[key] = chapter;
    return chapter;
  }

  Future<BibleChapter?> _continuousChapterFuture(
    _ContinuousChapterSection section,
  ) {
    final key = _continuousChapterKey(section.book.id, section.chapter.number);
    return _continuousChapterFutures.putIfAbsent(key, () async {
      final repository = ref.read(bibleRepositoryProvider);
      final hydrated = await repository.loadChapterVerses(
        widget.translationId,
        section.book.id,
        section.chapter.number,
      );
      final resolved = hydrated ?? section.chapter;
      if (resolved.verses.isNotEmpty) {
        _storeHydratedContinuousChapter(key, resolved);
        // If this is the chapter the reader is currently pointing at and a
        // specific verse was requested, retry verse focus now that real verse
        // widgets are about to be built. The initial _scheduleVerseFocus in
        // initState/didUpdateWidget fires before hydration completes, so verse
        // keys don't exist yet and the scroll silently does nothing.
        if (section.book.id == widget.reference.bookId &&
            section.chapter.number == widget.reference.chapter &&
            widget.reference.verse != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scheduleVerseFocus();
          });
        }
      }
      return resolved;
    });
  }

  void _prefetchContinuousChapterWindow(
    BibleReference reference, {
    int radius = 2,
  }) {
    if (!widget.continuousScrolling || _continuousSections.isEmpty) return;
    final centerIndex = _continuousSectionIndexFor(reference);
    if (centerIndex == null) return;
    final start = (centerIndex - radius).clamp(0, _continuousSections.length - 1);
    final end = (centerIndex + radius).clamp(0, _continuousSections.length - 1);
    for (var index = start; index <= end; index++) {
      _continuousChapterFuture(_continuousSections[index]);
    }
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
    // RichText spans cannot use the simpler InkWell path. We cache recognizers
    // per verse key so document-mode taps do not recreate gesture recognizers
    // on every build.
    recognizer.onTap = () => _handleVerseTap(bookId, chapterNumber, verse);
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
    // In continuous mode, currentReferenceProvider reflects the chapter that
    // was navigated to, not the chapter currently scrolled into view.
    // visibleChapterAnnotationsProvider therefore hides annotations on every
    // chapter except the original navigation target, so we fall back to the
    // full annotation stream and let touchesReference do the filtering.
    final annotations = widget.continuousScrolling
        ? ref.watch(userAnnotationsProvider).value ?? const []
        : ref.watch(visibleChapterAnnotationsProvider);
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

  bool _hasSavedAnnotations(List<UserAnnotation> verseAnnotations) {
    // Only show the note button when the verse has an annotation with actual
    // written text. Standalone highlights are already visible via the verse
    // background color — showing the note icon for them confuses users into
    // thinking their note was deleted when only the highlight was cleared.
    return verseAnnotations.any((annotation) => annotation.hasNoteText);
  }

  List<UserAnnotation> _savedVerseAnnotations(
    List<UserAnnotation> verseAnnotations,
  ) {
    final annotations = [...verseAnnotations];
    annotations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return annotations;
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

    // Multiple highlights on the same verse intentionally blend instead of
    // letting one silently win. That preserves the user's saved data even if
    // the UI later evolves to offer merge/edit tools.
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
    final hydrated = _hydratedContinuousChapter(bookId, chapterNumber);
    if (hydrated != null) return hydrated;
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
    final annotations = widget.continuousScrolling
        ? ref.watch(userAnnotationsProvider).value ?? const []
        : ref.watch(visibleChapterAnnotationsProvider);
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

  void _handleVerseTap(String bookId, int chapterNumber, BibleVerse verse) {
    if (_isRangeSelectionGesture) {
      final selectedVerses = ref.read(selectedVersesProvider);
      if (selectedVerses.isNotEmpty && _selectionAnchorReference != null) {
        _selectVerseRangeTo(_verseReference(bookId, chapterNumber, verse));
        return;
      }
    }

    _selectVerse(bookId, chapterNumber, verse);
  }

  bool get _isRangeSelectionGesture =>
      (isWebRuntime || isDesktopRuntime) &&
      HardwareKeyboard.instance.isShiftPressed;

  List<BibleReference> _orderedSelectableReferences() {
    if (widget.continuousScrolling) {
      return [
        for (final section in _continuousSections)
          for (final verse
              in _hydratedContinuousChapter(
                    section.book.id,
                    section.chapter.number,
                  )?.verses ??
                  const <BibleVerse>[])
              BibleReference(
                bookId: section.book.id,
                chapter: section.chapter.number,
                verse: verse.number,
              ),
      ];
    }

    return [
      for (final verse in widget.chapter.verses)
        BibleReference(
          bookId: widget.book.id,
          chapter: widget.chapter.number,
          verse: verse.number,
        ),
    ];
  }

  String _referenceSelectionKey(BibleReference reference) {
    return '${reference.bookId}:${reference.chapter}:${reference.verse ?? 0}';
  }

  void _selectVerseRangeTo(BibleReference targetReference) {
    final anchor = _selectionAnchorReference;
    if (anchor == null) {
      ref.read(selectedVersesProvider.notifier).setSingle(targetReference);
      _selectionAnchorReference = targetReference;
      ref.read(highlightPaletteExpandedProvider.notifier).state = false;
      return;
    }

    final orderedReferences = _orderedSelectableReferences();
    final anchorIndex = orderedReferences.indexWhere(
      (reference) =>
          _referenceSelectionKey(reference) == _referenceSelectionKey(anchor),
    );
    final targetIndex = orderedReferences.indexWhere(
      (reference) =>
          _referenceSelectionKey(reference) ==
          _referenceSelectionKey(targetReference),
    );

    if (anchorIndex < 0 || targetIndex < 0) {
      ref.read(selectedVersesProvider.notifier).toggle(targetReference);
      _selectionAnchorReference = targetReference;
      ref.read(highlightPaletteExpandedProvider.notifier).state = false;
      return;
    }

    final start = anchorIndex < targetIndex ? anchorIndex : targetIndex;
    final end = anchorIndex > targetIndex ? anchorIndex : targetIndex;
    final range = orderedReferences.sublist(start, end + 1);
    ref.read(selectedVersesProvider.notifier).replaceAll(range);
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  void _selectVerse(String bookId, int chapterNumber, BibleVerse verse) {
    final reference = _verseReference(bookId, chapterNumber, verse);
    final notifier = ref.read(selectedVersesProvider.notifier);
    notifier.toggle(reference);
    final selectedVerses = ref.read(selectedVersesProvider);
    if (selectedVerses.isEmpty) {
      _exitSelectionMode();
      return;
    }

    _selectionAnchorReference = reference;
    ref.read(highlightPaletteExpandedProvider.notifier).state = false;
  }

  Future<void> _showPersonalNotesSheet(
    BuildContext context, {
    required String bookId,
    required int chapterNumber,
    required BibleVerse verse,
    required List<UserAnnotation> verseAnnotations,
  }) async {
    final reference = _verseReference(bookId, chapterNumber, verse);
    final translationId = ref.read(currentTranslationProvider);
    final fallbackTranslationName = ref
            .read(availableTranslationsProvider)
            .asData
            ?.value
            .where((t) => t.id == translationId)
            .firstOrNull
            ?.name ??
        'Current translation';
    final initialAnnotations = _savedVerseAnnotations(verseAnnotations);
    if (initialAnnotations.isEmpty) return;

    Future<List<UserAnnotation>> reloadVerseAnnotations() async {
      final annotations = await ref
          .read(userAnnotationRepositoryProvider)
          .getAnnotations();
      final filtered = annotations
          .where(
            (annotation) => annotation.touchesReference(
              reference,
              translationId: translationId,
            ),
          )
          .toList();
      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return filtered;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final annotationsNotifier = ValueNotifier<List<UserAnnotation>>(
          initialAnnotations,
        );
        Future<void> refreshSheetAnnotations() async {
          final latest = await reloadVerseAnnotations();
          annotationsNotifier.value = latest;
          if (latest.isEmpty && sheetContext.mounted) {
            Navigator.of(sheetContext).pop();
          }
        }

        return ValueListenableBuilder<List<UserAnnotation>>(
          valueListenable: annotationsNotifier,
          builder: (context, annotations, _) {
            return _PersonalNotesSheet(
              referenceLabel:
                  '${displayBookNameForReference(widget.books, bookId)} '
                  '$chapterNumber:${verse.number}',
              verseText: verse.text,
              books: widget.books,
              annotations: annotations,
              onCreate: () async {
                final translation = await resolveCurrentTranslation(ref);
                if (translation == null || !sheetContext.mounted) return;
                await Navigator.of(sheetContext).push(
                  MaterialPageRoute(
                    builder: (context) => NoteEditorScreen(
                      primaryVerse: buildAnnotationVerseLink(
                        reference: reference,
                        translation: translation,
                      ),
                    ),
                  ),
                );
                await refreshSheetAnnotations();
              },
              onPreviewLinkedVerse: (link) {
                return showModalBottomSheet<void>(
                  context: sheetContext,
                  isScrollControlled: true,
                  showDragHandle: true,
                  builder: (previewContext) {
                    return ReferencePreviewSheet(
                      referenceLabel:
                          '${displayBookNameForReference(widget.books, link.bookId)} '
                          '${link.chapter}:${link.verse}',
                      reference: link.reference,
                      preferredTranslationId: link.translationId,
                      preferredTranslationName: link.translationName,
                      fallbackTranslationId: translationId,
                      fallbackTranslationName: fallbackTranslationName,
                      books: widget.books,
                      returnLabel: 'Back to Note',
                      onOpenInBible: (previewSheetContext, preview) async {
                        await ref
                            .read(currentTranslationProvider.notifier)
                            .setTranslation(preview.translationId);
                        await ref
                            .read(currentReferenceProvider.notifier)
                            .setReference(preview.reference);
                        if (previewSheetContext.mounted) {
                          Navigator.of(previewSheetContext).pop();
                        }
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    );
                  },
                );
              },
              onOpenReference: (annotation) async {
                if (!sheetContext.mounted) return;
                final translationId = annotation.primaryVerse.translationId;
                final available = await ref.read(
                  availableTranslationsProvider.future,
                );
                if (!sheetContext.mounted) return;
                final exists = available.any((t) => t.id == translationId);
                if (exists) {
                  await ref
                      .read(currentTranslationProvider.notifier)
                      .setTranslation(translationId);
                }
                if (!sheetContext.mounted) return;
                await ref
                    .read(currentReferenceProvider.notifier)
                    .setReference(annotation.primaryVerse.reference);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              onViewDetails: (annotation) async {
                if (!sheetContext.mounted) return;
                await Navigator.of(sheetContext).push(
                  MaterialPageRoute(
                    builder: (context) => AnnotationDetailScreen(
                      annotation: annotation,
                      books: widget.books,
                      onPreviewLinkedVerse: (link) => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (previewContext) => ReferencePreviewSheet(
                          referenceLabel:
                              '${displayBookNameForReference(widget.books, link.bookId)} '
                              '${link.chapter}:${link.verse}',
                          reference: link.reference,
                          preferredTranslationId: link.translationId,
                          preferredTranslationName: link.translationName,
                          fallbackTranslationId: translationId,
                          fallbackTranslationName: fallbackTranslationName,
                          books: widget.books,
                          returnLabel: 'Back to Note',
                          onOpenInBible: (previewSheetContext, preview) async {
                            await ref
                                .read(currentTranslationProvider.notifier)
                                .setTranslation(preview.translationId);
                            await ref
                                .read(currentReferenceProvider.notifier)
                                .setReference(preview.reference);
                            if (previewSheetContext.mounted) {
                              Navigator.of(previewSheetContext).pop();
                            }
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        ),
                      ),
                      onOpenReference: () async {
                        await ref
                            .read(currentReferenceProvider.notifier)
                            .setReference(annotation.primaryVerse.reference);
                        if (context.mounted) Navigator.of(context).pop();
                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                      },
                      onEdit: () async {
                        if (context.mounted) Navigator.of(context).pop();
                        await Navigator.of(sheetContext).push(
                          MaterialPageRoute(
                            builder: (context) => NoteEditorScreen(
                              primaryVerse: annotation.primaryVerse,
                              existingAnnotation: annotation,
                            ),
                          ),
                        );
                        await refreshSheetAnnotations();
                      },
                      onDelete: () async {
                        final id = annotation.id;
                        if (id == null || !context.mounted) return;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete?'),
                            content: const Text(
                              'This note or highlight will be permanently removed.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed != true) return;
                        await ref
                            .read(userAnnotationRepositoryProvider)
                            .deleteAnnotation(id);
                        if (context.mounted) Navigator.of(context).pop();
                        await refreshSheetAnnotations();
                      },
                    ),
                  ),
                );
              },
              onEdit: (annotation) async {
                if (!sheetContext.mounted) return;
                await Navigator.of(sheetContext).push(
                  MaterialPageRoute(
                    builder: (context) => NoteEditorScreen(
                      primaryVerse: annotation.primaryVerse,
                      existingAnnotation: annotation,
                    ),
                  ),
                );
                await refreshSheetAnnotations();
              },
              onDelete: (annotation) async {
                final id = annotation.id;
                if (id == null || !sheetContext.mounted) return;
                final confirmed = await showDialog<bool>(
                  context: sheetContext,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete?'),
                    content: const Text(
                      'This note or highlight will be permanently removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true) return;
                await ref
                    .read(userAnnotationRepositoryProvider)
                    .deleteAnnotation(id);
                await refreshSheetAnnotations();
              },
            );
          },
        );
      },
    );
  }

  void _dismissSelectedVerseFocus() {
    if (!_hasActiveVerseFocus) return;
    _setSelectedVerseFocusVisible(false);
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
}
