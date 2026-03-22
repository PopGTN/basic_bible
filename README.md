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

### Not done yet

- Notes authoring
- Sync
- Audio / TTS playback
- Daily verse features
- Prayer features
- Screen-reader / accessibility polish
- Full Bible-study feature set

## Bible Format Support

The app uses the local `bible_parser_flutter` package and stores parsed Bible data in a shared local model.

Current parser/app direction:

- USFX: partial rich support
- OSIS: partial rich support
- Zefania: partial rich support

This means the app now preserves and renders more than plain verse text, but it does not yet claim full lossless support for everything those formats can express.

## Project Structure

Most active app code lives under `lib/src/features/`:

- `auth`
- `home`
- `library`
- `menu`
- `reader`
- `settings`

Shared models, services, providers, and a few older placeholder/shared pieces still live in shared folders under `lib/src/`.

## Internal Project Docs

These files are the main internal docs for the app:

- `CONTEXT.md`
- `TODO_STATUS.md`

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
