# Basic Bible App

`basic_bible` is the Flutter app in this workspace. It is both a working Bible reader and a prototype app for testing parser, reader, and UI ideas before they are carried into larger Bible-study apps later.

This README is intentionally status-focused. It should reflect what the repo actually does now.

## Current App Status

### Working now

- Read Bible content inside the app.
- Switch between bundled, cached, downloaded, and imported translations.
- Import local Bible XML files in USFX, OSIS, and Zefania formats.
- Use the dedicated `Versions` screen to select translations.
- Control startup behavior from Settings, including:
  - opening directly on the Bible tab by default
  - turning the sample login gate on or off
- Open a full-screen `References` picker with:
  - search
  - canonical or alphabetical ordering
  - recent-reference history
  - optional verse selection
- Read in:
  - `Verse List` mode
  - `Document` mode
  - `Continuous Scrolling` mode
- Render partial rich Bible formatting from supported files, including:
  - words of Jesus
  - footnotes
  - cross-references
  - section headings rendered inline at the correct verse position with level-aware styles (`<ms>`, `<s>`, `<s2>`)
  - translator additions rendered italic with `[brackets]`
  - book introductions / some front-matter blocks
  - paragraph and poetry-style structure where the source exposes it
- Open verse notes from the side annotation button and view structured note/reference sheets.
- Render inline note/reference markers in the reader where parser metadata is available.
- Select verses in the reader and save:
  - standalone highlights
  - personal notes
  - notes with connected highlight colors
- Link extra verses to a personal note and preserve the translation label used when each verse was added.
- Browse and edit saved personal notes/highlights from a dedicated `Notes` screen.
- Use multiple themes, including:
  - system
  - light
  - dark
  - soft dark
  - pure black
  - pure white
  - blue
  - red
- Change app language with the current localization setup.
- Persist parsed Bible content locally on non-web platforms.
- Build and read bundled or downloaded Bible content in the browser with the web target.

### Partially done

- Rich-format support works across USFX, OSIS, and Zefania, but it is still partial and not full format fidelity for every source tag.
- Introductions and front matter now render in the reader, but Bible-level front matter is still not fully modeled end to end.
- Continuous scrolling works as a whole-Bible lazy reader, but it still has an open regression item around keeping the scroller and reference controls fully in sync during some interactions.
- Translation-library management is much better than before, but online-only translation access and fuller library lifecycle management are still not finished.
- Offline persistence works on non-web platforms; web now has a browser-safe database path, but local file import/export workflows are still limited there.
- Personal annotations now save and reopen, but:
  - partial-verse annotation is still future work
  - native platform share/export/sync are still follow-up work

### Not done yet

- Sync
- Audio / TTS playback
- Daily verse features
- Prayer features
- Screen-reader / accessibility polish
- Full Bible-study feature set
- Browser import of local Bible XML/SQLite files
- Browser export of cached translation databases

## Bible Format Support

The app uses the local `bible_parser_flutter` package and stores parsed Bible data in a shared local model.

The goal is to support **every meaningful feature** each format can express — not just plain verse text. The tables below show current progress. Every `❌ Not yet` row is planned work, not an intentional omission.

**Status key:**

- ✅ Supported — preserved through parser and stored in the app
- ⚠️ Partial — some coverage but incomplete or lossy
- ❌ Not yet — format supports it; parser and app do not yet preserve it

### USFX

