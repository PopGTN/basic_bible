# Copilot instructions for Basic Bible (basic_bible)

This repository is a Flutter app that displays Bible content and uses a local parser package (`bible_parser_flutter`) to read USFX/OSIS assets. The file below gives focused, actionable guidance so an AI coding agent can be productive immediately.

Keep this short — target 20–50 lines. Be concrete and reference real files.

-- Quick orientation

- App entry: `lib/main.dart` → `lib/src/app.dart` → UI under `lib/src/views/`.
- Core data flow: `bible_parser_flutter` (path dependency in `pubspec.yaml`) parses XML assets listed in `pubspec.yaml` (see `assets/bible/*.xml`).
- Primary repository adapter: `lib/src/repositories/app_bible_repository.dart` — it loads/streams parser `Book` objects and maps them to app models (caching via `DatabaseService`).

-- State & providers

- Riverpod is used pervasively. Key providers live under `lib/src/providers/`:
  - `bible_repository_provider.dart` — provides `BibleRepository` and `currentTranslationProvider`.
  - `current_chapter_provider.dart` — resolves the currently selected chapter (watch `currentReferenceProvider`). Note: some variants return `AsyncValue`.
  - `cross_reference_provider.dart` — fetches cross references via the parser for the active translation.
  - `currentReferenceProvider` and `bibleBooksProvider` are central to navigation and are used by the UI to change chapters.

-- UI conventions & patterns

- Primary viewer: `lib/src/views/home/tabs/bibleViewerTab/bibleViewer_tab.dart`. It:
  - watches `bibleBooksProvider`, `currentReferenceProvider`, and `currentChapterProvider`.
  - uses `AsyncValue.when` for loading/error/data UI branches.
  - shows cross‑references either as a dialog on large screens or pushes `ReferenceScreen` on phones.
  - translation selection updates `currentTranslationProvider` and refreshes the book provider.

- Reference UI: `ReferenceScreen.dart` parses human strings ("John 3:16") into `BibleReference` and sets `currentReferenceProvider.notifier.setReference(parsed)` to navigate.

-- Parsing & assets

- The single source of parsing logic is the `bible_parser_flutter` package (path referenced in `pubspec.yaml`). Do not add a second parser — call its `BibleRepository` / `BibleParser` API.
- Asset names must match translation IDs. Check `pubspec.yaml` asset entries (`assets/bible/eng-web.usfx.xml`, `eng-kjv2006_usfx.xml`, `asv_osis.xml`) and mapping logic in `app_bible_repository.dart`.

-- Developer workflows (how to run & test)

- Install deps: `flutter pub get` at workspace root.
- Run app locally: `flutter run -d linux` (or any available device). Tests: `flutter test`.
- If changing parser/package code, run `flutter pub get` for both packages and restart the app.

-- Conventions & gotchas for code changes

- Prefer adding Riverpod providers for data access (thin UI → provider → `bible_parser_flutter`) rather than embedding parsing in views.
- Use `FutureProvider.autoDispose` for per‑chapter/cross‑reference fetches to release memory when navigating.
- When changing translation IDs, update both the `availableTranslations` in `app_bible_repository.dart` and the `assets` list in `pubspec.yaml` (IDs must align to find local assets).
- Keep parsing helpers (e.g., `_parseReferenceString`, book name → ID map) in a single util if multiple files use them (move to `lib/src/utils/reference_utils.dart`).

-- Useful files to inspect

- `lib/src/repositories/app_bible_repository.dart` — mapping between parser `Book` and app `BibleBook`; caching.
- `lib/src/providers/bible_repository_provider.dart` — repository provider and translation state.
- `lib/src/providers/current_chapter_provider.dart` — how the app resolves the current chapter.
- `lib/src/views/home/tabs/bibleViewerTab/bibleViewer_tab.dart` — interaction patterns for references, translation selection, and UI layout.

If anything is unclear or you want this expanded with example edits (e.g., move parsing helpers into a util, or replace `app_bible_repository` mapping with a thin adapter to `BibleRepository`), say which task to do next.
