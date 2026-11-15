# Claude Session Handoff

This file summarizes the modifications made during this chat session, grouped
by problem area and optimized for senior review.

## Review Priorities

If reviewing this session as a senior developer, focus on these areas first:

1. Continuous reader state synchronization
2. Large-distance chapter jumps in continuous mode
3. Translation switching and mode switching anchors
4. Annotation/note UX changes and large-note safeguards
5. KJV source selection and web/native asset split
6. Native USFM parser platform support and failure messaging

## 1. Continuous Reader Async / Navigation Fixes

### Problem

Large jumps in continuous mode could update the reference UI but leave the
visible content behind. Translation switching and mode switching also became
inconsistent after manual scrolling because the app could use a stale shared
reference instead of the visible chapter on screen.

### Main changes

- `lib/src/features/reader/application/view_models/reader_session_view_models.dart`
  - Moved `state = reference` to the top of `ReferenceNotifier.setReference()`
    so the UI updates immediately before prefs writes.
  - Parallelized prefs writes with `Future.wait`.
  - Applied the same "state first" fix to `TranslationNotifier.setTranslation()`.
  - Added `visibleReaderReferenceProvider` to track the currently visible
    chapter in continuous mode.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
  - Updated continuous-mode callbacks to keep
    `visibleReaderReferenceProvider` in sync.
  - When adjacent-chapter navigation happens in continuous mode, both the local
    visible reference and the shared visible provider are updated.
  - When picker-based chapter navigation happens in continuous mode, the same
    visible anchor is updated before the shared `currentReference` write.

- `lib/src/features/library/presentation/versions_screen_actions.dart`
  - Added `_anchorReaderReferenceForTranslationSwitch()`.
  - Before translation-changing operations, if continuous mode is enabled, the
    code now copies the visible chapter into `currentReferenceProvider`.
  - Applied that anchor before:
    - select translation
    - open translation for session
    - download translation
    - import translation
    - clear translation cache
    - fallback translation switches during delete/remove flows

- `lib/src/features/home/presentation/home_screen.dart`
  - Added `_anchorVisibleContinuousReferenceIfNeeded()`.
  - Before turning continuous scrolling off, the visible continuous chapter is
    committed back into `currentReferenceProvider` so document/single-chapter
    mode opens at the chapter actually on screen.
  - Before changing reader layout mode, the same visible chapter is committed
    back into `currentReferenceProvider` so switching between document mode and
    verse-list mode in continuous mode stays anchored to the chapter currently
    on screen.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
  - `_BibleTextViewState.initState()` now prefers `widget.displayReference`
    over `widget.reference` when seeding the initial continuous list index and
    prefetch window.
  - This matters because `_BibleTextView` is recreated when layout mode changes
    since the widget key includes `layoutMode`.
  - Without this, switching between document mode and verse-list mode in
    continuous mode could recreate the view at the stale shared reference
    instead of the chapter actually visible before the rebuild.

### Intent

Separate "shared saved reader reference" from "visible chapter in the current
continuous viewport", then explicitly synchronize them before actions that
should follow what the user is actually reading.

## 2. Large-Jump Continuous Scroll Fix

### Problem

Very large jumps in continuous mode, such as jumping across distant books from
the reference picker, could fail because `scrollTo(index:)` estimation drifted
too far across many unhydrated chapters.

### Main changes

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
  - Added `_scrollableListKey`.
  - Added `_scrollableListInitialIndex`.
  - Seeded the initial continuous list index from the target chapter.
  - Added `_resetScrollableListAt(int targetIndex)`.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_state_core.dart`
  - Reworked `_scheduleChapterFocus()`.
  - Small jumps still use animated `scrollTo`.
  - Large jumps rebuild `ScrollablePositionedList` at the exact target index.
  - Immediate visible-reference callback keeps the chapter bar in sync instead
    of waiting for later scroll notifications.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_state_rendering.dart`
  - `ScrollablePositionedList.builder` now uses:
    - `key: _scrollableListKey`
    - `initialScrollIndex: _scrollableListInitialIndex`
    - `initialAlignment: 0.02`

