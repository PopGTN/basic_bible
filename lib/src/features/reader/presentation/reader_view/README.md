# Reader View Module

This module owns the main reading screen.

## Entry Point

- `bible_viewer_tab.dart`
  - Coordinator for the reader shell and the `_BibleTextView` flow.

## Part File Ownership

- `bible_viewer_tab_sections.dart`
  - Shared local section models and support types.
- `bible_viewer_tab_shell_snapshot.dart`
  - Small snapshot model for the outer reader shell so `build()` can read more clearly.
- `bible_viewer_tab_annotation_widgets.dart`
  - Annotation-related widgets and bottom sheets used by the reader.
- `bible_viewer_tab_document_widgets.dart`
  - Document-mode-specific helper widgets.
- `bible_viewer_tab_state_core.dart`
  - Selection state, focus behavior, annotation lookup helpers.
- `bible_viewer_tab_state_rendering.dart`
  - Verse-list and continuous-layout rendering orchestration.
- `bible_viewer_tab_state_document.dart`
  - Document-mode paragraph and poetry rendering.
- `bible_viewer_tab_state_annotations.dart`
  - Parser-note sheets, span rendering helpers, inline annotation markers.

## Performance Rules

Rebuilding the reader re-renders every verse of every visible chapter (twice
over in split view, which runs two readers). Work that fires while reading
must not do it:

- A chapter finishing loading rebuilds only its own `FutureBuilder`
  (`ContinuousReaderController` does not notify the reader).
- The visible chapter lives in the `_visibleReference` notifier; only the
  chapter bar listens. Set it with `_setVisibleReference`.
- Per-frame scroll handling (`_syncVisibleChapterFromViewport`) does nothing
  unless a different chapter came into view.
- Chapters are preloaded ahead of the scroll direction, past the edge of the
  screen being scrolled towards (`_prefetchAheadOfScroll`), not around the top
  chapter.
- Don't read animated values in the reader's `build`. The bottom safe area
  animates while the bars hide (`CollapsingBottomBarInset`); the reader lets a
  `SafeArea` absorb it. Reading `MediaQuery.paddingOf` (or `MediaQuery.of`)
  there rebuilt every verse on every frame of that animation. Use the narrow
  accessors (`MediaQuery.sizeOf`, `paddingOf`) in small widgets, never the
  full `MediaQuery.of(context)`.

Details: `docs/READER_STATE_MEMORY.md`, "Rebuild rules".

## Editing Rule

Do not grow `bible_viewer_tab.dart` with unrelated logic again.
If a change clearly belongs to one of the ownership areas above, place it there first.
