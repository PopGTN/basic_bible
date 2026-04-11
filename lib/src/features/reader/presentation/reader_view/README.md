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

## Editing Rule

Do not grow `bible_viewer_tab.dart` with unrelated logic again.
If a change clearly belongs to one of the ownership areas above, place it there first.
