# Bundled reader fonts

Fonts here appear automatically under **Font → Included with the app**.
They apply to Bible text only; the rest of the UI keeps the theme font.
Files are matched by (case-insensitive) name prefix:

| Font          | Files                                                      | License                |
|---------------|------------------------------------------------------------|------------------------|
| Gentium Plus  | `GentiumPlus-Regular.ttf`, `-Italic`, `-Bold`, `-BoldItalic` | `GentiumPlus-OFL.txt`  |
| OpenDyslexic  | `OpenDyslexic-Regular.otf`, `-Italic`, `-Bold`, `-BoldItalic` | `OpenDyslexic-OFL.txt` |

**Gentium Plus is the default Bible font** (`defaultBundledFontId`) until
the user picks another font, including "System Default".

Both fonts are under the SIL Open Font License 1.1. The license files are
registered with Flutter's `LicenseRegistry` (see
`registerBundledFontLicenses`), so they show on any `showLicensePage`.
To add another font, add an entry to `bundledFontSpecs` in
`lib/src/features/settings/data/reader_font_repository.dart`.