### Intent

Use full-list reset for large jumps to avoid position-estimation error while
keeping smooth animated navigation for nearby chapters.

## 3. Reference Picker Loading Guard

### Problem

Opening the reference picker while the reader was still loading could leave
users stuck on the picker or interacting with incomplete data.

### Main changes

- `lib/src/features/reader/presentation/reference_picker/chapter_bar.dart`
  - Added `canOpenReferencePicker`.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
  - Computes `canOpenReferencePicker` from reader loading state and shell books.
  - Passes the flag down into the chapter bar.

### Intent

Prevent navigation into a picker flow before the reader has enough state to
handle it correctly.

## 4. Notes / Annotation UX and Large-Selection Safeguards

### Problems

- Large note selections could lag or freeze the app.
- The reader sheet needed clearer CRUD flows and a non-edit detail view.
- Tapping a note from the sheet should open detail, and tapping in detail
  should open edit mode by default.

### Main changes

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
  - Added `static const _maxVersesPerNoteSelection = 250`.
  - `_handleNotePressed()` now blocks oversize note creation and shows a
    snackbar instead of trying to open a massive edit session.

- New file:
  - `lib/src/features/annotations/presentation/annotation_detail_screen.dart`
    - Read-only detail screen for a selected annotation.
    - Tapping the note body transitions into edit flow.

- New file:
  - `lib/src/features/annotations/presentation/linked_verses_section.dart`
    - Shared widget for rendering linked verses with truncation and `+N more`.

- Updated annotation/note surfaces to use the shared linked-verse UI:
  - `lib/src/features/annotations/presentation/note_editor_screen.dart`
  - `lib/src/features/annotations/presentation/notes_screen.dart`
  - `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_personal_notes.dart`

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_personal_notes.dart`
  - Reader sheet now supports stronger CRUD-oriented flows for the selected
    verse context.
  - Tapping a note card should open the detail screen.

- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_state_core.dart`
  - Reader sheet flows updated to support the new detail/edit transitions and
    refresh behavior.

### Additional stability work

- `lib/src/features/annotations/presentation/note_editor_screen.dart`
  - Deferred some pop/selection return-path state changes to reduce
    `mouse_tracker` assertion churn when closing editor flows.

### Intent

Reduce reader freezes for extreme note selections and split "view details" from
"edit" so the UI does not force large note payloads directly into the editor.

## 5. KJV Asset Source Migration

### Problem

The session introduced `assets/bible/kjv.sqlite` and switched KJV loading to
SQLite, but web still needs the XML/USFX path.

### Main changes

- `lib/src/features/library/data/bible_translation_catalog.dart`
  - KJV is now platform-aware:
    - native: `assets/bible/kjv.sqlite`
    - web: `assets/bible/eng-kjv2006_usfx.xml`
  - Format is conditional to match the chosen source.

- `pubspec.yaml`
  - Includes both built-in assets.

- New asset:
  - `assets/bible/kjv.sqlite`

### Intent

Use SQLite as the primary native built-in source while preserving web
compatibility with the existing XML/USFX path.

## 6. USFM Parser Native Support / Messaging

### Problem

USFM parsing depended on a native Rust parser that was unavailable on some
desktop platforms, leading to poor failure messaging and incomplete platform
support.

### Main changes

- `lib/src/features/library/data/usfm_parser_bridge.dart`
- `lib/src/features/library/data/usfm_parser_bridge_native.dart`
- `lib/src/features/library/data/usfm_parser_bridge_stub.dart`
- `lib/src/features/library/data/usfm_parser_bridge_web.dart`
  - Added exports and platform-specific unavailability reasoning.
  - Improved native parser search paths and diagnostics.

- `lib/src/features/library/data/bible_source_parser.dart`
  - Throws richer failure messages when native parsing is unavailable.

- New file:
  - `macos/Runner/build_usfm_parser_macos.sh`

- `macos/Runner.xcodeproj/project.pbxproj`
  - Added a build phase to build/copy the macOS parser library.

### Related native parser files present in working tree

