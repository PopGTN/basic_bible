# References Screen Regression Test Plan

## Overview
This test plan verifies that the References picker keeps the reader in sync with the selected reference, ensuring:
1. Picking a book/chapter/verse lands on the correct visible location
2. Returning from the picker doesn't leave the reference bar out of sync with the scroll position

## Test Environment Setup
- Load a translation with multiple books and chapters
- Test both **Single Chapter Mode** and **Continuous Scrolling Mode**
- Test with both **Verse List Mode** and **Document Mode**
- Verify on both **Mobile** and **Desktop** viewports

## Core Test Scenarios

### Scenario 1: Single Chapter Mode — Same Book, Different Chapter
**Setup:** Reader is viewing Genesis 1 in single chapter mode
**Action:**
  1. Tap reference bar → opens ReferencePickerScreen
  2. Select Genesis 5
  3. Verify that returning from picker:
     - Reference bar shows "Genesis 5"
     - Chapter content displays Genesis 5 verses
     - Scroll position is at top of chapter

**Expected Result:** ✅ Chapter changes, reference bar and scroll position sync

---

### Scenario 2: Single Chapter Mode — Different Book
**Setup:** Reader is viewing Genesis 1
**Action:**
  1. Open picker
  2. Search for and select "Matthew" chapter 1
  3. Close picker

**Expected Result:** ✅ Book and chapter change, content updates, bars are in sync

---

### Scenario 3: Verse-Level Navigation in Single Chapter Mode
**Setup:** Reader is viewing Matthew 5, verse selector is enabled
**Action:**
  1. Open picker
  2. Select Matthew 5, then pick verse 7
  3. Close picker

**Expected Result:** ✅ Reader scrolls to Matthew 5:7 specifically, verse is highlighted

---

### Scenario 4: Continuous Scrolling — Chapter Change
**Setup:** Reader is viewing Genesis 1 in continuous scroll mode
**Action:**
  1. Open picker
  2. Select Genesis 15
  3. Close picker

**Expected Result:** ✅ Continuous view scrolls to Genesis 15, reference bar shows Genesis 15

---

### Scenario 5: Continuous Scrolling — Verse-Level Jump
**Setup:** Reader is viewing Genesis 1:1 in continuous scroll, verse selector enabled
**Action:**
  1. Open picker
  2. Select Genesis 10:5 (different chapter)
  3. Close picker

**Expected Result:** ✅ Continuous view scrolls to Genesis 10:5, verse is highlighted with focus treatment

---

### Scenario 6: Rapid Picker Opens/Closes
**Setup:** Any mode
**Action:**
  1. Tap reference bar (opens picker)
  2. Immediately close without selecting (swipe back or back button)
  3. Verify reader state

**Expected Result:** ✅ Reader returns to previous state, no UI flickers, reference bar intact

---

### Scenario 7: Reference Bar Updates During Scroll
**Setup:** Continuous scroll mode, Genesis 1 visible
**Action:**
  1. Manually scroll down (e.g., Genesis 5 becomes visible)
  2. Reference bar updates to show Genesis 5
  3. Open picker while at Genesis 5
  4. Verify picker shows Genesis 5 as current

**Expected Result:** ✅ Picker reflects actual visible chapter, not just the provider state

---

### Scenario 8: History Navigation from Picker
**Setup:** Picker is open with reference history available
**Action:**
  1. Tap "History" button in picker
  2. Select a previous reference from history
  3. Close picker

**Expected Result:** ✅ Reader jumps to historical reference, scroll is in sync

---

## Known Issues to Verify Against

### Issue A: Verses Not Loading Yet
**Potential Problem:** When picker closes and verse-level scroll is scheduled, the verses might still be loading asynchronously. `Scrollable.ensureVisible` could fail silently if the verse widget isn't mounted yet.

**Verification:**
- Pick a verse in a large chapter that takes time to hydrate
- Observe whether scroll reaches the verse or gets stuck at chapter top
- Check if there's a delay in verse appearing after scroll

**Fix if Needed:**
- Ensure verse-focus scheduling waits for chapter hydration to complete
- Or use a callback mechanism when verses become available

---

### Issue B: Reference Bar Flash on Return
**Potential Problem:** In continuous scroll, briefly showing old reference before new one settles.

**Verification:**
- Open picker from Genesis 5
- Pick Matthew 10
- Watch reference bar closely as picker closes
- Should smoothly update, not flash old reference

**Fix if Needed:**
- Ensure both `_continuousVisibleReference` and `currentReference` update atomically
- Or suppress visible-reference updates briefly during picker navigation

---

### Issue C: Display Reference vs Actual Scroll Position
**Potential Problem:** Reference bar shows one chapter while actual scroll position is at a different chapter.

**Verification:** (Continuous scroll only)
- Pick a verse in Genesis 15
- While scrolling animation is in progress, check reference bar
- Verify reference bar shows target (Genesis 15) even if animation hasn't completed

**Fix if Needed:**
- Update displayReference atomically with scroll request
- Or ensure scroll completes before next reference updates are processed

---

## Edge Cases

1. **Picker closes without selection** — Reader should remain unchanged
2. **Same reference selected** — No unnecessary rebuild or scroll
3. **Invalid book ID** — Picker should not allow selection of non-existent books
4. **Out-of-range chapter** — Picker should clamp to valid chapters for book
5. **Out-of-range verse** — Picker should clamp to valid verses for chapter
6. **Empty chapter** — Should still scroll to chapter header, not crash

---

## Manual Testing Checklist

- [ ] Test Scenario 1 (same book)
- [ ] Test Scenario 2 (different book)
- [ ] Test Scenario 3 (verse navigation)
- [ ] Test Scenario 4 (continuous mode chapter)
- [ ] Test Scenario 5 (continuous mode verse)
- [ ] Test Scenario 6 (rapid open/close)
- [ ] Test Scenario 7 (reference bar during scroll)
- [ ] Test Scenario 8 (history navigation)
- [ ] Verify Issue A (verse loading)
- [ ] Verify Issue B (reference bar flash)
- [ ] Verify Issue C (display vs actual sync)
- [ ] Test all edge cases

---

## Integration Test Plan

Once manual testing is complete, add automated tests:

1. **Test: Picker selection updates provider** — Mock ReferenceNotifier and verify state changes
2. **Test: Chapter hydration waits before scroll** — Mock repository, verify scroll timing
3. **Test: Display reference updates with chapter change** — Verify continuous mode bar sync
4. **Test: Invalid reference fallback** — Pick non-existent book/chapter, verify fallback behavior
5. **Test: Verse focus highlight appears/disappears correctly** — Verify focus treatment

---

## Success Criteria

✅ All scenarios pass without visible glitches or misalignment
✅ Reference bar and scroll position always reflect the actual reader state
✅ No crashes or stuck scroll states
✅ Smooth transitions between picker return and settled reader state
✅ Integration tests cover main code paths

