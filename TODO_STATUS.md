
# Basic Bible App — Todo Status

## Purpose

Execution tracker for `basic_bible`. Complements `CONTEXT.md` (engineering context) and `README.md` (public roadmap).

**Status meanings:**

- `done` — implemented and verified in the current repo
- `in_progress` — actively being worked or partially landed
- `next` — recommended immediate follow-up
- `todo` — valuable but not yet the immediate next task
- `blocked` — cannot move safely without another prerequisite or decision

**Agent rule — required before ending any work session:**

1. Move completed work into `Completed Recently`.
2. Update `Current Status` to reflect what is actually in the repo right now.
3. Set `Recommended Next Step` to ONE concrete next task.
4. Trim `Completed Recently` to the last 10 entries — older history lives in `git log`.
5. Remove any `Current Status` line that is no longer true.
6. Update `CONTEXT.md` only if a structural decision changed (new architecture, new caveat, fixed caveat). Do not update it for routine task completion.

If you skip this step the next agent will start from stale information.

**Operating rules:**

- Update this file whenever a meaningful engineering task starts or finishes.
- Keep `Current Status` to only genuinely active or unresolved work.
- Keep `Recommended Next Step` to ONE item — replace it when priorities shift.
- Move finished work to `Completed Recently` as soon as it is verified.
- When a task changes user-visible behavior, add a `README.md` reminder.
- After any meaningful unit of work, commit with a clear message describing the actual change.

---

## Known Technical Debt

Structural issues that will slow down future app work if not addressed.
Separate from feature backlog — these affect correctness, safety, and maintainability.

| Issue | Severity | Description |
| --- | --- | --- |
| Destructive database migrations | High | `MigrationStrategy` currently deletes all tables on any schema version bump. This destroys all user-imported Bibles when the schema changes. Needs additive migrations that preserve data. |
| App models duplicate parser models | High | `lib/src/models/bible_models.dart` redefines every type from `bible_parser_flutter` with a `Bible` prefix (`BibleVerseSpanKind`, `BibleFootnote`, etc.). If the parser model changes, the app breaks silently. These should re-export the parser types or share a common interface. |
| No lazy loading | Medium | The entire Bible is loaded into memory. There is no chapter-level streaming or lazy page loading. For large translations this is a memory and startup cost that will eventually need addressing. |
| SharedPreferences async loading not exposed | Medium | Each Riverpod `StateNotifier` loads from `SharedPreferences` asynchronously in `_loadSavedValue()` but exposes no loading state. This can cause brief UI glitches on startup before saved values are applied. |
| Generic error handling | Low | `AppBibleRepository` throws `Exception('...')` with plain context strings instead of structured error types. Makes error handling and user-facing messaging harder to improve. |
| Hardcoded download URLs | Low | Built-in translation GitHub URLs are hardcoded with no version pinning or fallback mirrors. If the source repo moves or renames a file, downloads silently fail. |
| Web storage still in-memory | Low | Non-web platforms use file-backed SQLite. Web still falls back to in-memory storage, so cached Bibles are lost on every page reload. |

---

## Recommended Next Step

- `next` Finish the focused References-screen regression check so changing references from the picker always keeps the whole-Bible scroller and visible-position state in sync.

**Why this first:**

- The picker layout is now more responsive on both narrow and wide screens, so the remaining reference-flow problem is behavioral rather than visual.
- This is the clearest unresolved gap still called out in `Current Status`, and it directly affects navigation confidence in the reader.

**Definition of done:**

- Picking a book/chapter/verse from the References screen always lands on the correct visible location in both normal and continuous reading modes.
- Returning from the picker does not leave the reference bar, selected reference, and visible scroller position disagreeing about the current location.

---

## Current Status

- `in_progress` References screen chapter tiles still need a focused regression check — interacting with the reference bar or selector does not always keep the whole-Bible scroller and visible position in sync.
- `in_progress` The reader has working verse-list and document modes, structured note popups, inline annotation markers, and source-driven paragraph support, but document-mode fidelity is limited by what the parser preserves.
- `in_progress` The parser/app pipeline preserves partial rich content across USFX, OSIS, and Zefania, but many non-verse layout cases and source-specific tags are still normalized too aggressively before the reader sees them.
- `in_progress` Non-web Bible caching is persistent; web still falls back to in-memory storage.
- `in_progress` Built-in, downloaded, and imported translations share one metadata-driven resolution path, but broader translation-library management is still unfinished.
- `in_progress` Active app code is mostly organized under `lib/src/features/`, but some shared providers/services still sit outside that feature-first structure.

---

## Completed Recently

