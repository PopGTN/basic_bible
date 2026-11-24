# Bundled hymnals

The app ships pre-built hymnal assets in `assets/hymnals/<id>.json.gz`. **Never
edit those by hand.** Rebuild them from the files here:

```sh
dart run tool/hymnals/build_hymnal.dart bhb nbhb
```

| File | Purpose |
|---|---|
| `sources/<id>.source.json` | Raw hymn data (legacy bare-array format). |
| `<id>.meta.json` | The `book` block (title, publisher, copyright, permission wording), optional `rightsRules` for groups of hymns, and an optional `draftSource` used only while `source` is missing (draft builds go to `build/hymnals/`, never `assets/`). |
| `<id>.overrides.json` | Hand-reviewed per-hymn fixes (typos, line splits, editor notes, per-hymn copyright). |

Each run also writes `build/hymnals/<id>.json` (pretty, for review) and
`build/hymnals/<id>.report.txt` (lines that still need a human look, hymns whose
rights must be confirmed, and any `TODO_` fields left in the book block).

`test/features/hymns/bundled_hymnals_test.dart` fails while any `TODO_`
placeholder remains in a bundled asset — fill in the real publisher wording
before release.

## The two accepted formats

1. **Legacy** — a bare JSON array of
   `{id, title, author, meter, tuneName, verses: [[line]], chorus: [line], addedChorus: [line]}`.
   `addedChorus` is shown as an optional chorus.
2. **Hymnal v1** — `{"format": "hymnal", "schemaVersion": 1, "book": {...}, "hymns": [...]}`.
   Hymns use the legacy keys plus optional `notes`, `optionalVerses`,
   `alternateChoruses` (`[{label, lines}]`), `copyright` and `rightsStatus`.
   Unknown keys are ignored.
