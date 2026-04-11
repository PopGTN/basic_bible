# Project State

## Repo
- Project: `basic_bible`
- Type: Flutter Bible reader app with parser-driven content rendering and personal annotations
- Local date of last update: 2026-04-11

## Current State
- The app supports reading in verse-list, document, and continuous-scrolling layouts.
- Personal annotations are implemented as user-created data separate from parser footnotes and cross-references.
- Notes can carry connected highlight colors and linked verses with saved translation metadata.
- The Notes screen is real and supports browsing, editing, and jumping back into the reader.

## Recent Structural Work
- Reader presentation is now organized into:
  - `lib/src/features/reader/presentation/reader_view/`
  - `lib/src/features/reader/presentation/reference_picker/`
- `reader_view/bible_viewer_tab.dart` was refactored into a coordinator plus focused part files:
  - `bible_viewer_tab_sections.dart`
  - `bible_viewer_tab_annotation_widgets.dart`
  - `bible_viewer_tab_document_widgets.dart`
  - `bible_viewer_tab_state_core.dart`
  - `bible_viewer_tab_state_rendering.dart`
  - `bible_viewer_tab_state_document.dart`
  - `bible_viewer_tab_state_annotations.dart`
- The references UI now lives under `reference_picker/` with:
  - `chapter_bar.dart`
  - `reference_picker_screen.dart`
  - `reference_screen.dart`
  - `reference_bar.dart` as a barrel export
- Local `README.md` files were added under the reader presentation folders to make file ownership easier to understand for future maintainers.
- The outer reader shell now uses named methods for chapter-bar actions and verse-selection actions, which makes `bible_viewer_tab.dart` much easier to re-enter after time away.
- The outer reader shell now also uses a small snapshot model for watched state, which reduces the amount of provider noise inside the main `build()` method.
- The reader rendering layer now uses shared helpers for verse cards and chapter support blocks instead of keeping duplicate current-chapter and continuous-chapter implementations.
- `flutter analyze` was clean after the refactor.

## Highest-Value Next Step
- Add widget tests for annotations in the reader and Notes flow, then run manual QA across verse-list, document, and continuous-scrolling layouts after the reader refactor.

## Important Open Risks
- Document-mode paragraph layout still has limitations around per-verse highlight backgrounds because prose verses are rendered inline in a shared `RichText` tree.
- Quick highlight still needs a follow-up to update an existing highlight instead of always inserting a duplicate highlight row for the same verse/translation.
- Migration coverage still needs an on-disk upgrade test for older databases.

## Follow-Up Todo
- After reader regression coverage is stronger, do a second architecture cleanup pass to move more responsibilities out of `_BibleTextViewState` into standalone widgets/controllers where that improves testability and ownership.
- Review the older `.claude/memory/*.md` files and keep them aligned with `CONTEXT.md`, `TODO_STATUS.md`, `ANNOTATIONS_CONTEXT.md`, and `ANNOTATIONS_STATUS.md`.

## Source Of Truth Files
- General app status: `TODO_STATUS.md`
- General engineering context: `CONTEXT.md`
- Annotation status: `ANNOTATIONS_STATUS.md`
- Annotation architecture context: `ANNOTATIONS_CONTEXT.md`