| Feature | Status |
| --- | --- |
| Books / chapters / verses | ✅ |
| Words of Jesus (`<wj>`) | ✅ Supported — preserved as rich spans and rendered in the reader |
| Translator additions (`<add>`) | ✅ Supported — rendered italic with `[brackets]` |
| Footnotes (`<f>`) with label (`<fr>`) and body (`<ft>`) | ✅ Supported — structured footnotes preserved in app storage and reader sheet |
| Footnote quote / alt quote (`<fq>`, `<fqa>`) | ✅ Supported — shown as quoted text in the reader sheet |
| Cross-references (`<x>`) with targets (`<ref tgt="...">`) | ✅ Supported — structured references preserved with tappable targets |
| Cross-ref origin (`<xo>`) | ✅ Supported — preserved as origin metadata in the app |
| Quote attribution (`<q who="...">`) | ✅ Supported — preserved in verse metadata and surfaced in source details |
| Poetry / quote lines (`<q level="...">`) | ✅ Supported — quote level and poetry structure drive reader layout |
| Strong's word metadata (`<w s="...">`) | ✅ Supported — preserved in span metadata and surfaced in source details |
| Word morphology (`<w m="...">`) and lemma (`<w l="...">`) | ✅ Supported — preserved in span metadata and surfaced in source details |
| Book heading (`<h>`) | ✅ |
| TOC labels (`<toc>`) | ✅ |
| Section headings (`<ms>`, `<s>`, `<s2>`) | ✅ Supported — inline at correct verse, level-aware styles |
| Paragraph starts / breaks (`<p>`, `<b>`) | ✅ Supported — preserved as chapter document blocks |
| Intro paragraphs (`<ip>`, `<imt>`, `<is>`) | ✅ Supported — rendered as introduction blocks |
| Intro outline entries (`<io1>`, `<io2>`) | ✅ Supported — preserved with level metadata |
| Chapter description (`<cd>`) | ✅ Supported — preserved as chapter-level document content |
| List items (`<li1>`, `<li2>`, `<li3>`) | ✅ |
| Intro list items (`<ili1>`, `<ili2>`) | ✅ |
| Divine name / LORD (`<nd>`) | ✅ Supported — rendered with optional bold emphasis |
| Proper name (`<pn>`) | ✅ Supported — rendered with optional underline emphasis |
| Selah / music cue (`<qs>`) | ✅ Supported — preserved as a dedicated span kind |
| Acrostic heading (`<qa>`) | ✅ Supported — preserved as a dedicated span kind |
| Inline emphasis (`<em>`, `<bd>`, `<it>`) | ✅ Supported — preserved and rendered as emphasis/bold/italic spans |
| Foreign language (`<fl>`) | ✅ Supported — preserved and rendered as italicized foreign-language spans |
| Keyword (`<k>`) | ✅ Supported — preserved and rendered as highlighted keyword spans |

### OSIS

| Feature | Status |
| --- | --- |
| Books / chapters / verses (including milestone sID/eID) | ✅ |
| Words of Jesus (`<q who="Jesus">`) | ⚠️ Partial |
| Translator additions (`<transChange type="added">`) | ⚠️ Partial |
| Footnotes (`<note type="footnote">`) | ⚠️ Partial — nested parts incomplete |
| Study notes (`<note type="study">`) | ❌ Not yet — not distinguished from footnotes |
| Cross-references (`<note type="crossReference">`) | ⚠️ Partial |
| Reference targets (`<reference osisRef="...">`) | ⚠️ Partial |
| Book title (`<title type="main">`) | ✅ |
| Section heading (`<title type="section">`) | ⚠️ Partial |
| Running head (`<title type="runningHead">`) | ❌ Not yet |
| Canonical title / short title | ✅ |
| Psalm superscription (`<title type="psalm">`) | ⚠️ Partial — positioning partial |
| Poetry line group (`<lg>`) | ✅ |
| Poetry line (`<l level="...">`) | ⚠️ Partial |
| Paragraph (`<p>`) | ⚠️ Partial |
| Line break (`<lb />`) | ✅ |
| Speaker attribution (`<speaker>`) | ✅ |
| Tables (`<table>`, `<row>`, `<cell>`) | ❌ Not yet |
| Lists / items (`<list>`, `<item>`) | ✅ |
| Strong's numbers (`<w lemma="strong:H1">`) | ⚠️ Partial |
| Morphology (`<w morph="...">`) | ❌ Not yet |
| Nested section divs | ✅ |
| Book introduction (`<div type="introduction">`) | ⚠️ Partial |
| Colophon (`<div type="colophon">`) | ❌ Not yet |
| Catchword / gloss | ❌ Not yet |

### Zefania

| Feature | Status |
| --- | --- |
| Books / chapters / verses | ✅ |
| Bible metadata (`<INFORMATION>`) | ✅ |
| Book prolog (`<PROLOG>`) | ✅ |
| Chapter caption (`<CAPTION>`) | ✅ |
| Footnotes (`<NOTE>`) | ⚠️ Partial |
| Cross-references (`<XREF>`) | ⚠️ Partial |
| Styled text (`<STYLE type="...">`) | ⚠️ Partial — span kind inferred from type name |
| Words of Jesus (via `<STYLE>`) | ⚠️ Partial — inferred, not explicit |
| Translator additions (via `<STYLE>`) | ⚠️ Partial — inferred, not explicit |
| Paragraph (`<PARA>`) | ✅ |
| Line break (`<BR />`) | ❌ Not yet |
| Grammar metadata (`<gr>`) | ⚠️ Partial |

