---
name: Data Models
description: Core Bible and annotation data model classes, their relationships, and key fields
type: project
---

## Bible structure hierarchy
`BibleDocument → BibleBook → BibleChapter → BibleVerse`

All models use `equatable`, have `fromJson`/`toJson`, and live in `lib/src/models/bible_models/`.

### BibleVerse (bible_structure.dart)
- `number`, `text` (plain string)
- `spans: List<BibleVerseSpan>` — rich inline spans
- `footnotes: List<BibleFootnote>` — footnote objects with inline anchor info
- `crossReferences: List<BibleCrossReference>` — cross-ref objects with inline anchor info
- `notes`, `references` — legacy plain string lists (may coexist with structured versions)

### BibleVerseSpan (verse_span.dart)
- `text`, `kind: BibleVerseSpanKind`, `metadata: Map<String,String>`
- Kinds: `normal`, `wordsOfJesus`, `translatorAddition`, `quote`, `poetry`, `word`, `divineNameTag`, `properName`, `selah`, `acrosticHeading`, `emphasis`, `bold`, `italic`, `foreignLanguage`, `keyword`

### BibleFootnote / BibleCrossReference (verse_span.dart)
- Both carry `spanIndex: int?` and `charOffset: int?` — used to anchor the marker inline within the verse text
- `BibleFootnote`: `text`, `marker`, `label`, `bodyText`, `quotedText`, `references: List<BibleCrossReference>`
- `BibleCrossReference`: `label`, `target`, `marker`, `originRef`

### BibleDocumentBlock (document_block.dart)
- `kind: BibleDocumentBlockKind` — `paragraph`, `preface`, `introduction`, `heading`, `tocLabel`, `poetry`, `table`, `tableRow`
- `text`, `level: int?`, `metadata: Map<String,String>`
- Used for chapter-level blocks and book introduction blocks

### BibleBook (bible_structure.dart)
- `id` (3-letter code, uppercase, e.g. `GEN`), `name`, `shortName`, `bookNumber`
- `bookType: BibleBookType` — `oldTestament` or `newTestament`
- `tocLabels: List<BibleTocLabel>`, `introductionBlocks: List<BibleDocumentBlock>`

### BibleTranslation (bible_translation.dart)
- `id`, `name`, `language`, `description`, `format: BibleFormat`, `sourceType: BibleSourceType`
- `isLocal`, `filePath`, `githubUrl`
- Formats: `usfx`, `usfm`, `osis`, `auto`
- Source types: `asset`, `download`, `import`

### BibleReference (bible_reference.dart)
- `bookId: String` (e.g. `GEN`), `chapter: int`, `verse: int?`

## Annotation models (`lib/src/features/annotations/models/user_annotations.dart`)

### UserAnnotation
- `id: int?`, `type: UserAnnotationType` (`note` or `highlight`)
- `primaryVerse: AnnotationVerseLink` — the main verse this annotation belongs to
- `linkedVerses: List<AnnotationVerseLink>` — additional verses linked to this annotation
- `noteText: String?`, `highlightColorValue: int?`, `labels: List<String>`
- `createdAt`, `updatedAt`
- Helper: `touchesReference(BibleReference, {String? translationId})`

### AnnotationVerseLink
- `bookId`, `chapter`, `verse`, `translationId`, `translationName`, `sortOrder`
- Helper: `.reference` → `BibleReference`

### AnnotationEditorDraft
- Mutable editing state; `editingAnnotationId` distinguishes new vs. existing
- Factory: `AnnotationEditorDraft.fromAnnotation(UserAnnotation)`
