# Hymns Presentation

This folder holds the Hymns pages: the Hymns tab (book switcher, search, hymn
list and hymn view), the hymn book library, repository management, and the
legal / takedown page.

Data formats, the bundled-book build and the private hymn sources are
described in `tool/hymnals/README.md`. The architecture summary is in
`CONTEXT.md` (Hymns section).

## Pages

| Page | How to reach it | Route |
|---|---|---|
| Hymns tab | Bottom bar / side rail, 3rd tab (`HomeTabs.hymns`) | `/home` |
| Hymn books (library) | Hymns tab → library button, or book switcher → Manage hymn books | `/home/hymns/library` |
| Repositories | Library → server button, or Settings → Hymns → Manage repositories | `/home/hymns/repos` |
| Legal & takedown requests | Settings → Legal & takedown requests, or Repositories → gavel button | `/home/settings/legal` |
| One hymn (deep link) | `/home/hymns/<bookId>/<number>`, e.g. `/home/hymns/bhb/122` | redirects to `/home` with that hymn open |

## Files

- `hymns_tab.dart`
  - `HymnsTab`: the tab body. A search field over the result list, or the open
    hymn on phones, or both side by side at `kHymnsTwoPaneWidth` (840px) and
    wider, so the list keeps updating while a hymn stays open.
  - `HymnalTitleButton`: the app bar title (current book, tap to switch).
  - `hymnsTabActions`: app bar actions: favorites filter (with a count
    badge), sort (number / A–Z), library.
  - The home shell gets the title and actions through `_HomeTabDefinition`'s
    `titleWidget` and `actions`.
- `hymn_list_view.dart`
  - `HymnListView`: the results. Fixed-height rows built lazily (`itemExtent`)
    with the hymn number, title, first line (or author when the first line is
    the title) and a favorite star. One remembered scroll position per book.
- `hymn_detail_view.dart`
  - `HymnDetailView`: one hymn. Action bar (back on phones, previous/next,
    favorite, copy, and a menu with share, print, display settings, about this
    book), then the title, author/meter/tune, notes, verses, chorus, optional
    parts and the credit lines. Swipe left/right or the arrows move through
    the *current result list*. Text is selectable.
- `hymn_display_settings.dart`
  - `HymnDisplaySettingsPanel`: text size, chorus after every verse (off =
    once after verse 1, like the printed book), show author/meter/tune, show
    optional verses and choruses. The same panel is in the hymn view's sheet
    (`showHymnDisplaySettings`) and in Settings → Hymns.
- `hymnal_picker_sheet.dart`
  - `showHymnalPicker`: the quick book switcher from the tab title.
  - `hymnalSourceLabel`: "Included / Imported / Downloaded · N hymns".
- `hymnal_about_sheet.dart`
  - `showHymnalAboutSheet`: publisher, edition, ISBN, copyright, permission,
    source and hymn count, and **Report a copyright concern**. `TODO_`
    placeholder values are never shown.
- `report_options.dart`
  - `sendContentReport`: used by Report a copyright concern and the Legal
    page. Lets the sender choose **email** (`kAppTakedownEmail`,
    contact@joshuamc.ca, private) or a **GitHub issue** (`kAppTakedownContact`,
    public), both pre-filled. A book from a third-party repository goes
    straight to that repository's own contact instead. If no email app
    opens, the address is shown with a Copy button.
