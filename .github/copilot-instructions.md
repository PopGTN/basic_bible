# Copilot Instructions — basic_bible

Focused, actionable guidance so an AI coding agent can be productive immediately.
See `CONTEXT.md` and `TODO_STATUS.md` for deeper engineering context and status tracking.

---

## Quick Orientation

- Entry: `lib/main.dart` → `lib/src/app.dart` → features under `lib/src/features/`
- Active feature folders: `auth`, `home`, `library`, `menu`, `reader`, `settings`
- Shared models: `lib/src/models/bible_models.dart` (barrel export for `lib/src/models/bible_models/*.dart`)
- Shared services: `lib/src/services/app_database.dart` (Drift ORM, SQLite)
- Parser package: `bible_parser_flutter` (local path dependency in `pubspec.yaml`)

---

## Data Flow

```
XML file (asset / download / import)
  → BibleParser (bible_parser_flutter)
  → AppBibleRepository (lib/src/features/library/data/app_bible_repository.dart)
  → AppDatabase (Drift, lib/src/services/app_database.dart)
  → Riverpod providers
  → Reader UI
```

Parsing is done in a `compute()` isolate so large Bible files do not block the UI thread.

---

## State Management

Riverpod is used throughout. Key providers:

- `lib/src/features/reader/application/bible_provider.dart` — current translation, available translations, current Bible reference, reader layout mode, continuous scrolling toggle, show introductions toggle
- `lib/src/features/reader/application/current_chapter_provider.dart` — resolves the currently selected chapter from the loaded book list

All user settings are persisted to `SharedPreferences` inside their respective `StateNotifier` classes.

---

## Key Files for Common Tasks

| Task | File |
| --- | --- |
| Bible loading and caching | `lib/src/features/library/data/app_bible_repository.dart` |
| Database schema and migrations | `lib/src/services/app_database.dart` |
| Reader state and providers | `lib/src/features/reader/application/bible_provider.dart` |
| App-side Bible data models | `lib/src/models/bible_models.dart` (exports split model files under `lib/src/models/bible_models/`) |
| Translation selection UI | `lib/src/features/library/presentation/versions_screen.dart` |
| Reference picker UI | `lib/src/features/reader/presentation/references_screen.dart` |
| Main reader UI | `lib/src/features/reader/presentation/` |
| Settings UI | `lib/src/features/settings/presentation/` |
| App routing | `lib/src/app.dart` |

---

## Parsing and Assets

- The single source of parsing logic is the `bible_parser_flutter` package. Do not add a second parser.
- Built-in translations are defined in `AppBibleRepository` with explicit asset paths. Asset paths must also be listed in `pubspec.yaml` under `assets`.
- Imported translations are stored by the user via file picker and tracked in the `Translations` Drift table.
- Format auto-detection is handled by `BibleParser.fromString()` — it inspects the XML root tag.

---

## Developer Workflow

```bash
# Install dependencies
flutter pub get

# Run on Linux desktop
flutter run -d linux

# Run tests
flutter test

# Regenerate Drift database code after schema changes
dart run build_runner build --delete-conflicting-outputs
```

If changing parser or package code, run `flutter pub get` for both packages and hot-restart the app.

---

## Conventions and Gotchas

- Prefer adding Riverpod providers for data access (thin UI → provider → repository → parser) rather than embedding logic in views.
- Use `FutureProvider.autoDispose` for per-chapter or per-verse fetches to release memory when navigating away.
- When adding a new translation, update both `availableTranslations` in `AppBibleRepository` and the `assets` list in `pubspec.yaml`. IDs must align exactly for asset lookup to work.
- Database migrations currently delete all tables on schema version bumps (known technical debt — see `TODO_STATUS.md`). Be careful when bumping `schemaVersion` in `app_database.dart`.
- App-side models in `bible_models.dart` duplicate the parser models with `Bible` prefixes (known technical debt). The top-level file now re-exports split model files from `lib/src/models/bible_models/`. Prefer keeping the two in sync manually until deduplication is done.
- Reference helpers (`_parseReferenceString`, book name → ID maps) should live in `lib/src/utils/` if used by more than one feature.
