# Basic Bible App Todo Status

## Purpose
This file is the project execution tracker for `basic_bible`.

Use it to record:
- what has already been done
- what is currently in progress
- what should be done next
- what follow-up documentation must be updated

This file complements:
- `CONTEXT.md` for engineering context
- `README.md` for public-facing roadmap and feature status

## Operating Instructions
- Update this file whenever a meaningful engineering task starts or finishes.
- Before making code changes, add the task to this file with the intended status and the expected next step.
- After finishing the code changes, update this file again in the same work session to record what was completed, what changed, and what should happen next.
- Keep `Current Status` disciplined:
  - only list genuinely active or unresolved work
  - do not leave finished work there after verification
  - do not use it for broad product vision, backlog ideas, or repo history
- Keep `Completed Recently` disciplined:
  - move finished work there as soon as it is verified
  - write outcomes, not plans
  - trim or collapse older entries when the section stops being useful to scan
- Keep `Recommended Next Step` disciplined:
  - name one immediate next slice only
  - do not list multiple parallel priorities there
  - replace it when the active priority changes
- Add short comments to new or changed code when the intent, tradeoff, or reason for the approach would not be obvious to another developer or future agent.
- Do not add comment noise to self-explanatory code. Prefer a few high-value comments over many low-value ones.
- After a meaningful unit of work is complete and verified, create a commit with a clear message that describes the actual change.
- Do not bundle unrelated changes into the same commit if they can reasonably be separated.
- Keep statuses honest. Prefer repo truth over plans or assumptions.
- When a task changes user-visible behavior, add or update a `README.md reminder`.
- When a task is fully done, move it to `Completed Recently` and pick the next highest-value item for `Recommended Next Step`.
- If a task is blocked, say exactly what is blocking it.
- If the recommendation changes, update this file first so the next engineer or agent can continue cleanly.
- If a line in `Current Status` survives more than a few work sessions, either:
  - rewrite it as a precise unresolved problem
  - move it to backlog/roadmap sections
  - or remove it if it is already covered elsewhere

Status meanings:
- `done`: implemented and verified in the current repo
- `in_progress`: actively being worked or partially landed
- `next`: recommended immediate follow-up
- `todo`: valuable but not the immediate next task
- `blocked`: cannot move safely without another prerequisite or decision

