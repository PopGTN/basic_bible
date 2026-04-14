part of 'bible_viewer_tab.dart';

extension _BibleTextViewStateCore on _BibleTextViewState {
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
      } else if (_continuousItemScrollController.isAttached) {
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
        for (final book in widget.books)
          for (final chapter in book.chapters)
            for (final verse in chapter.verses)
              BibleReference(
                bookId: book.id,
                chapter: chapter.number,
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
    final noteAnnotations = _personalNoteAnnotations(verseAnnotations);
    if (noteAnnotations.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _PersonalNotesSheet(
          referenceLabel:
              '${displayBookNameForReference(widget.books, bookId)} '
              '$chapterNumber:${verse.number}',
          verseText: verse.text,
          books: widget.books,
          annotations: noteAnnotations,
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
                  fallbackTranslationId: ref.read(currentTranslationProvider),
                  fallbackTranslationName:
                      ref
                          .read(availableTranslationsProvider)
                          .asData
                          ?.value
                          .where(
                            (translation) =>
                                translation.id ==
                                ref.read(currentTranslationProvider),
                          )
                          .firstOrNull
                          ?.name ??
                      'Current translation',
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
          onEdit: (annotation) async {
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
            Navigator.of(sheetContext).pop();
            await Navigator.of(sheetContext).push(
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