- `done` Reworked the References picker layout so it now adapts more cleanly across mobile and desktop: phones keep a tighter one-book-at-a-time card flow with adaptive chapter/verse grids, while wider screens use a split book-list/detail-pane layout with clearer search and selection context.
- `done` Fixed verse focus highlight re-appearing when returning to Bible tab — `_showSelectedVerseFocus` now starts as `false` and only enables on explicit navigation events (cross-ref/footnote jumps).
- `done` Fixed `wordsOfJesus` and `word` spans not dimming when another verse is focused — `_spanColor` now respects the base color alpha for all span kinds.
- `done` Fixed verse focus not dismissing on desktop mouse scroll — wrapped build in `Listener(onPointerSignal:)` to catch `PointerScrollEvent`.
- `done` Added `<q who="...">` speaker attribution metadata to OSIS parser — non-Jesus speakers now emit `quoteWho` in span metadata.
- `done` Added `emphasis`, `bold`, `italic`, `properName`, `selah`, `acrosticHeading` to `BibleVerseSpanKind` with matching render styles (italic, bold w700, underline).
- `done` Added `divineNameTag` to `BibleVerseSpanKind` and wired bold rendering for it in both verse-list and document mode span helpers.
- `done` Added `BibleCrossReference.originRef`, updated serializer, and wired it to the note sheet as a muted origin prefix on cross-reference rows.
- `done` OSIS and Zefania footnotes now use the structured note sheet rendering path after the parser started populating `bodyText` for all three formats.
- `done` Updated note sheet to render `bodyText`, `originRef`, and `quotedText` as distinct visual elements — origin ref in muted smaller text, body in normal weight, quoted text in italic; falls back to merged `text` for OSIS/Zefania.

---

## Prioritized Backlog

### 1. Parser format fidelity (active)

Status: `in_progress`

Scope:

- Preserve every meaningful tag from USFX, OSIS, and Zefania — no intentional drops.
- See `README.md` format support tables for the specific `❌ Not yet` items that are still open.
- Priority order within this area: footnote parts → intro paragraphs → divine name / inline tags → poetry fidelity → word metadata → tables.

Why it matters:

- The app's goal is full format fidelity, not just plain-verse extraction.
- Every `❌ Not yet` row in the format tables is planned work.

README reminder: Update the format support tables in `README.md` as each feature lands.

### 2. Fix database migrations

Status: `todo`

Scope:

- Replace the current destructive migration strategy with additive column/table migrations.
- Verify that user-imported Bibles survive a schema version bump.
- Add migration tests.

Why it matters:

- The current strategy will silently destroy all user-imported content on the next schema change.

### 3. Deduplicate app and parser models

Status: `todo`

Scope:

- Remove the duplicated `Bible`-prefixed model types from `lib/src/models/bible_models.dart`.
- Re-export types from `bible_parser_flutter` directly, or move to a shared interface.
- Fix any downstream consumers that depend on the prefixed names.

Why it matters:

- A parser model change currently has a high risk of silently breaking the app with no compile-time warning.

### 4. Finish translation-library management

Status: `in_progress`

Scope:

- Add clearer user-facing status for installed, downloaded, and imported translations.
- Add search, language filtering, and per-translation actions.
- Decide online-only vs. download behavior explicitly.
- Preserve the same logical reading location across translation switches.

### 5. Finish reader document-mode fidelity

Status: `in_progress`

Scope:

- Render more parser-provided block types with distinct visual treatment.
- Preserve source-driven spacing, section breaks, poetry layout, and front-matter layout in the UI.
- Reduce app-side guessing where the parser already knows something more specific.

What "done" means:

- Document mode feels like it follows the source file structure, not a reconstruction from generic text blocks.
- Poetry, headings, intros, and prose sections each render with clearly distinct visual treatment.

### 6. Finish structured footnote and cross-reference UX

Status: `in_progress`

Scope:

- Improve the note sheet so it reflects parser structure more faithfully.
- Keep direct navigation using structured cross-reference targets.
- Ensure popup previews use the same anchor logic as the main reader.
- Add "go back" navigation after a cross-reference or footnote verse jump, so the user can return to the verse they were reading before the jump.

### 7. Finish startup and background warm-up behavior

Status: `in_progress`

Scope:

- Confirm that tab switches, translation switches, and fresh launches all benefit from background preload.
- Only add a dedicated startup loading screen if background warm-up is not enough.

### 8. Finish web storage behavior

Status: `todo`

Scope:

- Replace the in-memory web fallback with a real persistent web storage path.
- Verify imports and cached translations survive reloads on web the same way they do on desktop/mobile.

### 9. Finish remaining architecture cleanup

Status: `in_progress`

Scope:

- Move remaining shared services/providers that still sit outside the feature-first structure.
- Keep placeholder/legacy paths from slowly becoming active app paths again.

### 10. Keep README and docs aligned with repo truth

Status: `in_progress`

Scope:

- Update format support tables in `README.md` as parser features land.
- Update feature checkboxes and capability descriptions when behavior actually changes.

---

## Blockers / Risks

- `blocked` Richer parser features in the app are limited by what the parser itself preserves — parser work must lead app-side rendering work.
- `blocked` Additive database migrations need to be designed before the next schema change, or user data will be lost.

---

## README.md Reminder

- Do not mark features done in `README.md` until the behavior is implemented and verified.
- After any major task closes, check whether `README.md` needs updated format tables, feature checkboxes, or capability descriptions.

---

## Update Template

1. Before coding: add the planned task to `Current Status` or backlog.
2. Do the implementation work.
3. Move finished work to `Completed Recently`.
4. Update `Current Status` to reflect repo reality.
5. Add targeted code comments where future readers would otherwise have to reverse-engineer intent.
6. Run verification matching the scope of the change.
7. Commit with a focused message.
8. Replace `Recommended Next Step` if priorities changed.
9. Add or revise the matching `README.md` reminder.