- `native/usfm_parser/Cargo.toml`
- `native/usfm_parser/src/lib.rs`
- `linux/CMakeLists.txt`
- `windows/CMakeLists.txt`

### Intent

Improve platform support, and where support is missing, fail with actionable
messages instead of a generic unsupported-operation error.

## 7. Reader State Documentation Added

### New file

- `docs/READER_STATE_MEMORY.md`

### Purpose

Documents the state model for:

- persisted disk state
- Riverpod session state
- widget-local runtime state
- the distinction between `currentReferenceProvider` and
  `visibleReaderReferenceProvider`

This is specifically intended to help future debugging of continuous mode.

## New Files Added During This Session

These are the new files added during this session that should be reviewed:

- `assets/bible/kjv.sqlite`
- `docs/READER_STATE_MEMORY.md`
- `lib/src/features/annotations/presentation/annotation_detail_screen.dart`
- `lib/src/features/annotations/presentation/linked_verses_section.dart`
- `macos/Runner/build_usfm_parser_macos.sh`

Also present as new files in the wider working tree related to the same effort:

- `lib/src/features/library/data/bible_archive_support.dart`
- `lib/src/features/library/data/usfm_bundle_support.dart`
- `lib/src/features/library/data/usfm_parser_bridge.dart`
- `lib/src/features/library/data/usfm_parser_bridge_native.dart`
- `lib/src/features/library/data/usfm_parser_bridge_stub.dart`
- `lib/src/features/library/data/usfm_parser_bridge_web.dart`
- `native/usfm_parser/Cargo.toml`
- `native/usfm_parser/src/lib.rs`
- `test/features/library/data/bible_archive_support_test.dart`
- `test/features/library/data/remote_translation_catalog_service_test.dart`
- `test/features/library/data/usfm_bundle_support_test.dart`

## Files Most Worth Inspecting

If Claude is doing a senior-level pass, start here:

- `lib/src/features/reader/application/view_models/reader_session_view_models.dart`
- `lib/src/features/library/presentation/versions_screen_actions.dart`
- `lib/src/features/home/presentation/home_screen.dart`
- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab.dart`
- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_state_core.dart`
- `lib/src/features/reader/presentation/reader_view/bible_viewer_tab_state_rendering.dart`
- `lib/src/features/annotations/presentation/annotation_detail_screen.dart`
- `lib/src/features/annotations/presentation/linked_verses_section.dart`
- `lib/src/features/library/data/bible_translation_catalog.dart`
- `lib/src/features/library/data/usfm_parser_bridge_native.dart`

## Known Remaining Concerns

These are the areas I would still treat as review targets:

- Continuous-mode state sync is now more explicit, but it is still easy for
  future features to accidentally read `currentReferenceProvider` when they
  should first consider `visibleReaderReferenceProvider`.
- Layout changes now anchor and reseed from the visible reference, but any
  future key-based rebuild of `_BibleTextView` in continuous mode should be
  checked to make sure it seeds from `displayReference` rather than the stale
  shared reference.
- Large note/editor flows were reduced in cost, but truly huge annotations may
  still need more explicit pagination/virtualization if users keep creating
  very large linked-verse notes.
- The repeated Flutter `mouse_tracker` assertions looked like timing-sensitive
  UI teardown issues. Some mitigation was added, but this area deserves extra
  scrutiny.
- Desktop USFM support should be validated on real macOS/Linux/Windows builds,
  not just code review.
- `flutter analyze` is clean except for the two existing `drift/web.dart`
  deprecation infos in:
  - `lib/src/services/app_database_executor_web.dart`
  - `lib/src/services/translation_database_executor_web.dart`

## Suggested Mental Model For Review

For reader bugs, review with this model:

- Persisted state: what survives app restart
- Riverpod state: shared session truth
- Widget state: current view mechanics and local caches

The most important conceptual split is:

- `currentReferenceProvider` = shared reader anchor
- `visibleReaderReferenceProvider` = visible continuous viewport anchor

Any action that should follow what the user is actually looking at should be
checked against the visible anchor path.
