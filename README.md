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
  - headings
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

### Partially done

- Rich-format support works across USFX, OSIS, and Zefania, but it is still partial and not full format fidelity for every source tag.
- Introductions and front matter now render in the reader, but Bible-level front matter is still not fully modeled end to end.
- Continuous scrolling works as a whole-Bible lazy reader, but it still has an open regression item around keeping the scroller and reference controls fully in sync during some interactions.
- Translation-library management is much better than before, but online-only translation access and fuller library lifecycle management are still not finished.
- Offline persistence works on non-web platforms, but web still falls back to in-memory storage.
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
| Words of Jesus (`<wj>`) | ⚠️ Partial |
| Translator additions (`<add>`) | ⚠️ Partial |
| Footnotes (`<f>`) with label (`<fr>`) and body (`<ft>`) | ⚠️ Partial — nested parts not yet split |
| Footnote quote / alt quote (`<fq>`, `<fqa>`) | ❌ Not yet |
| Cross-references (`<x>`) with targets (`<ref tgt="...">`) | ⚠️ Partial |
| Cross-ref origin (`<xo>`) | ❌ Not yet |
| Quote attribution (`<q who="...">`) | ❌ Not yet |
| Poetry / quote lines (`<q level="...">`) | ⚠️ Partial |
| Strong's word metadata (`<w s="...">`) | ⚠️ Partial |
| Word morphology (`<w m="...">`) and lemma (`<w l="...">`) | ❌ Not yet |
| Book heading (`<h>`) | ✅ |
| TOC labels (`<toc>`) | ✅ |
| Section headings (`<s>`, `<s1>`, `<s2>`) | ⚠️ Partial |
| Paragraph starts / breaks (`<p>`, `<b>`) | ⚠️ Partial |
| Intro paragraphs (`<ip>`, `<imt>`, `<is>`) | ❌ Not yet |
| Intro outline entries (`<io1>`, `<io2>`) | ❌ Not yet |
| Chapter description (`<cd>`) | ❌ Not yet |
| List items (`<li1>`, `<li2>`, `<li3>`) | ✅ |
| Intro list items (`<ili1>`, `<ili2>`) | ✅ |
| Divine name / LORD (`<nd>`) | ❌ Not yet |
| Proper name (`<pn>`) | ❌ Not yet |
| Selah / music cue (`<qs>`) | ❌ Not yet |
| Acrostic heading (`<qa>`) | ❌ Not yet |
| Inline emphasis (`<em>`, `<bd>`, `<it>`) | ❌ Not yet |

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
