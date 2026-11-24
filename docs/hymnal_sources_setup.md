# Private hymnal sources (submodule) — setup and workflow

The full text of the bundled hymn books (The Believers Hymn Book and The New
Believers Hymnbook) is **not** stored in this public repository. It lives in
the private repository **`PopGTN/basic_bible_hymnals`**, which is mounted here
as a git submodule at `tool/hymnals/sources`. The app's bundled hymn files
(`assets/hymnals/*.json.gz`) are generated from it and are gitignored.

**Why:** John Ritchie Ltd gave permission (2025-11-06) to include both books
*in the app*: a free, non-commercial app. A public GitHub repository holding
the complete books is distribution outside the app, which the permission
doesn't cover. The NBHB text was also prepared from a PDF the publisher sent
on condition that it is used only for the app and not shared with anyone
else. The permission record is in `bible-data/licenses/hymnals/`.

## What lives where

| Where | What | Public? |
|---|---|---|
| `PopGTN/basic_bible_hymnals` (mounted at `tool/hymnals/sources/`) | `bhb.source.json`, `nbhb.source.json`: the raw hymn text | **Private** |
| `tool/hymnals/build_hymnal.dart` | The build tool | Public |
| `tool/hymnals/<id>.meta.json` | Book details, copyright and permission wording, `rightsRules` | Public |
| `tool/hymnals/<id>.overrides.json` | Hand-reviewed fixes (typos, line breaks, notes). Contains a few short lyric lines only. | Public |
| `assets/hymnals/<id>.json.gz` | Built hymn books shipped in the app | **Generated, gitignored** |
| `assets/hymnals/README.md` | Keeps the asset folder in git so builds work without the books | Public |
| `.gitmodules` | Points `tool/hymnals/sources` at the private repo | Public (the URL only) |

The book format and build tool are described in `tool/hymnals/README.md`.

## Set up on a new computer

You need read access to `PopGTN/basic_bible_hymnals` (you own it; anyone
else must be added as a collaborator on GitHub).

1. **Sign git in to GitHub**, because the submodule is private and is fetched
   over HTTPS. The easiest way is the GitHub CLI:

   ```sh
   gh auth login        # choose GitHub.com, HTTPS, and "Login with a web browser"
   gh auth setup-git    # lets git use that login
   ```

   (A credential manager or a personal access token with `repo` access works
   too.)

2. **Clone with submodules:**

   ```sh
   git clone --recurse-submodules https://github.com/PopGTN/basic_bible.git
   ```

   Already cloned? Fetch the submodule into the existing clone:

   ```sh
   git submodule update --init tool/hymnals/sources
   ```

3. **Build the hymn books and run the app:**

   ```sh
   make hymnals          # fetches the submodule and builds assets/hymnals/*.json.gz
   flutter run
   ```

4. **Recommended:** stop git from pushing a pointer to submodule work you
   haven't pushed yet (see [Safety rules](#safety-rules)):

   ```sh
   git config push.recurseSubmodules check
   ```

## Building without access (other contributors, CI)

Everything still builds and runs without the private repo:

- `flutter run` / `flutter build` work. The app simply has **no bundled hymn
  books**: `HymnalRepository` only lists bundled books whose asset is in the
  build (asset-manifest check), and the Hymns tab still works with imported or
  downloaded books.
- `flutter test` passes: `bundled_hymnals_test.dart` is **skipped** (it says
  "not built (needs the private submodule; run make hymnals)").
- `make hymnals` fails at the `git submodule update` step with a "Repository
  not found" or authentication error. That's expected without access.

## Everyday workflows

### Change the hymn text (the source files)

The submodule is its own git repository: commit there first, then record the
new version in this repo.

```sh
cd tool/hymnals/sources
git checkout main            # a fresh submodule is on a "detached HEAD"; switch to main first
# …edit bhb.source.json / nbhb.source.json…
git commit -am "Fix line breaks in NBHB 412"
git push                     # pushes to the PRIVATE repo

cd ../../..                  # back to basic_bible
make hymnals                 # rebuild, then read build/hymnals/<id>.report.txt
flutter test test/features/hymns
git add tool/hymnals/sources # records the new submodule commit (a pointer, no text)
git commit -m "Update hymnal sources"
```

Prefer fixing things in `tool/hymnals/<id>.overrides.json` when it's a
correction to a single hymn: overrides are reviewed in this repo and survive
a fresh copy of the source.

### Change book details, copyright wording or fixes

