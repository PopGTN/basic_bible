# Reader Presentation

This folder holds the user-facing reader UI.

## Folder Map

- `reader_view/`
  - Main Bible-reading experience.
  - Owns verse list, document mode, continuous scrolling, selection UI, note/highlight entry points, and reader-specific sheets.
- `reference_picker/`
  - Reference-picking and reference-navigation UI.
  - Used by the reader and by note editing when the app needs to return a chosen verse reference.

## Working Rule

If a change is mainly about how Bible text is displayed or interacted with while reading, start in `reader_view/`.

If a change is mainly about choosing, browsing, or opening references, start in `reference_picker/`.
