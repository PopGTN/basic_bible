---
name: Project Structure
description: Permanent MVVM-style structure guide for basic_bible
type: project
---

# How This Project Is Structured

`basic_bible` uses a pragmatic MVVM-style feature layout on top of Riverpod.
It is not a strict framework rewrite. The goal is readability, testability, and safer ownership boundaries.

## Core rule

For each feature, prefer this shape:

- `models/`
  - domain objects and draft/edit models
- `data/`
  - repositories, persistence, integration boundaries
- `application/view_models/`
  - Riverpod providers, state notifiers, UI-facing orchestration
- `presentation/`
  - screens, widgets, sheets, dialogs, rendering logic

## What counts as a ViewModel here

In this repo, a "ViewModel" is usually one of:

- a `StateNotifier`
- a Riverpod `Provider` that derives UI-facing state
- a `FutureProvider` or `StreamProvider` that feeds a screen

If the logic exists to help a screen load, react, select, filter, or navigate, it belongs in `application/view_models/`.

## Current feature map

- `features/auth`
  - ViewModel: `application/view_models/auth_view_model.dart`
  - View: `presentation/login_screen.dart`
- `features/home`
  - ViewModel: `application/view_models/home_navigation_view_model.dart`
  - View: `presentation/home_screen.dart`
- `features/settings`
  - ViewModels:
    - `app_launch_preferences_view_models.dart`
    - `reader_display_preferences_view_models.dart`
  - Views:
    - `settings_screen.dart`
    - `advanced_settings_screen.dart`
- `features/annotations`
  - Model: `models/user_annotations.dart`
  - Data: `data/user_annotation_repository.dart`
  - ViewModels:
    - `annotation_data_view_models.dart`
    - `annotation_selection_view_models.dart`
  - Views:
    - `notes_screen.dart`
    - `note_editor_screen.dart`
- `features/reader`
  - ViewModels:
    - `reader_session_view_models.dart`
    - `reader_preferences_view_models.dart`
    - `bible_library_view_models.dart`
    - `current_chapter_view_model.dart`
  - Views:
    - `presentation/reader_view/`
    - `presentation/reference_picker/`

## Direct import rule

Import concrete `application/view_models/*.dart` files directly.

Rule:
- New logic goes into `view_models/`.
- Do not recreate feature-level provider files under `application/`.
- Keep ownership explicit in imports so the architecture is visible from the file header.

## Decision guide

When adding code:

- Put it in `presentation/` if it is mostly widget composition or rendering.
- Put it in `application/view_models/` if it coordinates screen state or derives data for the UI.
- Put it in `data/` if it talks to Drift, files, parser output, or other persistence boundaries.
- Put it in `models/` if multiple layers need the same structured type.

## What not to do

- Do not put repository logic into widgets.
- Do not let a single screen become the only place that understands a feature's behavior.
- Do not create duplicate app-only copies of parser models unless there is a real boundary reason.
- Do not add more giant mixed-responsibility files if a feature already has `view_models/` and focused presentation files.

## Anti-drift rules for AI and future contributors

- Default to this feature structure unless there is a strong reason not to:
  - `models/`
  - `data/`
  - `application/view_models/`
  - `presentation/`
- Do not recreate barrel files that hide ownership.
- Put real implementations into `view_models/`.
- Do not solve file-size problems by creating vague `utils.dart` dumping grounds.
- Do not add persistence or repository work directly into widgets.
- Do not grow screen files by stacking more modal builders, callbacks, and rendering branches into one state class when ownership can be separated cleanly.

## Large-file guardrails

These are repo guardrails, not absolute laws, but future work should justify violating them.

- `0-200` lines:
  - excellent
  - keep doing what you're doing
- `200-500` lines:
  - acceptable
  - monitor for complexity; consider extracting widgets
- `500-1000` lines:
  - heavy
  - refactor immediately; split logic from UI
- `1000+` lines:
  - critical
  - treat the file as a God Object; it is likely difficult to test or maintain safely

Preferred splits:

- screen shell vs child widgets
- widget rendering vs state orchestration
- session state vs preferences vs derived state
- repository vs mappers/serialization helpers

Avoid bad splits:

- tiny files with no ownership boundary
- "misc" or "utils" files that hide feature logic

## Working rule

Before ending a task, quickly sanity-check:

- Is this code in the right layer?
- Is there any new business logic living in a screen that should be in a ViewModel or repository?
- Did any file grow enough that it is harder to read than before?

If yes, clean that up before stopping when practical.