## Completed Recently
- `done` Made app startup configurable by adding persisted settings for opening directly on the Bible tab and for disabling the dummy login gate, then wired those settings through startup prefs bootstrap, routing, the home shell, Settings, and the Menu tab so the behavior is no longer hardcoded.
- `done` Added shell-level Bible warm-up so the current translation now starts loading in the background from the main app shell before the reader tab is opened, which is the preferred path before introducing a dedicated startup loading screen.
- `done` Corrected reader book-name fallback for cases like the `WEB` preface so placeholder names such as `Unknown` no longer outrank real TOC/display labels that the source already provides.
- `done` Refreshed the public app README so it now reflects the shipped reader modes, versions screen, reference picker, theme options, translation handling, and the current partial-vs-finished feature boundaries more accurately.
- `done` Tightened Bible load performance again by removing extra translation-metadata and cache-existence lookups from the cached local load path, and by starting translation switches immediately instead of deferring the next Bible load through an extra event-loop turn.
- `done` Removed `Show Introductions` from the quick Bible viewer settings sheet so that toggle now lives only in the full Settings page instead of being duplicated across both settings surfaces.
- `done` Added a softer built-in-style `Soft Dark` theme option alongside `Pure Black`, and wired it into both Settings and the quick reader theme picker so users can keep a dark UI without losing selected switches, chips, and other controls against fully black surfaces.
- `done` Tuned the monochrome theme contrast so pure black mode now uses stronger variant/outline colors, visible text-button defaults, and clearer settings chips instead of letting several controls disappear into black surfaces.
- `done` Tightened the References screen chapter grid to a smaller verse-style size and removed the hardcoded canonical-name display fallback from the reader/reference labels so unresolved book IDs now show a readable source-derived label instead of bad `Unknown`-style output.
- `done` Expanded the theme system so system dark mode now uses a true black theme, and added explicit `Pure Black` and `Pure White` theme choices to both Settings and the quick reader theme picker.
- `done` Moved the reader chapter/reference bar to the bottom on every screen size, switched the wider layouts off the old top-mounted placement, and rebalanced the reader padding so content clears the bottom floating bar instead of leaving a fake top gap.
- `done` Improved the Bible viewer overflow menu contrast by forcing the dropdown item icons to use the popup's high-contrast `onSurface` color instead of inheriting a dimmer default tint.
- `done` Unified the References screen picker tiles so chapter picks now use the same square size, spacing, radius, and selected styling as the verse picks instead of rendering as a larger older-looking grid.
- `done` Optimized Bible viewer loading by keeping previously opened translations hot in memory, stopping the reader books provider from recreating itself on every translation change, and switching the continuous whole-Bible reader to a lazy builder with coalesced visible-chapter syncing instead of rebuilding the full section list on every update.
- `done` Moved the reference picker onto its own full-screen References screen, kept the search/AZ/history controls there, and changed the picker so only one book expands into chapter choices at a time instead of showing every chapter grid at once.
- `done` Cleaned up the Versions screen so selecting a translation now switches quietly without a success snackbar, and locally available translations render a check-state chip instead of a misleading download icon.
- `done` Rebuilt the reference picker around a single searchable book/chapter flow with canonical-vs-alphabetical ordering, added a history button for recently visited references, and moved verse-selection control into the main Settings page so the quick reader sheet does not own that option.
- `done` Hardened reader book-name fallback so unresolved source IDs now resolve to real display labels or readable normalized names instead of bad `Unknown`-style output, and filtered empty book/document labels out of the picker and reader sections so blank entries no longer render.
- `done` Removed the ripple/ink effect from the small-screen bottom navigation so tab switches now feel immediate without the default Material splash animation.
- `done` Corrected the reader intro toggle so it now controls book introduction/front-matter blocks instead of chapter headers, removed the extra TOC-label description line from the introduction card, and limited those introduction blocks to chapter 1 instead of repeating them across later chapters.
- `done` Fixed continuous-mode reference selection so picked book/chapter/verse jumps now stay targeted to the selected spot instead of being overridden by a follow-up chapter-top scroll, and tightened the chapter-header layout so section headers stay visually centered in the whole-Bible reader.
- `done` Cleaned up reader book-label fallback and introduction presentation so unknown-book cases can now match against parsed TOC labels, the repeated third-line display label was removed from chapter headers, and that secondary label now appears in the introduction section instead when it is useful.
- `done` Widened continuous mode into a whole-Bible lazy section list instead of a current-book-only reader, so the reference bar can now follow both book and chapter across the loaded translation while chapter jumps and section headers continue to work in one continuous scroll surface.
- `done` Reworked continuous scrolling so the reader now renders the full current book, keeps chapter headers formatted consistently across sections, keeps chapter 1 introductions visible in the continuous view, updates the reference bar from the visible chapter while scrolling, and makes the chapter arrows jump between chapter sections instead of acting like disconnected pagination controls.
- `done` Changed the reader translation pill to show the translation abbreviation instead of the full translation name, which keeps the top-bar control compact and readable on mobile.
- `done` Fixed the reader reference-bar regression after translation switches by resolving book references more flexibly, falling back to readable book names instead of `Unknown`, and moving the floating chapter bar above the reader content so its background renders as a real visible surface again.
- `done` Added a first dedicated `Versions` screen for translation selection, wired the reader translation pill to open it, added simple row action buttons for future library features, and added an `Import Bible XML` entry to the top-right menu there.
- `done` Strengthened the small-screen floating reference bar background so it now reads as a real pill control with visible fill, border, and shadow instead of blending into the reading surface.
- `done` Restyled the small-screen chapter/reference bar so the scrolled reader now uses a flatter floating pill reference control with centered book-chapter text, matching the current prototype direction more closely.
- `done` Improved Bible load performance by keeping the active translation hot in memory and replacing the old nested cached-Bible rebuild queries with bulk book/chapter/verse fetches.
- `done` Added a persisted `Continuous Scrolling` reader mode and cleaned the chapter header so the viewer now shows only the chapter number on the second line instead of repeating the book name there.
- `done` Added explicit back navigation to unfinished routed pages so placeholder screens, settings, and other non-tab pages can always return to the previous screen or fall back to `/home` instead of trapping the user in a dead-end route.
- `done` Consolidated the Bible viewer top-bar controls behind a reader-specific overflow menu and settings sheet, so `Fonts & Settings` now opens a dedicated Bible viewer settings surface with font-size controls, reader mode toggle, theme selection, and an `All Settings` handoff.
- `done` Replaced the boxed selected-verse highlight with a softer temporary focus state: the chosen verse now stays visually emphasized without a background box until the user touches the screen to scroll.
- `done` Hardened reader reference fallback so switching to a translation that does not contain the previously saved book/chapter no longer throws `Bad state: No element`; the reader now falls back safely to the first available matching content.
- `done` Fixed bundled translation resolution so built-in entries like ASV always keep their shipped asset fallback even when stored lifecycle metadata exists, instead of accidentally behaving like remote-only translations.
- `done` Hardened the verse-detail popup preview so note letters stay visible there: anchored markers now render with stronger superscript styling, and the sheet falls back to its annotation-entry letters when a verse does not carry anchor metadata.
- `done` Fixed stale cached translations that were hiding inline annotation letters by rebuilding older local Bible copies when they predate the newer per-span anchor metadata.
- `done` Fixed the verse-detail popup preview so inline note/reference letters now render beside their anchored words there too, instead of being appended at the end of the verse text.
- `done` Added inline annotation anchors so note/reference markers can now render beside the words they attach to when the parser preserves those anchors, instead of only appearing in a verse-level sheet.
- `done` Polished document-mode paragraph rendering so prose sections read more like real paragraphs and annotation buttons stay available there instead of disappearing outside verse-list mode.
- `done` Reworked verse annotation interaction so side icons open a more reference-app-like bottom sheet with verse context and lettered annotation rows instead of relying on tapping the whole verse for a generic details panel.
- `done` Improved front-matter and section-layout rendering so introductions, headings, and other non-verse blocks now read like intentional document sections instead of plain parser output appended between verses.
- `done` Improved document-mode fidelity so poetry-style paragraph starts and source-driven line breaks from the parser now render more like the source document instead of being merged back into one prose block.
- `done` Rewrote `README.md` so it now reflects the real app status, shipped reader capabilities, current parser support, and active development gaps instead of acting only as an old wish-list snapshot.
- `done` Reorganized the active app paths around feature folders so auth, home shell, reader, library data, menu, and settings code now live under `lib/src/features/` instead of being split across generic provider/view/repository roots.
- `done` Cleaned up downloaded-translation lifecycle handling so stored metadata now overrides built-in defaults when a bundled translation has been downloaded, and the picker reflects whether a translation is bundled, downloaded, or imported.
- `done` Clarified reader-mode behavior so one mode stays fully verse-listed and the other now follows the parsed document structure more literally instead of forcing all source content into paragraph-style prose.
- `done` Improved the verse-detail note/reference UX by grouping annotation content into clearer cards and action chips so heavily annotated verses no longer fall back to a very plain stacked list.
- `done` Finished translation asset lookup cleanup by removing filename-guess fallback logic and unifying built-in/imported translation resolution through explicit metadata.
- `done` Added explicit local Bible import flows so users can pick USFX, OSIS, or Zefania XML files, store them as managed local translations, and reopen them from the translation picker on later launches.
- `done` Finished structured cross-reference navigation so verse-detail taps now use parser-provided targets like `JHN.1.1` directly and only fall back to label parsing when no structured target is available.
- `done` Brought OSIS and Zefania onto the same structured paragraph-block path as USFX so all supported formats can drive paragraph mode from parsed document markers instead of app-side guessing.
- `done` Switched paragraph mode from a UI-only "join the whole chapter" fallback to document-driven grouping by preserving chapter paragraph markers from the source content and rendering multiple paragraph sections in the reader.
- `done` Confirmed that the first paragraph-mode implementation was app-driven instead of source-driven, and identified the missing piece: in-chapter paragraph markers were not being preserved from the source documents.
- `done` Fixed rich-span display spacing for tag-heavy sources like KJV and added a persisted reader layout mode so users can switch between verse-list and paragraph reading.
- `done` Restored chapter/verse picking flow by adding verse selection to the reference picker and making the reader scroll to and highlight a selected verse.
- `done` Rendered structured book/chapter document blocks in the reader and replaced the old verse tap fallback with a richer bottom sheet for footnotes and cross-references.
- `done` Brought the Zefania parser up to the same shared rich-model direction as the other supported formats, including structured introduction blocks, chapter headings, notes, references, and styled verse spans.
- `done` Completed the first end-to-end rich-text slice: the reader now renders structured verse spans and the parser/app pipeline preserves those spans through local storage.
- `done` Normalized app-side book IDs to the uppercase form the reader/navigation code already expects, which keeps parsed content aligned with the app's existing reference model.
- `done` Carried the richer parser output through `basic_bible` so book/chapter/verse metadata now survives repository mapping and local Drift storage instead of being flattened away.
- `done` Began Phase 1 parser behavior work by updating the USFX parser to populate structured footnotes, cross-references, TOC labels, and introduction/front-matter blocks.
- `done` Started Phase 1 implementation by adding shared rich-content model types in both `bible_parser_flutter` and `basic_bible`.
- `done` Added app-side model support for structured verse spans, footnotes, cross-references, TOC labels, and document blocks while keeping plain-text verse support intact.
- `done` Added `CONTEXT.md` to document the current app architecture, product state, and implementation caveats.
- `done` Reviewed the local `bible_parser_flutter` package and documented its current capabilities and gaps.
- `done` Added parser-side docs and tracking files in `bible_parser_flutter` for footnotes, red-letter text, and richer Bible XML support.
- `done` Identified two high-impact technical issues in the app:
  - Bible asset filenames do not match the app's translation ID lookup pattern.
  - The current Drift database uses in-memory storage and does not persist across restarts.
