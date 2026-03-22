# Basic Bible App

This is a Flutter Bible app and learning project. It is the place where I am learning and testing ideas before building larger Bible-study apps later.

The app already works as a real Bible reader, but it is still under active development. The goal of this README is to reflect what the repo actually does today, not just what I hope to add later.

## Current App Status

Working now:
- Read the Bible in the app.
- Switch between bundled, downloaded, and imported translations.
- Import local Bible XML files in USFX, OSIS, and Zefania formats.
- Select book, chapter, and verse.
- Use `Verse List` mode or `Document` mode in the reader.
- Render partial rich formatting from supported Bible files:
  - words of Jesus
  - footnotes
  - cross-references
  - headings and some introduction/front-matter blocks
  - paragraph and poetry-style structure where the source file exposes it
- Use multiple UI languages:
  - English
  - French
  - Spanish
  - German
  - Chinese support exists in the localization setup
- Change app theme colors.
- Cache parsed Bible content locally on non-web platforms.

Partially done:
- Offline Bible persistence works on non-web platforms, but the web path still falls back to in-memory storage.
- Rich-format support is working across USFX, OSIS, and Zefania, but it is still partial and not full format fidelity for every possible source tag.
- The app structure is much cleaner than before, but there is still more contributor-facing cleanup to do.

Not done yet:
- Account system
- Notes
- Notes syncing
- TTS / audio playback
- Daily verse features
- Prayer list
- Screen-reader/accessibility improvements
- Full Bible-study feature set

## Bible Format Support

The app uses the local `bible_parser_flutter` package and stores parsed Bible data in a shared local model.

Current parser/app direction:
- USFX: partial rich support
- OSIS: partial rich support
- Zefania: partial rich support

This means the app preserves and renders more than plain verse text, but it still does not claim full lossless support for everything those formats can express.

## Project Structure

Active app code now lives mainly under `lib/src/features/`:
- `auth`
- `home`
- `library`
- `menu`
- `reader`
- `settings`

Shared models, services, and some app-wide providers still live in shared folders under `lib/src/`.

## Internal Project Docs

These files are for engineering context and task tracking:
- `CONTEXT.md`
- `TODO_STATUS.md`

## Planned Next Steps

Near-term priorities:
- keep `README.md` and internal docs aligned with repo truth
- continue improving reader polish and structured annotation UX
- keep improving format fidelity across USFX, OSIS, and Zefania
- continue cleanup toward a more maintainable feature-first codebase

Longer-term ideas:
- notes and study features
- sync/import-export workflows
- audio support
- daily verse and habit features