Those are in the public files `tool/hymnals/<id>.meta.json` and
`<id>.overrides.json`; the submodule doesn't change. Edit, run
`make hymnals`, check the report, run the tests, commit.

### Get someone else's changes

```sh
git pull --recurse-submodules
make hymnals
```

(Plain `git pull` updates the pointer but not the files; run
`git submodule update` afterwards if you forget.)

### Add another bundled hymn book

Only with written permission covering in-app distribution, recorded in
`bible-data/licenses/hymnals/<id>.md` first. Then:

1. Add `<id>.source.json` to the **private** repo (commit and push there).
2. Add `tool/hymnals/<id>.meta.json` (and overrides if needed) here.
3. Add the book to `kBundledHymnals` in
   `lib/src/features/hymns/data/hymnal_repository.dart` and to the `hymnals`
   target in the `makefile` (`build_hymnal.dart bhb nbhb <id>`).
4. `make hymnals`, review the report, run the tests, commit.

## Releasing

- **Android, iOS, Windows, macOS, Linux:** run `make hymnals` before
  `flutter build …`. A build without it ships with no bundled hymn books.
- **Web via `make deploy`:** it runs `make hymnals` first, so the hymn books
  are included. The built site serves the hymn files publicly (any web app
  sends its data to the browser). **Hold web releases until John Ritchie Ltd
  confirms the permission covers the web version**: the original request
  named Android, Windows and Mac.
- **Web via GitHub Actions** (`.github/workflows/deploy_web.yml`, on every
  push to `main`): the workflow checks out **without** submodules and has no
  access to the private repo, so that site is built **without bundled hymn
  books**. That is deliberate for now.

  To include them later (once web is confirmed):
  1. Create a read-only **deploy key** for `basic_bible_hymnals` (Settings →
     Deploy keys) and save its private key in `basic_bible` as an Actions
     secret, e.g. `HYMNALS_DEPLOY_KEY`.
  2. In the workflow, after Checkout, add a step that loads the key with an
     SSH agent action, runs `git submodule update --init
     tool/hymnals/sources` using the SSH form of the URL, then
     `dart run tool/hymnals/build_hymnal.dart bhb nbhb`.
  3. Never print the sources or upload them as an artifact other than the
     built site.

## Safety rules

1. **Never commit hymn text to this public repo.** That means
   `tool/hymnals/sources/*.json` (they belong to the submodule) and
   `assets/hymnals/*.json.gz` (gitignored). If `git status` ever lists them
   as new files, stop and check the submodule and `.gitignore`.
2. **Never make `basic_bible_hymnals` public**, and only add collaborators
   who need the text to build the app.
3. **Push the submodule before the parent.** If this repo records a
   submodule commit that only exists on your computer, everyone else gets
   "reference is not a tree" errors. `git config push.recurseSubmodules
   check` makes `git push` refuse in that case.
4. **Don't push the local branch `backup/Hymnbooks-added-before-private-split`.**
   It predates the move to the submodule and still contains the full text.
   Delete it once you're confident: `git branch -D
   backup/Hymnbooks-added-before-private-split`. Avoid `git push --all`.
5. Test fixtures use short made-up hymns, never text copied from the real
   books.

## Troubleshooting

| Problem | Cause and fix |
|---|---|
| `make hymnals`: "Repository not found" or asks for a password | Git isn't signed in to an account with access. Run `gh auth login` and `gh auth setup-git`, or ask for access to `PopGTN/basic_bible_hymnals`. |
| `tool/hymnals/sources/` is empty | The submodule hasn't been fetched: `git submodule update --init tool/hymnals/sources`. |
| "fatal: reference is not a tree" / "not our ref" | This repo points at a submodule commit that was never pushed. Push it from `tool/hymnals/sources` (on the computer that made it). |
| Edits in `tool/hymnals/sources` "disappeared" after `git submodule update` | You committed on a detached HEAD. Find the commit with `git -C tool/hymnals/sources reflog`, then `git checkout main` and `git cherry-pick <commit>` in the submodule. Always `git checkout main` before editing. |
| No hymn books in the app | The assets weren't built: `make hymnals`, then stop and run the app again. |
| `bundled_hymnals_test` shows as skipped | Same: the assets aren't built. |
| `bundled_hymnals_test` fails "no TODO_ placeholders remain" | A `TODO_` value is back in `tool/hymnals/<id>.meta.json`. Fill it in and run `make hymnals`. |
| `git status` shows `modified: tool/hymnals/sources (new commits)` | The submodule moved to a newer commit. Commit it here (`git add tool/hymnals/sources`) if that's intended, or `git submodule update` to go back. |