For the complete per-tag breakdown including specific XML attributes, see `bible_parser_flutter/README.md`.

## Project Structure

Most active app code lives under `lib/src/features/`:

- `auth`
- `home`
- `library`
- `menu`
- `reader`
- `settings`

The codebase now uses a pragmatic MVVM-style feature layout:

- `models/` for shared structured types
- `data/` for repositories and persistence
- `application/view_models/` for Riverpod-based screen state and UI orchestration
- `presentation/` for widgets, screens, and rendering

Shared models, services, providers, and a few older placeholder/shared pieces still live in shared folders under `lib/src/`.

## Internal Project Docs

These files are the main internal docs for the app:

- `CONTEXT.md`
- `TODO_STATUS.md`
- `ANNOTATIONS_CONTEXT.md`
- `ANNOTATIONS_STATUS.md`

## Running The Web App

Start from the app folder:

```bash
cd "/home/joshua/Documents/Flutter Apps/Bible App Projects/basic_bible"
```

For normal web development, use Flutter's web runner:

```bash
flutter run -d chrome
```

That gives you hot reload and is the best option while actively changing code.

If you want to test the production-style web build instead:

```bash
flutter build web
python3 -m http.server 8000 --directory build/web
```

Then open:

```text
http://127.0.0.1:8000
```

Notes:

- The production web build must be served over HTTP. Opening `build/web/index.html` directly from the file system is not enough.
- Browser-persisted downloaded translations use the web database/cache path, so they should survive reloads after a successful build and load.
- Local file import is still not available in the browser yet.

## Running With Google Sign-In And Language Packs

Both features are configured with build-time `--dart-define` values, and both
are optional: with none of them set, the app runs normally (Google sync shows
"not configured", and the UI language packs come from the `main` branch).

### 1. Put the values in a gitignored file

```bash
cp dart_defines.example.json dart_defines.json   # already in .gitignore
```

| Key | Needed for | Notes |
|---|---|---|
| `GOOGLE_DESKTOP_CLIENT_ID`, `GOOGLE_DESKTOP_CLIENT_SECRET` | Google sign-in on desktop | See `docs/google_sync_setup.md` |
| `GOOGLE_WEB_CLIENT_ID` | Google sign-in on Android | Used as the server client id |
| `GOOGLE_IOS_CLIENT_ID` | Google sign-in on iOS | |
| `LANGUAGE_PACK_REF` | Which git ref the UI language packs download from | Leave empty (or remove it) to use `main` |

Never commit real client IDs; this repository is public.

### 2. Run or build with it

```bash
flutter run -d linux   --dart-define-from-file=dart_defines.json
flutter run -d android --dart-define-from-file=dart_defines.json
flutter build apk      --dart-define-from-file=dart_defines.json
```

The VS Code launch configurations already pass `--dart-define-from-file`.

### Language packs

- English is bundled in the app (`lib/l10n/app_en.arb`). Other languages are
  downloaded the first time they are needed (on first launch if the device
  language is supported, otherwise when picked in Settings → Language) and
  cached on the device, so they work offline afterwards.
- Packs live in this repo as `lib/l10n/app_<code>.arb`, listed in
  `lib/l10n/languages.json`. To add a language, add both files and open a PR.
- **`LANGUAGE_PACK_REF` unset or empty: packs come from `main`** and are
  re-checked about once a day. This is what `flutter run` and local builds use.
- **Release builds should pin the commit they were built from**, so the app
  always gets strings that match its code (a pinned pack never changes, so it
  is cached permanently):

  ```bash
  flutter build apk --dart-define-from-file=dart_defines.json \
    --dart-define=LANGUAGE_PACK_REF=$(git rev-parse HEAD)
  ```

  A tag such as `v1.2.0` also works. The GitHub Pages workflow
  (`.github/workflows/deploy_web.yml`) already pins `github.sha`.
- If the ref doesn't exist on GitHub (for example an unpushed commit), the
  download fails and the app keeps its cached pack or falls back to English.
- After editing `lib/l10n/app_en.arb`, run `python3 tool/gen_l10n.py` to
  regenerate `lib/l10n/app_localizations.dart`.

## Near-Term Focus

The current high-value work is still:

- improving parser-side format fidelity
- reducing UI-side guessing in the reader
- tightening continuous-scrolling behavior
- keeping docs aligned with repo truth

## Longer-Term Ideas

- study notes and study tools
- sync and import/export workflows
- audio support
- daily-verse and habit features

