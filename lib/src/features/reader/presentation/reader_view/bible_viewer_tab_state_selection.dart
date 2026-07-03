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

  // Shared preamble for _handleHighlightColorSelected and
  // _handleClearHighlightPressed: resolves the translation, gathers overlapping
  // standalone-highlight annotations, then delegates to [body].
  // The in-flight flag is managed here so callers do not need to touch it.
  Future<void> _executeHighlightAction(
    Future<void> Function(
      List<BibleReference> references,
      BibleTranslation translation,
      List<UserAnnotation> highlightAnnotations,
      UserAnnotationRepository repository,
      ScaffoldMessengerState messenger,
    ) body,
  ) async {
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

      await body(
        selectedReferences,
        translation,
        highlightAnnotations,
        ref.read(userAnnotationRepositoryProvider),
        messenger,
      );
    } finally {
      _setSelectionActionInFlight(false);
    }
  }

  // Trims [selectedReferences] from [annotation] and writes the result.
  // If the trimmed result is null the annotation is fully covered and is deleted.
  Future<void> _trimOrDeleteAnnotation(
    UserAnnotation annotation,
    List<BibleReference> selectedReferences,
    String translationId,
    UserAnnotationRepository repository,
  ) async {
    final trimmed = removeReferencesFromStandaloneHighlight(
      annotation,
      selectedReferences,
      translationId: translationId,
    );
    if (trimmed == null) {
      final id = annotation.id;
      if (id != null) await repository.deleteAnnotation(id);
    } else {
      await repository.saveAnnotation(trimmed);
    }
  }

  Future<void> _handleHighlightColorSelected(Color color) =>
      _executeHighlightAction(
        (references, translation, highlightAnnotations, repository, messenger) async {
      // Remove the selected verses from every overlapping annotation.
      // _standaloneHighlightAnnotationsForSelection already deduplicates by id,
      // but processedIds guards against any future path that could produce
      // duplicates without risking a double-delete.
      // This also handles the "recolour a subset" case: an annotation covering
      // verses 1–5 is trimmed to 1–2, 4–5 before the new per-verse annotation
      // is created for verse 3, preserving the original colour on the remainder.
      final processedIds = <int?>{};
      final trimFutures = <Future<void>>[];
      for (final annotation in highlightAnnotations) {
        if (!processedIds.add(annotation.id)) continue;
        trimFutures.add(
          _trimOrDeleteAnnotation(annotation, references, translation.id, repository),
        );
      }
      await Future.wait(trimFutures);

      // Create one fresh per-verse annotation with the chosen colour.
      // We never update an existing multi-verse annotation in-place because
      // that would silently recolour unselected verses too.
      await Future.wait([
        for (final reference in references)
          repository.saveAnnotation(
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
          ),
      ]);

      if (!mounted) return;
      _clearSelectionUi();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            references.length == 1
                ? 'Highlight saved.'
                : 'Highlights saved for ${references.length} verses.',
          ),
        ),
      );
    });

  Future<void> _handleClearHighlightPressed() =>
      _executeHighlightAction(
        (references, translation, highlightAnnotations, repository, messenger) async {
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

      await Future.wait([
        for (final annotation in highlightAnnotations)
          _trimOrDeleteAnnotation(annotation, references, translation.id, repository),
      ]);

      if (!mounted) return;
      _clearSelectionUi();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            highlightAnnotations.length == 1
                ? 'Highlight removed.'
                : 'Highlights removed.',
          ),
        ),
      );
    });

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
          _clearSelectionUi();
        });
      }
    } finally {
      // Defer the in-flight reset to the next frame so the busy state persists
      // through the route-push animation. Clearing it synchronously (like the
      // highlight handlers do) would cause the tray to briefly re-enable
      // mid-transition, producing a visible flicker. Any new action that pushes
      // a route should use the same deferred pattern here.
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
