---
name: Project Overview
description: High-level summary of the basic_bible Flutter app — what it is, what it does, and how it is structured
type: project
---

**basic_bible** is a cross-platform Flutter Bible reader app (package `basic_bible`, bundle `ca.joshuamc.basic_bible`). It targets Android, iOS, and desktop (Linux/Windows/Mac via `window_manager`). Dart SDK `>=3.9.0 <4.0.0`.

## Core purpose
- Display Bible text with rich formatting (headings, poetry, footnotes, cross-references, Words of Jesus, etc.)
- Let users highlight verses and write notes (annotations)
- Support multiple Bible translations, including user-imported files (USFX, OSIS, Zefania XML)
- Two reading layout modes: **verseList** and **document** (paragraph style)

## Feature areas (`lib/src/features/`)
- **reader** — main reading tab; scroll-driven hide/show of nav/appbar; reference bar; chapter picker
- **annotations** — highlights + notes tied to verse references; full editor with linked verses and labels
- **library** — translation management: 3 built-in (KJV, WEB, ASV), downloadable, user-importable
- **home** — bottom-tab navigation shell
- **settings** — font size, layout, reading preferences
- **auth** — stub/in-progress login screen
- **menu** — additional nav tab

## Data layer
- **Drift** (SQLite ORM, schema v6) — `AppDatabase` in `lib/src/services/app_database.dart`; generated in `app_database.g.dart`
- Tables: `Translations`, `Books`, `Chapters`, `Verses`, `UserAnnotations`, `AnnotationVerses`
- Two-phase loading: **shell** (books + chapter metadata, no verses) loaded fast → verses **hydrated on demand** per chapter via `currentChapterProvider`
- Book IDs stored as `{translationId}_{BOOKID_UPPERCASE}` composite keys
- Parser version (`_currentParserVersion = 2`) tracked per translation; cache is invalidated and re-parsed when bumped

## State management
- **Riverpod 3.0** throughout — used in an explicit MVVM-style feature layout
- Feature convention:
  - `models/` = cross-layer types
  - `data/` = repositories and persistence
  - `application/view_models/` = Riverpod state + UI orchestration
  - `presentation/` = widgets and screens
- Key providers: `currentTranslationProvider`, `currentReferenceProvider`, `bibleBooksShellProvider`, `currentChapterProvider`, `userAnnotationsProvider`
- Persistent settings in `SharedPreferences`: current book/chapter/verse, layout mode, continuous scroll, font size

## Bible parsing
- Custom local package `bible_parser_flutter` (path: `/home/joshua/Documents/Flutter Apps/Bible App Projects/bible_parser_flutter`)
- Parses USFX, OSIS, Zefania XML → `BibleDocument` model tree
- Bundled assets: `assets/bible/eng-kjv2006_usfx.xml`, `assets/bible/eng-web.usfx.xml`, `assets/bible/asv_osis.xml`

## Localization
- `lib/l10n/` — English, German, Spanish, French, Chinese (`.arb` + generated `.dart`)

## Git branches
- Active dev: `development-work`
- Stable release: `Stable`
