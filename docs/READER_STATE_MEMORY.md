# Reader State Memory

This note is a handoff for future debugging around reader navigation, mode
switching, and translation switching.

## Core Model

There are three layers of state involved in the reader:

1. Persisted disk state
2. Shared in-memory Riverpod state
3. Widget-local runtime state

Most reader bugs came from confusing those layers, especially in continuous
mode where the visible chapter on screen can differ from the saved reader
reference.

## Persisted To Disk

These are stored in `SharedPreferences` and survive app restarts.

- `bible_translation`
- `bible_book`
- `bible_chapter`
- `bible_verse`
- `reader_continuous_scrolling`
- `reader_layout_mode`
- `reader_show_book_introductions`
- `reader_show_verse_selector`

These keys are the long-term app state.

## Shared Riverpod State

These providers are the shared in-memory state for the running app session.

- `currentTranslationProvider`
- `currentReferenceProvider`
- `visibleReaderReferenceProvider`
- `continuousScrollingProvider`
- `readerLayoutModeProvider`
- selection and annotation UI providers
- async provider caches for books, chapters, and translations

Important distinction:

- `currentReferenceProvider` is the official shared reader anchor.
- `visibleReaderReferenceProvider` is the visible chapter anchor used for
  continuous mode.

Those two references can drift apart if the user manually scrolls in continuous
mode and the visible chapter is not synced back before another action uses the
older shared reader reference.

## Widget-Local Runtime State

Inside `_BibleTextViewState`, the following are widget-local and not durable:

- `ItemScrollController`
- `ItemPositionsListener`
- `_continuousSections`
- `_continuousChapterFutures`
- `_hydratedContinuousChapters`
- `_verseKeys`
- `_scrollableListKey`
- `_scrollableListInitialIndex`
- local focus/selection rendering state

This state belongs to the current reader widget instance only. It can be
recreated when the widget is rebuilt or replaced.

## Single-Chapter Mode

Single-chapter mode mainly depends on:

- `currentReferenceProvider`
- current translation
- one current chapter async load
- local verse focus and selection state

It is lighter than continuous mode because it only needs one chapter at a time.

## Continuous Mode

Continuous mode depends on:

- `currentReferenceProvider`
- `visibleReaderReferenceProvider`
- chapter section indexing across the available books
- nearby chapter hydration
- scroll position listeners and item controllers

Continuous mode uses more memory because it tracks the current viewport and
keeps surrounding chapter data around the reading position.

## Important Bug Pattern

The main issue was not that both reader layouts were loaded and fighting each
other at the same time.

The actual issue was:

1. The user manually scrolled in continuous mode.
2. The chapter visible on screen changed.
3. `currentReferenceProvider` did not always update to match that visible
   chapter before another action happened.
4. A later action, like switching translations or switching reader modes, used
   the older shared reference instead of the chapter actually on screen.

That is why the behavior felt inconsistent.

## Current Fix Strategy

The code now uses `visibleReaderReferenceProvider` as the viewport anchor for
continuous mode.

The visible reference is updated from the continuous reader when:

- the visible chapter changes from scrolling
- the user jumps chapters in continuous mode
- the user changes reference in continuous mode

Before actions that should follow the chapter currently on screen, the app
anchors `currentReferenceProvider` to `visibleReaderReferenceProvider`.

This currently includes:

- translation switching
- switching out of continuous mode

## Mental Model

Use this model when debugging:

- Disk state: where the app last persisted the reader location/settings
- Riverpod state: shared session truth used across screens
- Widget state: transient rendering and scroll mechanics for the active view

In continuous mode, there are effectively two useful references:

- shared reader anchor: `currentReference`
- visible viewport anchor: `visibleReaderReference`

If a feature should follow what the user is actually looking at, it usually
needs to consider the visible reference before relying on `currentReference`
alone.