- `done` Replaced the in-memory Drift connection with a file-backed SQLite database for non-web platforms.
- `done` Added translation metadata persistence so cached Bibles are tracked as local stored data instead of only temporary parsed content.
- `done` Updated local translation definitions to use explicit asset paths for bundled USFX and OSIS files.
- `done` Added a real `/coming-soon/:feature` placeholder route so menu entries no longer point at missing screens.
- `done` Quarantined legacy todo experiment files under `lib/legacy/` instead of leaving them mixed into the main app root.
- `done` Renamed active Bible viewer widget files to clearer snake_case paths and moved the old backup widget into `lib/legacy/`.
- `done` Cleaned up remaining analyzer issues after the structural cleanup. `flutter analyze` now passes with no issues.

## Current Status
- `in_progress` The References screen chapter tiles are being tightened again because they still take up too much room compared with the smaller verse-picker tiles the reader is already using elsewhere.
- `in_progress` Continuous scrolling still needs a focused regression check because interacting with the reference bar or reference selector does not always keep the whole-Bible scroller and visible position in sync.
- `in_progress` The reader now has working verse-list and document modes, structured note popups, inline annotation markers, and source-driven paragraph support, but document-mode fidelity is still limited by the parser structure that survives import.
- `in_progress` The parser/app pipeline now preserves partial rich content across USFX, OSIS, and Zefania, but many non-verse layout cases and source-specific tags are still normalized too aggressively before the reader sees them.
- `in_progress` Non-web Bible caching is persistent, but the web path still falls back to in-memory storage.
- `in_progress` Built-in, downloaded, and imported translations now share one metadata-driven resolution path, but broader translation-library management is still unfinished.
- `in_progress` The active app code is mostly organized under `lib/src/features/`, but some shared providers/services and placeholder routes still sit outside that feature-first structure.

