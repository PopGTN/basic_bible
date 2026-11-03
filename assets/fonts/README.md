# Bundled reader fonts

Drop font files here and they appear automatically under
**Font → Included with the app** — no code or pubspec change needed.
Files are matched by (case-insensitive) name prefix:

| Font          | File names that match                    |
|---------------|------------------------------------------|
| Gentium Plus  | `GentiumPlus-Regular.ttf`, `-Italic`, `-Bold`, `-BoldItalic` |
| OpenDyslexic  | `OpenDyslexic-Regular.otf`, `-Italic`, `-Bold`, `-Bold-Italic` |

Both fonts are under the SIL Open Font License: include each font's
license file (e.g. `OFL.txt`) alongside it and keep it in the app's
licenses/about screen. To add another font, add an entry to
`bundledFontSpecs` in
`lib/src/features/settings/data/reader_font_repository.dart`.
