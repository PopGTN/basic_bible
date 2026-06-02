part of 'bible_viewer_tab.dart';

// Maximum verses that can be linked to a single note from the selection tray.
const _maxVersesPerNoteSelection = 250;

extension _BibleViewerTabStateSelection on _BibleViewerTabState {
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