## Recommended Next Step
- `next` Return to parser-side layout fidelity work so more front-matter and section tags survive into the reader instead of being normalized away too early.

Why this is next:
- The visible translation-switch regression is fixed, and the biggest remaining prototype gap is still formatting fidelity.
- The reader can only render what the parser preserves, so upstream structure is still the highest-value source of visible improvement.

Definition of done for this step:
- More front-matter and section-layout tags from USFX, OSIS, and Zefania are preserved in the shared parser model.
- The app can distinguish more layout cases without guessing from plain text.
- Reader rendering quality improves because the parser is providing richer structure, not because the UI is hardcoding more heuristics.

## Prioritized Backlog

### 1. Persist Bible storage to disk
Status: `done`

Scope:
- Replace `NativeDatabase.memory()` with a file-backed database location.
- Verify the app opens the same DB across launches.
- Confirm the repository/database APIs still work for existing Bible data loads.

README.md reminder:
- Update the README when offline persistence actually works, not before.

### 2. Expand translation import and metadata tracking
Status: `done`

Scope:
- Support explicit import flows for local USFX, OSIS, and Zefania files.
- Persist source metadata for each imported translation.
- Keep the normalized local database as the runtime storage layer.

Why it matters:
- This is the senior-developer path from "temporary parser output" to "real managed local Bible library".

