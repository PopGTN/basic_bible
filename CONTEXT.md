# Basic Bible App Context

## Purpose
This repository contains a Flutter Bible app that serves two roles:

- It is a simple Bible-reading app.
- It is also a learning project that the maintainer is using to build toward a future, larger Bible app.

`README.md` is the public-facing roadmap and feature checklist. This file is the engineering context document for future coding agents and maintainers who need to understand the current codebase quickly.

Use `TODO_STATUS.md` beside this file as the execution tracker:
- record what was completed
- record what is in progress
- record the next recommended engineering step
- add a reminder whenever `README.md` should be updated to match repo reality

## Current Product State
- The core implemented feature is Bible reading.
- Bible content is bundled in `assets/bible/` and can also be fetched from GitHub-defined translation URLs.
- The app has translation selection for Bible data with `kjv`, `asv`, and `web` currently defined in code.
- UI scaffolding exists for authentication, settings, themes, language selection, and menu-driven feature areas.
- Personal notes/highlights now exist as a separate user-data feature with a reader selection bar, note editor, and Notes screen.
- Several non-reader features are still placeholders, "coming soon" destinations, or partially scaffolded.
- Localization support exists in code/assets for English, French, Spanish, German, and Chinese.

## Architecture Overview

### App bootstrap
- `lib/main.dart` initializes Flutter bindings, sets up database factory behavior for web and desktop, configures desktop window sizing, and launches the app inside a `ProviderScope`.

### App shell and routing
- `lib/src/app.dart` is the main app entry inside Flutter.
- It wires Riverpod state into:
  - `GoRouter` auth-aware navigation
  - theme selection
  - locale selection
- Current registered routes are:
  - `/`
  - `/login`
  - `/home`
  - `/home/other`
  - `/home/settings`

### Main UI structure
- `lib/src/views/home/home_screen.dart` is the main authenticated shell.
- It provides a responsive layout:
  - bottom navigation on smaller screens
  - `NavigationRail` on wider screens
- The three primary tabs are:
  - Home
  - Bible
  - Menu
- The Bible tab also owns the app-bar actions for search/audio placeholders, translation selection, and Bible text size selection.

### Reader presentation structure
- The reader presentation layer now uses a coordinator-plus-parts layout instead of keeping the full screen implementation in one giant file.
- The reader presentation layer is now organized into subfolders by responsibility:
  - `lib/src/features/reader/presentation/reader_view/`
  - `lib/src/features/reader/presentation/reference_picker/`
- Each of those folders now also has a small local `README.md` so maintainers can quickly see file ownership without reconstructing it from imports and part directives.
- `reader_view/bible_viewer_tab.dart` is now the coordinating screen/state entry.
- Heavy reader responsibilities are split into focused part files under `reader_view/` for:
  - core state and selection behavior
  - rendering orchestration
  - document-mode rendering
  - annotation-sheet / span helpers
  - extracted widget sections
- The outer reader shell file was also cleaned up so the chapter-bar behavior and verse-selection actions now route through named methods instead of one large callback-heavy build block.
- The outer reader shell now uses a small snapshot model for watched state so `bible_viewer_tab.dart` reads more like screen composition and less like one long provider/spacing calculation block.
- Shared verse-card and chapter-support rendering now flow through common helpers in the reader rendering layer instead of maintaining separate near-duplicate implementations for current-chapter and continuous-chapter paths.
- The reference-picker UI lives under `reference_picker/` so:
  - `reference_picker/chapter_bar.dart` owns the chapter bar
  - `reference_picker/reference_picker_screen.dart` owns the main picker screen
  - `reference_picker/reference_screen.dart` owns the separate references screen
  - `reference_picker/reference_bar.dart` is a barrel export for shared picker entry points

This split is a structural maintenance improvement, not a feature change. Treat the current priority as regression confidence, not more reader-surface expansion.

### Bible state and loading
- `lib/src/providers/bible_provider.dart` contains the main Bible-reading state.
- It manages:
  - the selected translation
  - the current Bible reference
  - async loading of parsed Bible books
- Translation and reference state are persisted with `SharedPreferences`.
- Bible content loading is exposed through Riverpod state notifiers and `AsyncValue`.

### Bible repository and parsing
- `lib/src/repositories/app_bible_repository.dart` is the main repository for Bible data.
- It can:
  - load Bible content from bundled assets
  - download Bible content from GitHub
  - parse Bible files with `bible_parser_flutter`
  - cache parsed data through the app database layer
