# References Screen Code Flow Analysis

## Data Flow Diagram

```
User picks reference in ReferencePickerScreen
        ↓
Navigator.pop(reference) returns to ChapterBar
        ↓
onReferenceChanged(reference) callback
        ↓
Parallel updates:
  ├→ setState(_continuousVisibleReference = reference) [if continuous mode]
  └→ ref.read(currentReferenceProvider.notifier).setReference(reference)
        ↓
BibleViewerTab rebuild triggered
        ↓
didUpdateWidget checks for changes:
  ├→ Reference changed? Schedule verse focus if verse != null
  ├→ Chapter changed? Schedule chapter focus if verse == null (continuous mode)
  └→ Chapter hydration done? Reschedule verse focus if needed
        ↓
_scheduleVerseFocus or _scheduleChapterFocus (post-frame)
        ↓
Scrollable.ensureVisible animates scroll to target
        ↓
Reference bar updates (shows displayReference)
```

## Key State Variables

### BibleViewerTab._BibleTextViewState

- `_continuousVisibleReference`: Tracks which chapter is currently visible during scrolling
- `_scrollController`: Controls the ListView/continuous view scroll
- `_showSelectedVerseFocus`: Highlights the focused verse with dimmed other verses
- `_suppressNextChapterAutoScroll`: Flag to prevent auto-scroll after manual scroll triggers visible-chapter sync

## Critical Code Paths

### Path 1: Single Chapter Mode Picker Selection

**User selects Genesis 5 while viewing Genesis 1**

1. `ReferencePickerScreen._selectReference()` pops with `BibleReference(bookId: 'GEN', chapter: 5)`
2. `ChapterBar.onReferenceChanged()` is called
3. `currentReferenceProvider.notifier.setReference()` updates provider
4. `currentChapterProvider` FutureProvider observes reference change and loads Genesis 5 verses
5. `BibleViewerTab._BibleTextViewState.didUpdateWidget()`:
   - Detects `oldWidget.chapter != widget.chapter`
   - Calls `_scheduleVerseFocus()`
6. Next frame: `_scheduleVerseFocus()` runs
   - Looks up verse key (if verse was selected)
   - Calls `Scrollable.ensureVisible()` to scroll
7. Reference bar updates to show Genesis 5

**Potential Issues:**
- If verse selection fails to parse, reference updates but scroll doesn't happen
- If chapter hydration is slow, scroll might trigger before verses are available (will be retried when chapter updates)

---

### Path 2: Continuous Scroll Mode Picker Selection

**User selects Genesis 15 while viewing Genesis 5 in continuous mode**

1. `onReferenceChanged()` is called with Genesis 15
2. **First update (state-based):**
   - `setState(_continuousVisibleReference = Genesis 15)` schedules rebuild
   - Reference bar immediately shows Genesis 15
3. **Second update (provider-based):**
   - `setReference(Genesis 15)` updates currentReferenceProvider
   - BibleViewerTab rebuilds with new currentReference
4. `didUpdateWidget()` detects reference change
5. If verse specified: `_scheduleVerseFocus()` scrolls to verse
6. If no verse: `_scheduleChapterFocus()` scrolls to chapter header
7. The `_suppressNextChapterAutoScroll` flag is checked:
   - If set (from manual scroll), skip auto-scroll
   - Otherwise, proceed with verse/chapter focus
8. As scroll animation runs:
   - `ScrollUpdateNotification` fires on each frame
   - `_queueVisibleChapterSync()` coalesces these into periodic syncs
   - `_syncVisibleChapterFromViewport()` calculates which chapter is "best visible"
   - Updates displayed reference via `onVisibleReferenceChanged()`
9. As scroll reaches target, visible chapter matches picked reference

**Potential Issues:**
- **Race condition in Path 1/2**: If `_scheduleVerseFocus()` is called but verse widget not yet mounted, scroll silently fails. Recovery happens when chapter hydration completes and triggers widget rebuild.
- **Sync lag in Path 2**: During scroll animation, `_syncVisibleChapterFromViewport()` might report a different "visible" chapter than the programmatically-scrolling-to chapter. This causes reference bar to flicker or show intermediate chapters.
- **Double rebuild coordination**: The `setState()` for `_continuousVisibleReference` and the `ref.read()` for provider update happen sequentially. If timing is off, two separate rebuilds could cause transient misalignment.

---

## Code Locations

| Component | Location |
|-----------|----------|
| Picker screen | `reference_screen.dart` lines 7–69 (ReferenceScreen), 189–583 (ReferencePickerScreen) |
| Reference bar | `reference_bar.dart` lines 6–163 (ChapterBar), 149–161 (_showReferencePicker) |
| Callback registration | `bible_viewer_tab.dart` lines 189–198 (onReferenceChanged) |
| Reference sync trigger | `bible_viewer_tab.dart` lines 340–361 (didUpdateWidget) |
| Verse focus scheduling | `bible_viewer_tab.dart` lines 371–390 (_scheduleVerseFocus) |
| Chapter focus scheduling | `bible_viewer_tab.dart` lines 392–407 (_scheduleChapterFocus) |
| Visible chapter sync (continuous) | `bible_viewer_tab.dart` lines 895–925 (_syncVisibleChapterFromViewport) |
| Provider definition | `bible_provider.dart` lines 134–160 (ReferenceNotifier) |
| Chapter provider | `current_chapter_provider.dart` lines 8–46 (currentChapterProvider) |

---

## Known Limitations

1. **Verse-level scroll timing**: If verse widget not mounted when `Scrollable.ensureVisible` is called, scroll does not happen until chapter hydration completes and reschedules focus.

2. **Reference bar flicker in continuous mode**: During scroll animation, the "visible chapter" sync might report intermediate chapters, causing the floating reference bar to show multiple references as scroll progresses.

3. **Manual scroll interruption**: If user starts scrolling while the picker is being animated closed and scroll focus is being scheduled, the `_suppressNextChapterAutoScroll` flag might not be set in time, causing a double-scroll or conflict.

---

## Recommendations for Testing

1. **Test verse-level selection** with slow chapter hydration (e.g., large chapter with many verses)
2. **Test reference bar updates** during continuous scroll animations to check for flicker
3. **Test manual scroll interruption** by:
   - Opening picker
   - Selecting a reference
   - While picker animation is closing, manually scroll in the opposite direction
   - Verify reference bar and scroll position end up in sync
4. **Test verse not found** by:
   - Selecting a verse number that doesn't exist (if possible)
   - Verify fallback to chapter header