README.md reminder:
- Update the README when local Bible import becomes a real user-facing feature.

### 3. Fix translation asset lookup
Status: `done`

Scope:
- Align translation IDs with bundled asset names, or add explicit asset-path metadata per translation.
- Ensure local assets are preferred when available.

Why it matters:
- The app should not miss bundled Bibles because of filename mismatch.

README.md reminder:
- Update the README if local bundled translations become a stable supported feature.

### 4. Add structured Bible metadata support
Status: `in_progress`

Scope:
- Start with structured footnotes and red-letter text.
- Then add cross-references, poetry/quote blocks, word metadata, and translator additions.
- Keep plain verse text for search and simple rendering.

Dependency:
- This depends on stable local persistence and model/schema changes.

Implementation note:
- The parser and app should preserve structured verse content such as spans, notes, references, and formatting metadata instead of saving only one flattened `text` string.
- Use plain text for search and simple fallback rendering, but keep structured data for real display features.
- Introductions and front matter should be treated as first-class parsed content too, not discarded as non-verse text.
- The long-term direction is format fidelity: preserve as much meaningful structure from USFX, OSIS, and Zefania as the app can model and render safely.

README.md reminder:
- Update the README when the app can actually display footnotes or red-letter text in the UI.

### 5. Support introductions and front matter
Status: `in_progress`

Scope:
- Preserve Bible-level and book-level introductions from USFX, OSIS, and Zefania where available.
- Preserve TOC labels, headings, prefaces, and other non-verse front matter instead of dropping them during parsing.
- Make this data available to the app as structured content, not just raw XML.

Why it matters:
- Some Bible files include a preface, book introductions, canonical titles, and navigation labels that are useful in a real Bible app.
- Right now the parser model only exposes books, chapters, and verses, so that content is being lost.

Implementation note:
- The parser already exposes the list of books through `BibleParser.books`.
- The missing part is preserving introduction/front-matter content alongside those books.
- Book-level introduction blocks do now render in the reader, but Bible-level front matter is still only partial because the current app import path is centered on books/chapters/verses rather than a first-class top-level document object.

README.md reminder:
- Update the README when introductions or front matter become visible in the app UI.
### 6. Close route / menu placeholder gaps
Status: `done`

Scope:
- Either register menu destinations or temporarily disable dead navigation targets.
- Reduce mismatch between visible menu options and real routes.

README.md reminder:
- Update the README when a placeholder feature becomes a real screen.

### 7. Clean up legacy app structure
Status: `done`

Scope:
- Audit root-level `lib/` files that sit outside `lib/src/`.
- Decide whether they should be deleted, migrated, or clearly marked legacy.

Why it matters:
- Reduces confusion for future work.

README.md reminder:
- No README update required for this internal cleanup unless you decide to document the new project structure.

### 8. Reorganize toward feature-first modules
Status: `done`

Scope:
- Group Bible import, Bible library/storage, reader UI, auth, and settings into clearer feature boundaries.
- Reduce cross-folder mixing between models, providers, services, repositories, and views where a feature module would be clearer.
- Keep `lib/src/` as the main app root and `lib/legacy/` as non-active code.

Why it matters:
- This is the remaining gap between "cleaned up learning project" and "lead-level maintainable app structure."