- Parsing is offloaded with `compute(...)` so large Bible files do not block the UI thread.

### Database layer
- `lib/src/services/app_database.dart` defines the Drift-backed storage layer.
- It stores parsed Bible data as books, chapters, and verses.
- The repository reads from and writes to this layer for caching-oriented workflows.
- It also stores personal annotations in dedicated user-annotation tables separate from parser-originated footnotes/references.

### Personal annotations
- The personal annotations feature lives under `lib/src/features/annotations/`.
- It is intentionally separate from parser-provided footnotes and cross-references.
- The current model supports:
  - standalone highlights
  - standalone notes
  - notes with connected highlight colors
  - extra linked verses with saved translation metadata
- The first version is whole-verse only; partial-verse anchors are future work.

## Important Implementation Caveats

### Translation asset lookup mismatch
- The repository looks for local files using patterns like `assets/bible/$translationId.$ext`.
- Current bundled files use names such as:
  - `eng-kjv2006_usfx.xml`
  - `eng-web.usfx.xml`
  - `asv_osis.xml`
- Because the IDs in code are `kjv`, `web`, and `asv`, local lookup may miss bundled assets and fall back to download behavior.

### Web storage still falls back to memory
- Non-web platforms use a file-backed SQLite path.
- Web still falls back to in-memory storage.
- This means Bible cache and personal annotations do not survive browser reloads yet.

### Menu routes outpace registered routes
- Most placeholder menu routes still go through `/coming-soon/...`.
- `Notes` is now a real route and should be treated as a live feature, not a placeholder.
- Future navigation work should verify route registration before assuming a destination exists.

### Mixed old and new code structure
- The main app architecture lives under `lib/src/`.
- There is also older or non-core code in root-level files such as:
  - `lib/TodoModal.dart`
  - `lib/providerTodo.dart`
  - `lib/todo_repository.dart`
- Treat these as legacy or unrelated unless a task clearly requires them.

## Preferred Working Model
- Treat `lib/src/` as the primary application code.
- Use `README.md` for roadmap intent, but validate current behavior against the actual code before making changes.
- Verify route, provider, and storage assumptions before extending features.
- Keep the app functioning as a simple Bible reader first; add roadmap features in layers rather than assuming the scaffolding is already complete.
- When touching Bible loading or caching, check both the translation ID flow and the real persistence behavior.
- When touching notes/highlights, keep personal annotations separate from parser content at every layer.
- When touching the reader, prefer extending the split presentation files by responsibility instead of growing `bible_viewer_tab.dart` back into a giant mixed-responsibility file.
- When re-entering the reader after time away, start with the local `README.md` files under `lib/src/features/reader/presentation/` before diving into the implementation files.

## Plain-Language Note On Bible Formatting
Supporting Bible formatting from USFX, OSIS, and Zefania does not mean "just read the XML and save one string per verse."

The safer long-term approach is:
- parse the source file
- convert it into one shared app model
- save plain verse text for search and simple fallback display
- also save structured formatting data for real rendering

That structured data is where features such as these should live:
- footnotes
- cross-references
- red-letter text / words of Jesus
- poetry and quote indentation
- translator-added words
- word-level metadata such as Strong's numbers

In plain terms:
- raw XML is the import format
- normalized local database rows are the app's runtime format
- plain text is for search and simple reading
- structured spans/notes/references are for faithful display

If the app stores only flattened verse text, it loses too much meaning and later formatting features become much harder to build correctly.

## Plain-Language Note On Introductions And Book Lists
The parser can already give you the list of books. In practice, that comes from the parser's `books` stream, which yields each parsed Bible book one at a time.

What it does **not** preserve well yet is the non-verse content around those books, such as:
- Bible prefaces
- book introductions
- TOC labels
- canonical titles and headings
- other front matter that appears before normal chapter/verse text

This matters because some real Bible XML files already include that content. For example:
- the WEB USFX file includes a `FRT` preface book and TOC/title data
- USFX files include tags such as `h` and `toc`
- OSIS files often include `title` and other section/front-matter elements

So the short version is:
- yes, the parser can already produce the list of books
- no, it does not yet treat introductions and front matter as first-class content

If the app should eventually show introductions, then the parser and app model need to keep that content instead of dropping everything that is not a normal verse.

## Long-Term Fidelity Goal
The long-term goal for this project is not just "parse enough to show chapters and verses."

