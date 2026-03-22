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
- Add short comments to new or changed code when the intent, tradeoff, or reason for the approach would not be obvious to another developer or future agent.
- Do not add comment noise to self-explanatory code. Prefer a few high-value comments over many low-value ones.
- After a meaningful unit of work is complete and verified, create a commit with a clear message that describes the actual change.
- Do not bundle unrelated changes into the same commit if they can reasonably be separated.
- Keep statuses honest. Prefer repo truth over plans or assumptions.
- When a task changes user-visible behavior, add or update a `README.md reminder`.
- When a task is fully done, move it to `Completed Recently` and pick the next highest-value item for `Recommended Next Step`.
- If a task is blocked, say exactly what is blocking it.
- If the recommendation changes, update this file first so the next engineer or agent can continue cleanly.

Status meanings:
- `done`: implemented and verified in the current repo
- `in_progress`: actively being worked or partially landed
- `next`: recommended immediate follow-up
- `todo`: valuable but not the immediate next task
- `blocked`: cannot move safely without another prerequisite or decision

## Completed Recently
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
- `in_progress` The project now persists cached Bible data on disk for non-web platforms, but the web path still falls back to in-memory storage.
- `in_progress` The app now renders rich verse spans end to end for the parser output it receives, including red-letter text, translator additions, some poetry/word metadata styling, and structured intro/heading blocks, but the note/reference UX can still be polished further.
- `in_progress` The README is currently more of a feature wish list than a maintained reflection of actual repo status.
- `in_progress` The app structure is cleaner, but the codebase is still not fully feature-sliced. Bible import, library management, reader UI, and settings are still spread across shared folders rather than organized as strict feature modules.
- `in_progress` The project now has a plain-language documentation note explaining that Bible formatting support must preserve structure, not only flattened verse text.
- `in_progress` The current parser model is still limited to books, chapters, and verses. It does not yet preserve introductions, prefaces, TOC labels, or book-level front matter that already exists in some USFX and OSIS files.
- `in_progress` The long-term product goal is full-fidelity support for the Bible source formats in use, which means preserving as much meaningful USFX, OSIS, and Zefania structure as is practical instead of only rendering simplified verse text.
- `in_progress` Phase 1 parser/app-model planning is being documented so future implementation work starts from a shared spec instead of ad hoc parser changes.
- `in_progress` Phase 1 shared-model implementation is now real across USFX, OSIS, and Zefania at a partial-rich level, and the reader now renders intro/heading blocks, but better structured note/reference navigation still needs polish.
- `in_progress` Reader rendering now uses the structured parser output for intro blocks and richer verse details, but there is still room to improve the presentation and navigation flow around those details.

## Recommended Next Step
- `next` Polish the reader UX around structured notes and references, especially direct navigation from structured targets and clearer presentation for verse details in longer passages.

Why this is next:
- The parser and storage path now produce and preserve richer verse data.
- The reader now uses structured spans instead of flattening everything back to `verse.text`.
- The next biggest user-visible gap is navigation and presentation quality inside the new verse-detail UI.

Definition of done for this step:
- Structured cross-reference targets can be used more directly instead of relying mostly on label parsing.
- Verse-detail UI remains readable when many notes/references exist.
- Existing reading and navigation still work.

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
Status: `next`

Scope:
- Support explicit import flows for local USFX, OSIS, and Zefania files.
- Persist source metadata for each imported translation.
- Keep the normalized local database as the runtime storage layer.

Why it matters:
- This is the senior-developer path from "temporary parser output" to "real managed local Bible library".

README.md reminder:
- Update the README when local Bible import becomes a real user-facing feature.

### 3. Fix translation asset lookup
Status: `in_progress`

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
Status: `todo`

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
