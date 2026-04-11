---
name: Architecture & Providers
description: Riverpod provider map, loading strategy, and key architecture patterns used in the app
type: project
---

## State management: Riverpod 3.0
Imports: `flutter_riverpod`, `hooks_riverpod`, `riverpod/legacy.dart` (for `StateNotifierProvider`).

## Project pattern

The repo now uses a pragmatic MVVM-style layout:

- `models/` for shared structured types
- `data/` for repositories and persistence
- `application/view_models/` for Riverpod-driven screen state
- `presentation/` for widgets and rendering

## Key providers

### Reader session and preferences (`lib/src/features/reader/application/view_models/`)
| Provider | Type | State |
|---|---|---|
| `currentTranslationProvider` | `StateNotifierProvider<TranslationNotifier, String>` | active translation ID (default: `'kjv'`) |
| `currentReferenceProvider` | `StateNotifierProvider<ReferenceNotifier, BibleReference>` | current book/chapter/verse |
| `readerLayoutModeProvider` | `StateNotifierProvider<..., ReaderLayoutMode>` | `verseList` or `document` |
| `continuousScrollingProvider` | `StateNotifierProvider<..., bool>` | continuous scroll setting |
| `showBookIntroductionsProvider` | `StateNotifierProvider<..., bool>` | show intro blocks |
| `showVerseSelectorProvider` | `StateNotifierProvider<..., bool>` | show verse selector UI |
| `bibleRepositoryProvider` | `Provider<AppBibleRepository>` | singleton repository |
| `bibleBooksShellProvider` | `StateNotifierProvider<BibleBooksShellNotifier, AsyncValue<List<BibleBook>>>` | fast shell (no verses) |
| `bibleBooksProvider` | `StateNotifierProvider<BibleBooksNotifier, AsyncValue<List<BibleBook>>>` | full books with all verses |
| `availableTranslationsProvider` | `FutureProvider<List<BibleTranslation>>` | all stored translations |

### Current chapter (`lib/src/features/reader/application/view_models/current_chapter_view_model.dart`)
| Provider | Type | Description |
|---|---|---|
| `currentChapterProvider` | `FutureProvider<BibleChapter?>` | Watches shell + reference; hydrates verses on demand via `repository.loadChapterVerses()` if shell chapter has empty verses |

### Annotations (`lib/src/features/annotations/application/view_models/`)
| Provider | Type | Description |
|---|---|---|
| `userAnnotationRepositoryProvider` | `Provider<UserAnnotationRepository>` | singleton repo |
| `userAnnotationsProvider` | `StreamProvider<List<UserAnnotation>>` | live stream of all annotations |
| `visibleChapterAnnotationsProvider` | `Provider<List<UserAnnotation>>` | annotations for current chapter + translation |
| `selectedVersesProvider` | `StateNotifierProvider.autoDispose<SelectedVersesNotifier, List<BibleReference>>` | current multi-selection in the reader |
| `selectedVerseProvider` | `Provider.autoDispose<BibleReference?>` | first selected verse convenience accessor |
| `selectedVerseAnnotationsProvider` | `Provider<List<UserAnnotation>>` | annotations for tapped verse |
| `highlightPaletteExpandedProvider` | `StateProvider.autoDispose<bool>` | palette open state |

## Two-phase loading strategy
1. **Shell load** — `bibleBooksShellProvider` calls `repository.loadLocalBibleShell()` → books + chapter metadata, **no verses**. Fast because it skips the large verses table.
2. **Verse hydration** — `currentChapterProvider` checks if current chapter has empty verses; if so, calls `repository.loadChapterVerses(translation, bookId, chapterNumber)` to fetch just that chapter's verses from DB.
3. **Translation cache** — `AppBibleRepository` keeps a `Map<String, List<BibleBook>> _memoryCacheByTranslation`; switching back to a previously loaded translation is instant.

## Translation loading flow
```
loadLocalBibleShell(id)         → DB: books + chapters (no verses)
  ↓ fails?
loadLocalBible(id)             → DB: full load
  ↓ fails?
downloadBible(id)              → HTTP fetch + parse + cache to DB
```
Import flow: `prepareBibleImport(filePath)` → returns `BibleImportDraft` for user review → `importPreparedBible(BibleImportRequest)` → stores to DB.

## Parser version cache invalidation
`AppBibleRepository._currentParserVersion = 2` — stored per translation in `translations.parserVersion`. If DB version < current, translation is re-parsed from source. Bump this constant when parser output format changes incompatibly.

## SharedPreferences keys
- `bible_translation` — current translation ID
- `bible_book`, `bible_chapter`, `bible_verse` — last reading position
- `reader_continuous_scrolling`, `reader_show_book_introductions`, `reader_show_verse_selector`
- `reader_layout_mode` — `verseList` or `document`
