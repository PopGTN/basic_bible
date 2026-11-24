
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
- Keep the MVVM-style feature structure intact:
  - `models/`
  - `data/`
  - `application/view_models/`
  - `presentation/`
- Do not recreate old feature-level provider files under `application/`; import the concrete `view_models/` files directly.
- When a file grows past roughly `500-700` lines and owns multiple concerns, split it before adding more feature work unless there is a documented reason not to.

---

## Known Technical Debt

Structural issues that will slow down future app work if not addressed.
Separate from feature backlog — these affect correctness, safety, and maintainability.

| Issue | Severity | Description |
| --- | --- | --- |
| Migration coverage is still thin | Medium | The app now uses additive migration steps for recent schema changes, but there is still no test that opens an older on-disk database and proves upgrade safety end to end. |
| App models duplicate parser models | High | `lib/src/models/bible_models.dart` re-exports split app model files under `lib/src/models/bible_models/`, but still duplicates parser types with `Bible` prefixes (`BibleVerseSpanKind`, `BibleFootnote`, etc.). If the parser model changes, the app breaks silently. These should re-export the parser types or share a common interface. |
| No lazy loading | Medium | The entire Bible is loaded into memory. There is no chapter-level streaming or lazy page loading. For large translations this is a memory and startup cost that will eventually need addressing. |
| SharedPreferences async loading not exposed | Medium | Each Riverpod `StateNotifier` loads from `SharedPreferences` asynchronously in `_loadSavedValue()` but exposes no loading state. This can cause brief UI glitches on startup before saved values are applied. |
| Generic error handling | Low | `AppBibleRepository` throws `Exception('...')` with plain context strings instead of structured error types. Makes error handling and user-facing messaging harder to improve. |
| Hardcoded download URLs | Low | Built-in translation GitHub URLs are hardcoded with no version pinning or fallback mirrors. If the source repo moves or renames a file, downloads silently fail. |
| Web storage uses deprecated drift API | Low | Web translation caches persist in IndexedDB through drift's legacy `WebDatabase`, which is deprecated in favour of `package:drift/wasm.dart`. |
| Reader presentation still centered on one large state object | Medium | The reader refactor split files by responsibility, but much of the orchestration still lives on a single `_BibleTextViewState`. Future cleanup should extract more standalone widgets/controllers so the reader does not drift back into a giant mixed-responsibility state class. |

---

## Recommended Next Step

- `next` Get John Ritchie Ltd's exact permission wording for both bundled hymnals and fill the `TODO_` fields (`tool/hymnals/bhb.meta.json`: edition, ISBN, copyright, permissionNotice, permissionDate; `nbhb.meta.json`: permissionNotice, permissionDate), confirm whether that permission covers the 38 Remembrance Hymns (Isaac Y. Ewan) in NBHB and the 13 flagged BHB hymns, then rebuild with `dart run tool/hymnals/build_hymnal.dart bhb nbhb`.

**Why this first:**

