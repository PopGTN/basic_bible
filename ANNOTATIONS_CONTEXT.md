# Personal Annotations Context

## Purpose
This file tracks the app's user-created annotation system.

It is intentionally separate from parser-originated Bible footnotes and cross-references.

The personal annotation feature covers:

- saved highlights
- saved notes
- notes with connected highlight colors
- linked verse references inside notes
- translation metadata for every saved verse link

## Architectural Direction

### Separate personal annotations from source annotations
Parser footnotes and cross-references are part of imported Bible content.
Personal notes and highlights are user-created data.

These should stay separate in:

- app models
- storage tables
- providers
- UI wording

This keeps future editing, export, sync, and partial-verse work from being tangled up with parser fidelity work.

### Storage model
The first version uses:

- a `user_annotations` table for the primary saved item
- an `annotation_verses` table for extra linked verses attached to notes

The primary verse stays on the main annotation row.
Additional linked verses live in the child table.

Each saved verse link stores:

- book id
- chapter
- verse
- translation id
- translation name shown when it was saved

### Annotation shape
The current model supports:

- standalone highlight
- standalone note
- note with connected highlight color

This is why the model keeps both:

- `type`
- optional `noteText`
- optional `highlightColorValue`

That gives the UI a fast highlight path without blocking richer note behavior.

### Future-safe constraint
V1 is whole-verse only.

The current model intentionally does not store text-range anchors yet, but it also avoids hard-coding the feature around parser footnotes or flattened strings. That leaves room for future work on:

- partial-verse highlights
- partial-verse notes
- export formatting
- cloud sync metadata

## Current UI Surface
The current annotation UI is spread across:

- the reader verse-selection action bar
- the note editor screen
- the Notes screen

The reader can now:

- select a verse
- save a quick highlight
- open a note editor
- copy verse text
- use a temporary share fallback that copies text to clipboard

The Notes screen can now:

- list saved notes and highlights
- show linked verses
- show saved translation labels
- jump back into the reader
- reopen items for editing

## Current Limitations

- Partial-verse annotation is not implemented yet.
- Native platform share is not wired yet; the current share action copies text and explains that fallback.
- Export is not implemented yet.
- Cloud sync is not implemented yet.
- Reader document-mode selection/highlight treatment is improved, but it still needs more polish than verse-list mode.

## Next Safe Extensions

- widget tests for reader selection and Notes screen navigation
- export pipeline (`docx`, `csv`)
- sync abstraction for free providers later
- text-range anchors for partial-verse annotations
