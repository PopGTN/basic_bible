---
name: Database Schema
description: Drift database schema (v6), table definitions, converters, and key access patterns
type: project
---

## AppDatabase (Drift, schema version 6)
File: `lib/src/services/app_database.dart` | Generated: `app_database.g.dart`

Run `flutter pub run build_runner build` to regenerate after schema changes.

## Tables

### `Translations` → `TranslationEntry`
| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | translation ID (e.g. `kjv`) |
| `name`, `language`, `description`, `format` | TEXT | metadata |
| `sourceType` | TEXT | `asset`, `download`, `import` |
| `sourceLocation` | TEXT? | file path or URL |
| `isLocal` | BOOL | default false |
| `importedAt` | DATETIME | default now |
| `parserVersion` | INT | default 0; used for cache invalidation |

### `Books` → `BookEntry`
| Column | Type | Notes |
|---|---|---|
| `id` | TEXT PK | composite: `{translationId}_{BOOKID_UPPERCASE}` e.g. `kjv_GEN` |
| `translationId` | TEXT FK→Translations | |
| `name`, `shortName` | TEXT | |
| `bookNumber` | INT | |
| `bookType` | INT | index of `BibleBookType` enum |
| `tocLabels` | TEXT? | JSON list of `BibleTocLabel` |
| `introductionBlocks` | TEXT? | JSON list of `BibleDocumentBlock` |

### `Chapters` → `ChapterEntry`
| Column | Type | Notes |
|---|---|---|
| `id` | INT autoincrement PK | |
| `bookId` | TEXT FK→Books | |
| `number` | INT | |
| `blocks` | TEXT? | JSON list of `BibleDocumentBlock` |
| UNIQUE | (`bookId`, `number`) | |

### `Verses` → `VerseEntry`
| Column | Type | Notes |
|---|---|---|
| `id` | INT autoincrement PK | |
| `chapterId` | INT FK→Chapters | |
| `number` | INT | |
| `verseText` | TEXT | (named `verseText` to avoid collision with Drift's `text()` builder) |
| `notes` | TEXT? | semicolon-delimited strings |
| `references` | TEXT? | semicolon-delimited strings |
| `spans` | TEXT? | JSON list of `BibleVerseSpan` |
| `footnotes` | TEXT? | JSON list of `BibleFootnote` |
| `crossReferences` | TEXT? | JSON list of `BibleCrossReference` |
| UNIQUE | (`chapterId`, `number`) | |

### `UserAnnotations` → `UserAnnotationEntry`
| Column | Type |
|---|---|
| `id` | INT autoincrement PK |
| `type` | TEXT (`note`/`highlight`) |
| `primaryBookId`, `primaryChapter`, `primaryVerse` | TEXT/INT |
| `primaryTranslationId`, `primaryTranslationName` | TEXT |
| `noteText` | TEXT? |
| `highlightColorValue` | INT? |
| `labels` | TEXT (JSON array of strings) |
| `createdAt`, `updatedAt` | DATETIME |

### `AnnotationVerses` → `AnnotationVerseEntry`
| Column | Type | Notes |
|---|---|---|
| `id` | INT autoincrement PK | |
| `annotationId` | INT FK→UserAnnotations | |
| `sortOrder` | INT | |
| `bookId`, `chapter`, `verse` | TEXT/INT | |
| `translationId`, `translationName` | TEXT | |
| UNIQUE | (`annotationId`, `sortOrder`) | |

## Migration history
- v1–v4: initial Bible content tables
- v5: added `parserVersion` column to `translations`
- v6: added `user_annotations` and `annotation_verses` tables

## Type converters
- `StringListConverter` — semicolon-delimited (used for `notes`, `references`)
- `JsonStringListConverter` — JSON array of strings (used for `labels`)
- `BibleVerseSpanListConverter`, `BibleFootnoteListConverter`, `BibleCrossReferenceListConverter` — JSON arrays
- `BibleTocLabelListConverter`, `BibleDocumentBlockListConverter` — JSON arrays

## Key access patterns
- `getBooksShell(translationId)` — books + chapters, empty verses (fast)
- `getChapter(translationId, bookId, chapterNumber)` → `BibleChapter?` — single chapter with verses
- `getBible(translationId)` — full load (all books, chapters, verses; slow)
- `insertBible(translationId, books)` — replaces entire translation in one transaction
- `isBibleCached(translationId)` — quick check before parsing
- `watchAllUserAnnotations()` → `Stream<List<UserAnnotation>>`
- `saveUserAnnotation(annotation)` → `int` (annotation ID)
- `deleteUserAnnotation(annotationId)`