README.md reminder:
- Update the README only if you want to document the architectural layout for contributors.

### 9. Full format-fidelity support across USFX, OSIS, and Zefania
Status: `todo`

Scope:
- Preserve meaningful non-verse and inline structure from all supported source formats instead of flattening most content into plain verse strings.
- Expand the parser/app model to cover introductions, front matter, headings, notes, references, poetry, quote levels, red-letter text, translator additions, and word-level metadata.
- Accept that some source-specific tags may still need normalization into shared app concepts instead of being exposed 1:1.

Why it matters:
- This is the path from "basic Bible reader" to "real Bible library and study app."
- It prevents losing data during import and keeps future reader features possible.

Implementation note:
- This is a multi-phase program, not a single task.
- The senior-developer approach is to define a shared canonical model first, then teach each parser format to map into it incrementally.

README.md reminder:
- Update the README only when major fidelity features are actually user-visible, not when the backlog item is created.

## Remaining Work, Written Out

### App: What is still left to add

#### A. Finish reader document-mode fidelity
What still needs to happen:
- Render more parser-provided block types differently instead of treating many of them as generic headings or generic paragraphs.
- Preserve more source-driven spacing, section breaks, poetry layout, and front-matter layout in the actual UI.
- Reduce app-side guessing where the parser already knows something more specific.

What "done" should mean:
- `Document` mode feels like it is following the source file structure, not rebuilding the chapter from generic text blocks.
- Poetry, headings, intros, and prose sections each render with their own clearer visual treatment.

#### B. Finish front matter and introduction rendering
What still needs to happen:
- Show book-level introductions more intentionally.
- Support Bible-level front matter once the parser exposes it more clearly.
- Render TOC labels, prefaces, intros, and non-verse content in a way that feels like real reading content instead of technical parser output.

What "done" should mean:
- Front matter is visible, readable, and clearly separated from normal verse flow.
- The app can present book intros and prefaces as part of the reading experience.

#### C. Finish structured footnote UX
What still needs to happen:
- Improve the note sheet so it reflects parser structure more faithfully.
- Preserve annotation order and grouping as the source intended.
- Show note markers more clearly in verse text, document mode, and the popup preview.
- Reduce fallback logic that invents marker ordering when real parser data exists.

What "done" should mean:
- Footnotes feel anchored, readable, and consistent between the verse view and the bottom sheet.
- The app is using structured note data first, not plain-text fallback first.

#### D. Finish structured cross-reference UX
What still needs to happen:
- Improve how cross-references are presented when many exist on one verse.
- Keep direct navigation using structured targets.
- Optionally show destination context or grouped reference sections later.

What "done" should mean:
- Cross-references are easy to scan and navigate without relying on fragile label parsing.

#### E. Finish inline annotation marker fidelity
What still needs to happen:
- Keep note/reference letters positioned more faithfully in both verse-list mode and document mode.
- Ensure popup previews use the same anchor logic as the main reader.
- Reduce cases where marker placement still depends on fallback ordering rather than true parser anchor data.

What "done" should mean:
- Inline markers appear beside the correct words consistently enough for prototyping and design work.

#### F. Finish startup and background warm-up behavior
What still needs to happen:
- Preload the current Bible from the app shell before the user opens the reader whenever possible.
- Confirm that tab switches, translation switches, and fresh app launches all benefit from that warm-up path.
- Only add a dedicated startup loading screen if background warm-up still is not enough to hide the initial reader load well.

What "done" should mean:
- Opening the Bible tab usually feels instant for already-cached translations.
- A dedicated startup warm-up screen is only needed, and only added, if background preload is still not enough.

#### G. Finish richer reader styling support
What still needs to happen:
- Improve how the app visually distinguishes:
  - red-letter text
  - translator additions
  - poetry
  - headings
  - introductions
  - note markers
- Keep styling driven by data, not by translation-specific heuristics.

What "done" should mean:
- Rich parser output is visible in the UI as distinct reading styles, not only as preserved metadata in storage.