The stronger goal is:
- support as much meaningful content from USFX, OSIS, and Zefania as the app can safely model
- normalize that content into one shared internal representation
- store enough structure locally so future reader and study features do not need the source XML to be reparsed every time

In practical terms, that means the project should eventually support:
- books, chapters, and verses
- introductions and front matter
- section titles and navigation labels
- footnotes and cross-references
- red-letter text
- poetry and quote structure
- translator-added words
- word-level metadata where useful

It does **not** mean every raw source tag must be exposed directly to the UI.
The senior-developer approach is to map source-specific XML into shared app concepts first, then render those shared concepts in the app.

## Phase 1 Spec: Shared Model Before Full Fidelity
Before adding more parser features, the project should define one shared model that both the parser package and the app can understand.

Phase 1 is **not** "support every XML feature yet."
Phase 1 is:
- define the canonical app/parser model
- keep current plain-text reading working
- make room for richer metadata without redesigning storage again

### Phase 1 Goal
Create a shared data model that can support:
- plain verse text
- structured inline spans
- footnotes
- cross-references
- introductions and front matter
- section titles / TOC labels

### Phase 1 Non-Goals
These can come later after the model is stable:
- rendering every style in the UI
- lossless round-trip export of every source tag
- exposing raw XML tags directly to widgets

### Canonical Model Direction
The current model is too small because it mainly assumes:
- `Book`
- `Chapter`
- `Verse`

Phase 1 should move toward these shared concepts:

- `BibleDocument`
  - translation-level metadata
  - optional Bible-level introduction / preface blocks
  - list of parsed books
- `BibleBook`
  - id
  - number
  - title
  - short title / TOC labels
  - optional book introduction blocks
  - chapters
- `BibleChapter`
  - chapter number
  - optional structured blocks that belong at chapter level
  - verses
- `BibleVerse`
  - verse number
  - `plainText`
  - `spans`
  - `footnotes`
  - `references`

### Structured Types To Add
These names can change, but the concepts should exist.

- `VerseSpan`
  - `text`
  - `kind`
  - optional metadata

Suggested `kind` values:
- normal
- wordsOfJesus
- translatorAddition
- quote
- poetry
- word

- `Footnote`
  - marker / caller
  - optional label
  - text or structured content
  - optional nested references

- `CrossReference`
  - label text
  - normalized target if available

- `DocumentBlock`
  - kind
  - text or structured inline content
  - optional level / metadata

Suggested `DocumentBlock` uses:
- preface paragraph
- book introduction paragraph
- heading
- TOC/title label
- poetry block

### Storage Direction For Phase 1
Do not store only one flattened verse string.

Phase 1 storage should keep:
- plain text for fast search
- structured metadata for richer rendering later

Senior-friendly storage direction:
- keep normalized book/chapter/verse rows
- add JSON columns or related tables for:
  - spans
  - footnotes
  - references
  - introduction/front-matter blocks

For this project, JSON-backed columns are acceptable in Phase 1 if they reduce migration complexity.
The key requirement is: do not force another full schema redesign before richer reader features can be built.

### Parser Rollout Order
Implement in this order:
1. shared model in `bible_parser_flutter`
2. app-side matching model/storage changes in `basic_bible`
3. USFX support first
4. OSIS support second
5. Zefania support third

Why this order:
- USFX already has partial notes/reference support and matches local app assets well
- OSIS has important red-letter/title semantics
- Zefania should follow once the canonical model is stable

### Phase 1 Acceptance Criteria
Phase 1 is complete when:
- parser and app agree on one richer shared model
- plain-text reading still works
- footnotes, references, and introduction/front-matter content can be preserved in parsed output
- storage can retain that richer output locally
- the next parser enhancements can be added without redesigning the model again

### Beginner Summary
Phase 1 means:
- stop thinking "a verse is just one string"
- start thinking "a verse is text plus structured meaning"
- build the data model first
- then teach each parser format how to fill that model
- then render it in the app

## Practical Starting Points
- Start with `lib/main.dart` and `lib/src/app.dart` to understand app startup and routing.
- Move next to `lib/src/views/home/home_screen.dart` to understand the main shell.
- For Bible-reader work, inspect:
  - `lib/src/providers/bible_provider.dart`
  - `lib/src/repositories/app_bible_repository.dart`
  - `lib/src/services/app_database.dart`
- For feature/status questions, prefer repo truth over the README checklist.
- For execution tracking, update `TODO_STATUS.md` in the same commit or task that changes project behavior.