- The Hymns feature is built on branch `Hymnbooks-added`, but `test/features/hymns/bundled_hymnals_test.dart` deliberately fails (release gate) while any `TODO_` placeholder remains, the 13 BHB hymns listed as "rights to confirm" and the 38 NBHB Remembrance Hymns listed as third-party (see the build reports and `bible-data/licenses/hymnals/`) must be confirmed as covered. NBHB is now bundled from the clean 2021 source (678 hymns; the other publishers' songs are already left out). Only the project owner can get that wording from John Ritchie Ltd.

---

- `todo` Hymns (branch `Hymnbooks-added`): on-device QA on Android/iOS for share, print (printing plugin), file import, and back-gesture behaviour in the Hymns tab; then merge back into `test`.
- `todo` Hymns: publish `catalog/production/hymnals.json` (repository index) and a takedown issue template in the bible-data repo; until then the official hymnal repository shows "could not load".
- `todo` Create the Google Cloud OAuth credentials (see `docs/google_sync_setup.md`) and run the first end-to-end Drive sync between two devices/platforms signed into the same account.
- `in_progress` Reader font picker needs on-device QA on Android: fling through installed fonts and confirm no `RenderViewport exceeded its maximum number of layout cycles` and no jank; also select verses in continuous mode to confirm the reader no longer resizes.
- `todo` Move the remaining hard-coded English in older reader, notes, reference-picker, settings, and advanced-settings screens into the ARB files (e.g. "Chapters", "Type", "Translation", "Export Translation Databases").
- `todo` Native-speaker review of the de/es/fr/zh strings added in the localization pass and the 91 Hymns strings (incl. the legal/takedown text).
- `in_progress` Personal annotations need widget-test coverage and manual QA across reader layouts after the reader presentation refactor.
- `in_progress` References screen navigation still deserves a regression pass after the new verse-selection bar landed in the reader.
- `in_progress` Reader presentation code is now organized into `reader_view/` and `reference_picker/`; behavior should now be regression-checked instead of adding more UI complexity blindly.
- `in_progress` The repo now follows an explicit MVVM-style feature layout with `application/view_models/` folders, but screens still need gradual cleanup so more orchestration moves out of large widget state classes over time.
- `todo` After regression coverage improves, do a second reader architecture pass to extract more standalone widgets/controllers from `_BibleTextViewState` instead of continuing to grow the state class through `part` extensions alone.
- `done` Personal notes and highlights now exist as a real user-data feature with dedicated models, repository/provider plumbing, additive Drift storage, a note editor, and a Notes screen.
- `done` The reader now has working verse-list and document modes with comprehensive span rendering: red-letter, emphasis/bold/italic, divine names, proper names, selah, acrostic headings, structured footnotes and cross-references with inline markers, and source-driven introductions/tables.
- `done` Parser/app pipeline preserves rich content: footnotes and cross-references now include spanIndex anchors; poetry/quote structure is consistent across all three formats with stanza groups and indentation; document-mode rendering reflects all preserved parser structures.
- `done` Bible caching is persistent on every platform: verified in a production web build that the translation database (drift `WebDatabase` on IndexedDB) survives a page reload.
- `done` Built-in, downloaded, and imported translations share one metadata-driven resolution path with user-facing removal for downloaded Bibles.
- `partial` Active app code is mostly organized under `lib/src/features/`, but some shared providers/services still sit outside that feature-first structure.

---

## Completed Recently

- `done` Hymns feature (branch `Hymnbooks-added`): 4th bottom tab with live search (number/title/words/author, quoted phrases, diacritics), number/A–Z sort, per-book favorites, phone list↔hymn view and wide two-pane view where results update while a hymn stays open; chorus after verse 1 with a setting for after every verse; copy/share/print (pdf+printing) always carry the copyright lines. Two accepted JSON formats (legacy bare array, and "hymnal" v1 with publisher/copyright `book` block). Bundled BHB is built reproducibly by `tool/hymnals/build_hymnal.dart` from source + overrides. File import (also on web), F-Droid-style Manage repositories with a required third-party disclaimer, takedown kill-switch (`withdrawn`), "Report a copyright concern" links and a Legal & takedown screen. Separate `hymnals.sqlite` drift store (no codegen, AppDatabase untouched); shared `fetchVerifiedHttps` now used by Bible downloads too; tab indexes are `HomeTabs` constants. Verified in a web build (Playwright) and `flutter build linux`. README reminder: list Hymns, hymn import and repositories as features.
- `done` Chapter bar no longer sits on the screen edge when scrolling hides the bars on phones: Scaffold strips the bottom safe area (gesture bar / home indicator) from its body whenever a bottom nav exists, even collapsed; `CollapsingBottomBarInset` (`lib/src/widgets/`) gives it back as the nav collapses. The reader absorbs it with a `SafeArea` around the text, so only that widget updates during the animation (a first version read it in the reader's build and rebuilt every verse ~14 times per bar animation; a test now guards this). Document-mode and home-screen width checks moved from `MediaQuery.of` to `MediaQuery.sizeOf`.
- `done` Continuous scrolling performance: a chapter finishing loading now rebuilds only that chapter (the reader used to re-render every visible chapter on each load, up to ~11 times per jump); a new chapter scrolling into view rebuilds only the chapter bar (`_visibleReference` notifier) instead of the whole reader; the per-frame viewport sync skips its work unless the visible chapter changed; chapters are preloaded 4 ahead of the scroll direction from the screen's leading edge instead of ±2 around the top chapter (scrolling down used to show loading placeholders while scrolling up was instant). Removed the controller's unused change notifications. Doubles as a split-view speed-up, since split view runs two readers. Not yet measured on device (`flutter run --profile`).
- `done` Split view availability: offered only in landscape or on screens 700px+ wide (`SplitReaderLayout.isAvailable`); on a phone held upright the button hides and split view hides until the phone turns back, without being turned off. In split view on the desktop app both readers open their screens in their own half; web and mobile open them full page.
- `done` Split view rebuilt (#84): the second pane is now the real reader (`BibleViewerTab`) in a child Riverpod scope instead of a 267-line simplified copy, so highlights, notes, verse details, continuous scrolling and the reader font work in both panes. Layout follows YouVersion: second pane left with its translation button lined up to the divider, a round play button (placeholder) beside each chapter pill. Split view starts off each launch, opens at the main reader's chapter, keeps the pane's place until relaunch (setting to always follow the main reader). In split view, screens a reader opens appear inside its own half on the desktop app and full page on mobile and web. Removed duplication: chapter stepping (×3 → `adjacentChapterReference`), span spacing (×3 → `needsSpaceBetweenSpans`), translation chip (×2 → `TranslationChip`). Works around a riverpod 3.0.3 scoping gap with an explicit provider list plus a guard test. See `reader/presentation/split_view/README.md`.
- `done` Merged `origin/test` (beta features batch + bug sweep) into the local font / line-spacing / translation-rights work. Duplicate implementations were unified: `BibleTranslationRights` keeps the status/notes/allowDownload model and gains `isEmpty`; the chapter-end copyright footer (#18) opens the Versions rights sheet; replacing a translation DB closes, deletes SQLite sidecars, then seeds; session-only translations are downloadable unless rights forbid it.
- `done` Localized the merged-in features (Bible search, split view, notes date/type filters, linked verses, settings, advanced export, front-matter `Read` tile, copyright footer, download notifications) and filled the 58 (zh: 63) untranslated keys, so de/es/fr/zh now cover every key in `app_en.arb`. Translations were machine-written and should get a native-speaker review.
- `done` Strong's-tagged words no longer get accent colour/weight unconditionally: colour, weight, and underline all follow one setting, renamed `Highlight Strong's Words` (off by default, same stored preference), in the reader and the verse details sheet.
- `done` Reader line spacing (closes #19): Compact/Normal/Relaxed/Loose presets in Bible viewer settings, persisted via `LineSpacingService` and applied as a multiplier on every reader line height (verse text, headings/intros, tables), so Normal matches the previous look. The settings sheet now opens at half height over a light scrim with the text controls on top (plus a live size readout) so changes can be judged on the reader behind it. README reminder: mention line spacing.
- `done` Reader font picker (Bible viewer settings → Font): System Default, bundled fonts in `assets/fonts/` (auto-detected, none shipped yet), imported .ttf/.otf files, and fonts installed on the device (Android/desktop; scanned off the UI thread). Split into `models/reader_font.dart`, `ReaderFontRepository` (choice/bundled/imports), `ReaderFontLoader` (deduped engine loads, queued + budgeted previews) and `DeviceFontScanner`; picker rows are fixed-extent to avoid layout-cycle errors; all strings localized (en/de/es/fr/zh). The continuous reader now only shrinks its viewport by the constant bar height, so selecting verses no longer resizes it. README reminder: mention custom reader fonts.

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

Status: `in_progress`

Scope:

- Translation caches already persist on web via drift's legacy `WebDatabase` + IndexedDB (verified across a reload). That API is deprecated; migrate to `package:drift/wasm.dart`.
- Verify imports survive reloads on web the same way they do on desktop/mobile.

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