- `hymn_print.dart`
  - `printHymn` / `buildHymnPdf`: a one-hymn PDF (Gentium Plus font) sent to the
    system print dialog (`printing` package; the browser's print on web).
- `hymnal_library_screen.dart`
  - `HymnalLibraryScreen`: books on this device (open, about; rename and
    remove for non-bundled books), **Import a hymn book file** (JSON, plain
    or `.gz`, also on web), help links to the import and "make your own hymn
    book" guides, and books available from enabled repositories with
    download progress. Pull to refresh.
  - Import is two steps: `prepareImport` checks the file without saving it,
    then the name dialog asks for a name and optional short name
    (pre-filled from the book, or the file name for legacy files), then
    `completeImport` saves it. A book with the same id is replaced, and the
    dialog says so.
- `hymnal_name_dialog.dart`
  - `showHymnalNameDialog`: name + optional short name, used for import and
    rename. The stored name always wins over the title inside the file.
- `guide_links.dart`
  - `HymnGuideLink` / `openHymnGuide`: open the public guides in
    `bible-data/docs/` (URLs in `../data/content_reporting.dart`).
- `manage_repos_screen.dart`
  - `ManageReposScreen`: repositories, F-Droid style. The official one can be
    turned off but not removed. **Add repository** checks the address
    (https only; http only for localhost testing), then shows a third-party
    disclaimer that must be ticked before the repository is saved. Removing a
    repository also removes the books downloaded from it.
  - "How repositories work, and how to make your own" (on the screen and in
    the Add repository dialog) opens `kRepositoriesGuideUrl`
    (`../data/content_reporting.dart`): `bible-data/docs/repositories.md` on
    GitHub, which documents both file formats for repository makers.
- `legal_takedown_screen.dart`
  - `LegalTakedownScreen`: what the app distributes (bundled books, with
    permission), what it doesn't (third-party repositories, imported files),
    and how rights holders request removal.

State lives in `../application/view_models/`:

- `hymnal_view_models.dart`: selected book, parsed book, query, sort,
  favorites, the result list, the open hymn.
- `hymn_settings_view_model.dart`: display settings.
- `hymnal_library_view_models.dart`: repositories, repository indexes, downloads,
  import and remove.
- `../application/hymn_links.dart`: opens a hymn from the deep link.

## How the Hymns tab keeps its place

The home shell rebuilds a tab from scratch every time you switch to it, so
**nothing the user would expect to survive a tab switch lives in widget
state**. The book, query, sort, favorites filter and open hymn are all
providers; the list's scroll position uses a `PageStorageKey` per book. Only
the search field's text controller is widget state, and it is re-seeded from
`hymnQueryProvider`.

On phones the open hymn is not a pushed route: `HymnsTab` shows either the
list or the hymn. Back (and Android's predictive back) closes the hymn
through `PopScope`. Typing in the search field closes the hymn and shows the
live results.

## Copyright on every copy

Copy, share and print all go through `formatHymnAsText` / `buildHymnPdf`,
which end with `hymnCreditLines`: the hymn's own copyright line (if any),
"From <book> (#n)", and the book's copyright and permission notice. The
screen shows the same lines under the lyrics. This is a condition of the
publisher's permission, so keep it on every new way of exporting a hymn.

## Rules when changing these pages

1. **Chorus placement is decided only in `layoutHymn`** (`../data/hymn_layout.dart`).
   The screen, copy, share and print all call it; don't re-implement it in a
   widget.
2. **New exports of hymn text must append `hymnCreditLines`.**
3. **New state the user expects to keep across tab switches goes in a
   provider**, not in a `State` class.
4. **New screens get a route under `/home/hymns/`** in `lib/src/app.dart`, and
   use `context.push` so the system back button returns to the tab.
5. **Every visible string goes in all five ARB files** (`lib/l10n/`), then
   `flutter gen-l10n` and `dart format lib/l10n`.
6. **Keep the list cheap:** fixed `itemExtent`, no per-row futures, no
   per-row providers beyond the favorites set. Search runs synchronously on
   each keystroke (a few milliseconds even for 1,200 hymns), so don't make it
   async.
7. **Never put hymn text in this public repo**, including test fixtures copied
   from real books. Tests use short made-up hymns.

## Tests

- `test/features/hymns/hymns_tab_test.dart`: phone layout (search, open a hymn,
  typing returns to the list), wide layout (hymn stays open while results
  update), favorites filter.
- `hymn_layout_test.dart`: chorus placement and the credit lines on copied
  text.
- `hymn_search_test.dart`, `hymnal_json_codec_test.dart`,
  `hymnal_repository_test.dart`, `content_repo_service_test.dart`: search,
  both file formats, import/download/withdrawal, repositories.
- `bundled_hymnals_test.dart`: the bundled books parse and carry their legal
  text (release gate). Skipped when the assets aren't built.

## Troubleshooting

- **No hymn books on the Hymns tab, or "This hymn book could not be opened".**
  The bundled assets aren't built. Run `make hymnals` (needs access to the
  private `PopGTN/basic_bible_hymnals` submodule), then do a full restart.
- **A rebuilt book doesn't appear or shows old text.** Stop the app and run
  it again; hot reload doesn't reload the parsed book (it's cached in
  `HymnalRepository`).
- **The official repository shows "Could not load this repository".** Its
  index (`bible-data/catalog/production/hymnals.json`) isn't published to
  `main` yet, or the device is offline with no cached copy.
