# Personal Annotations Status

## Current Status

- `in_progress` Reader-side manual QA is still needed across verse-list, document, and continuous-scrolling layouts.
- `in_progress` Widget-test coverage for the new annotation UI is still missing.
- `in_progress` Annotation behavior should be regression-checked after the reader presentation reorganization into `reader_view/` and `reference_picker/`.
- `in_progress` Document mode paragraph layout (prose) does not show per-verse highlight color backgrounds. This is a structural limitation of inline `RichText` — verses share a single `TextSpan` tree with no containing widget per verse. Highlight background in document mode only works in the poetry section (which wraps each verse in a `Container`). A future fix would require splitting paragraph verses into individual row widgets.
- `todo` Document mode selection bar has been confirmed wired (`_InlineVerseSelector.onTap` → `_selectVerse` → `selectedVerseProvider`). Needs a full manual QA pass: verify the action bar appears when tapping verse numbers in both paragraph and poetry document layouts, and that highlight/note/copy all work from there.
- `done` Added a dedicated personal-annotation domain separate from parser footnotes/cross-references.
- `done` Added persistent Drift storage for saved notes, highlights, and linked verses with translation metadata.
- `done` Added verse selection in the reader with a bottom action bar for highlight, note, copy, and share fallback.
- `done` Added a note editor that supports connected highlight color, linked verses, and labels.
- `done` Added a real `Notes` screen and replaced the Menu placeholder route.

## Recommended Next Step

- `next` Add widget tests for reader verse selection, saved-note markers, and Notes-screen open-in-reader navigation, then run a manual regression pass across document mode and continuous scrolling.

## Completed Recently

- `done` Split and organized the reader presentation code under `reader_view/` so the annotation flow no longer lives inside one 2500+ line reader file.
- `done` Organized the references UI under `reference_picker/`, keeping the add-verse picker flow easier to reason about.
- `done` Added `user_annotations` and `annotation_verses` tables with additive migration step `v6`.
- `done` Added `UserAnnotation`, `AnnotationVerseLink`, and editor-draft models for personal note/highlight data.
- `done` Added repository and Riverpod providers for annotation CRUD, current selection, chapter filtering, and note-editor draft state.
- `done` Added connected note highlight support so notes can optionally preserve a highlight color.
- `done` Added reader-side saved-note markers and whole-verse highlight tinting for row-based verse rendering.
- `done` Added repository tests for save/load/edit/delete annotation flows and linked-verse translation metadata.
- `done` Removed the fake profile header from the Menu and routed Notes to a real screen.

## Open Follow-Ups

- `todo` Replace share fallback with native platform share.
- `todo` Add export support for `docx` and `csv`.
- `todo` Design a free sync abstraction before attempting Google Docs or other providers.
- `todo` Add migration tests that open a pre-v6 database file and verify upgrade safety.
- `todo` Add per-verse `CASCADE` delete on the `AnnotationVerses.annotationId` foreign key (requires schema v7 migration and `PRAGMA foreign_keys = ON` in Drift's `beforeOpen`). Current code handles it correctly via manual two-step delete, but the schema itself offers no protection.
- `todo` Quick-highlight from the reader always inserts a new annotation row even when a highlight already exists for that verse/translation. The `existingAnnotations` list is already passed to `_VerseSelectionBar` but is not yet consulted in the save path. Fix: look up an existing highlight annotation by id and update it instead of inserting. Notes and highlights are already allowed to coexist as separate saved items on the same verse; this follow-up is only about avoiding duplicate highlight rows.
- `todo` Document mode paragraph layout (prose) is missing per-verse highlight color backgrounds. Requires splitting paragraph verses into individual row widgets rather than inline `TextSpan` children.
