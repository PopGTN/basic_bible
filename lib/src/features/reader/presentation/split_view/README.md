# Split View Module

Split view (#84) shows a second Bible reader next to the main one. The two
readers are independent: each has its own translation, chapter, scroll
position and verse selection.

The second pane is **not** a separate reader implementation. It is a second
`BibleViewerTab`, the same widget as the main reader, so every reader feature
(highlights, notes, verse details, continuous scrolling, fonts, settings)
works in both panes without duplicated code.

## Files

- `split_reader_layout.dart`
  - `SplitReaderLayout`: places the two readers side by side (700px wide or
    more) or stacked (narrower). `SplitReaderLayout.isAvailable` decides
    where split view is offered at all: in landscape, or 700px wide or more.
    A phone held upright gets no split button, and rotating it upright hides
    split view without turning it off: rotating back to landscape shows both
    readers again as they were. To offer split view on upright
    phones again (stacked), make `isAvailable` return true. Side by side, the second pane is on the left
    and the main reader on the right, under the app bar's tools.
  - `SplitPaneTranslationChip`: the second pane's translation button in the
    app bar. Side by side it sits just left of the divider (positioned from
    `splitDividerXProvider`); stacked, it sits among the app bar actions. It
    opens the same Versions screen as the main reader's, scoped to the pane.
  - `_PaneNavigator`: a reader's own navigator, used for both readers in split
    view on computers only (see "Screens the readers open").
- `../../application/view_models/split_view_view_models.dart`
  - `splitViewEnabledProvider`: on/off. Not saved; the app always starts with
    split view off.
  - `splitPaneContainerProvider`: the pane's provider scope (see below).
  - `splitPaneFollowsMainProvider`: the setting "Open Split View At Main
    Chapter" (Settings, saved, off by default).
  - `splitPaneOverrides`: what the pane gets its own copy of.
- `../reader_scope.dart`
  - `inReaderScope`: keeps a reader's scope for the screens it opens.

## How the panes stay independent

The reader reads its state from Riverpod providers such as
`currentTranslationProvider` and `currentReferenceProvider`. The second pane
runs inside a child `ProviderContainer` (`splitPaneContainerProvider`) that
overrides these with its own copies:

| Provider | In the pane |
|---|---|
| `currentTranslationProvider` | Own translation, saved under `split_view_translation`. The first time, it defaults to the main reader's. |
| `currentReferenceProvider` | Own chapter, not saved (`ReferenceNotifier.unsaved`). |
| `visibleReaderReferenceProvider` | Own chapter on screen in continuous scrolling. |
| `selectedVersesProvider`, `highlightPaletteExpandedProvider` | Own verse selection. |

Everything computed from those (books, current chapter, annotations, search
context, translation actions) is also listed in `_derivedReaderProviders`, so
the pane gets its own copy. Settings, fonts, notes storage and the downloaded
translations are shared by both panes.

### Why derived providers are listed by hand

Riverpod is meant to give a child scope its own copy of any provider whose
`dependencies` include an overridden one. As of riverpod 3.0.3 it does not do
this for a provider the main reader had already used before split view opened:
the pane silently shares the main reader's copy. The symptom is the second pane
showing the main reader's text and changing chapter with it. Listing a provider
as its own override (`[currentChapterProvider, ...]`) forces a pane copy.

## When opening and closing split view

- The scope is created the first time split view opens in an app session and
  kept until the app is relaunched, so closing and reopening split view returns
  the pane to where it was.
- The first opening after a launch starts the pane at the main reader's
  chapter. With "Open Split View At The Current Chapter" on, every opening does.
- "The main reader's chapter" is the chapter on screen in continuous
  scrolling, not the last one picked (`searchContextReferenceProvider`).
- Rotating a phone upright hides split view without turning it off; rotating
  back shows both readers again. The second pane returns to its chapter (at
  the top of it) and its verse selection is cleared.

## Performance

Split view runs two full readers, so every rendering cost is paid twice. Keep
to the reader's performance rules in `../reader_view/README.md`. Judge speed
with `flutter run --profile`; debug builds are several times slower.

## Screens the readers open

The reference picker, note editor, note details and verse sheets are built by
a navigator, outside the reader's widgets, so they would read the main
reader's providers. Every place in the reader flow that opens one wraps its
builder in `inReaderScope(context, builder)`, which carries the opening
reader's scope with it, including screens opened from those screens (note
editor, then reference picker, then its sheet).

Where they appear (`SplitReaderLayout.panesHaveOwnNavigators`):

- **Phones, tablets and the web:** full page, for both readers, the same as
  without split view.
- **Computers (Windows/macOS/Linux app):** inside the half of the reader that
  opened them, for both readers, so the other reader stays visible. Without
  split view the main reader opens them full page as usual.

## Rules when changing reader code

1. **A new provider computed from the pane's state** (it watches any provider
   in the table above, directly or through another one) needs a
   `dependencies:` list (Riverpod throws without one) **and** an entry in
   `_derivedReaderProviders`. `split_view_scoping_guard_test.dart` fails and
   names any provider you missed. If it must stay shared, add it to
   `_rootOnly` in that test instead, with a reason.
2. **A new screen or sheet opened from the reader** needs
   `builder: inReaderScope(context, ...)`, or from the second pane it acts on
   the main reader.
3. **Don't add state outside Riverpod** (statics, singletons) to the reader
   unless both panes really should share it, like the font size.
4. **Test scoping the realistic way:** use a provider in the main (root)
   container *before* creating the pane. A test that creates the pane first
   passes even when the bug is present.

## Tests

- `test/features/reader/split_view_test.dart`: panes show and move
  independently, layout and divider alignment, reopening behaviour and the
  setting, screens opened from the pane acting on the pane.
- `test/features/reader/split_view_scoping_guard_test.dart`: reads every
  `dependencies:` list under `lib/` and checks `_derivedReaderProviders` is
  complete.

## Troubleshooting

- **The pane shows the main reader's text or follows its chapter.** Do a full
  restart (hot restart `R`, or stop and run), not hot reload: the pane's scope
  is created once per run and hot reload keeps an old one. If it persists, a
  derived provider is missing from `_derivedReaderProviders`; run the guard
  test.
- **A screen opened from the pane changes the main reader.** Its builder is
  missing `inReaderScope`.
