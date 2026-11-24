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
- `_continuousController` (`ContinuousReaderController`: the chapter list,
  memoized chapter loads, the 48-chapter hydrated cache, prefetch)
- `_lastSyncedSectionIndex` (last chapter the viewport sync reported)
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

### Rebuild rules (performance)

Rebuilding the reader re-renders every verse of every visible chapter, so
continuous mode avoids it on the paths that fire while reading:

- **A chapter's verses finish loading:** only that chapter's `FutureBuilder`
  rebuilds. `ContinuousReaderController` does not notify the reader (it used
  to, and a jump re-rendered the screen up to ~11 times as nearby chapters
  loaded).
- **A new chapter scrolls into view:** the outer reader keeps the visible
  chapter in a `ValueNotifier` (`_visibleReference`, set through
  `_setVisibleReference`), and only the chapter bar listens to it.
- **Every frame while scrolling:** `_syncVisibleChapterFromViewport` returns
  early unless the chapters in view changed, so prefetching and reporting run
  once per chapter, not once per frame.
- **Prefetch runs ahead of the scroll direction** (`_prefetchAheadOfScroll`):
  the 4 chapters past the bottom-most visible chapter when scrolling down, past
  the top-most when scrolling up. It used to be centred on the top chapter, so
  half the window was spent on chapters just read (already cached) and the
  ones coming up from the bottom loaded only as they appeared: scrolling down
  showed placeholders while scrolling up was instant.

Keep new per-scroll or per-load work off `setState` on the reader states.

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
continuous mode. The outer reader sets it together with its own
`_visibleReference` notifier in `_setVisibleReference` (one place, applied
after the frame if reported mid-build).

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
alone. `searchContextReferenceProvider` already does this (visible chapter in
continuous mode, `currentReference` otherwise); prefer reading it over
combining the two by hand, because `visibleReaderReference` is not cleared when
continuous mode is turned off.

In split view the second reader has its own copies of all of these (see
`lib/src/features/reader/presentation/split_view/README.md`).