#### H. Finish translation-library management
What still needs to happen:
- Improve lifecycle handling for bundled, downloaded, and imported translations.
- Add clearer user-facing status for what is installed locally and what came from import/download.
- Make stale-cache refresh and translation replacement behavior more intentional and visible.
- Preserve the same logical book/chapter more explicitly across translation switches even when different source files expose different book ID styles.
- Add a real `Versions` screen instead of relying only on the current picker flow.
- Support grouped library sections such as:
  - downloaded
  - available by language
  - failed downloads
  - imported/local files
- Add search, language filtering, and clearer per-translation actions.
- Show clearer status icons for:
  - available online
  - downloaded locally
  - audio availability
  - failed download / retry state

What "done" should mean:
- The translation picker behaves like a real library manager instead of a thin list of IDs.
- Users can browse, search, filter, download, retry, and manage translations from a dedicated screen that matches the intended library UX more closely.
- Translation switches preserve the same logical reading location intentionally, not only through tolerant fallback matching.

#### I. Add online-only translation access
What still needs to happen:
- Decide whether remote translations should support a true "use online without downloading" mode.
- Add explicit user choice between:
  - download for offline/local use
  - stream/view online without keeping a full local copy
- Keep the local-library path for users who do want offline storage.
- Make it obvious in the UI which translations are:
  - installed locally
  - available online only
  - temporarily streaming
- Decide how reading state, caching, and failure/retry behavior should work when the user chooses online-only access.

What "done" should mean:
- Users are not forced to download a translation just to preview or read it over the internet.
- The app clearly distinguishes local-library behavior from online-only viewing behavior.

#### J. Finish web storage behavior
What still needs to happen:
- Replace the current in-memory web fallback with a real persistent web storage path, if feasible for the chosen stack.
- Verify imports and cached translations survive reloads on web the same way they do on desktop/mobile.

What "done" should mean:
- Web no longer loses all cached Bible content on reload.

#### K. Finish remaining architecture cleanup
What still needs to happen:
- Move or clarify the remaining shared services/providers that still sit outside the feature-first structure.
- Keep placeholder/legacy paths from slowly becoming active app paths again.
- Continue tightening ownership boundaries between library, parser integration, and reader presentation.

What "done" should mean:
- The active app structure is consistently feature-first and easier for other developers or agents to extend safely.

#### K. Finish README and public-facing docs as features land
What still needs to happen:
- Keep `README.md` aligned with real user-visible behavior.
- Update docs when front matter, richer notes, or other fidelity features become clearly usable in the UI.

What "done" should mean:
- The project docs describe the actual app, not the intended app.

### App: Recommended remaining implementation order
1. Finish document-mode fidelity and front-matter rendering.
2. Finish footnote and cross-reference UX using the structured parser data more faithfully.
3. Finish inline marker fidelity and rich reader styling polish.
4. Build the real translation-library / `Versions` screen and decide online-only vs download behavior.
5. Finish translation-library management and web persistence.
6. Finish remaining architecture/doc cleanup once the formatting prototype is stable.

## Blockers / Risks
- `blocked` Rich parser features cannot be implemented cleanly in the app without expanding the current verse/data model.
- `blocked` Storage work must be done carefully because DB/schema changes can ripple into repository logic and future migration handling.

## README.md Reminder
- Keep `README.md` aligned with actual repo state.
- Do not mark features as done in `README.md` until the behavior is implemented and verified in the app.
- After any major task closes, check whether `README.md` needs:
  - updated feature checkboxes
  - updated current capabilities
  - clarified limitations
  - links to new internal docs such as `CONTEXT.md` or this file if useful

## Update Template
Use this pattern when editing the tracker:

1. Before coding, add the planned task to `Current Status`, `Recommended Next Step`, or the backlog as appropriate.
2. Do the implementation work.
3. Move finished work into `Completed Recently`.
4. Update `Current Status` to reflect repo reality.
5. Add targeted comments to the changed code if future readers would otherwise have to reverse-engineer intent.
6. Run verification that matches the scope of the change.
7. Create a commit with a focused message if the work is in a good state.
8. Replace `Recommended Next Step` if priorities changed.
9. Add or revise the matching `README.md reminder`.
10. Keep backlog ordered by actual engineering value, not by wish list order.
