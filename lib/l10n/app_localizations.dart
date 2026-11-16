// GENERATED FILE - DO NOT EDIT. Run `python3 tool/gen_l10n.py`.
// Source: lib/l10n/app_en.arb
import 'package:basic_bible/src/features/localization/language_pack_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Runtime-resolved UI strings. Lookup order: downloaded language pack,
/// bundled English, then the key itself.
class AppLocalizations {
  AppLocalizations(this.locale)
    : _strings = LanguagePackStore.strings(locale.languageCode),
      _fallback = LanguagePackStore.strings('en');

  final Locale locale;
  final Map<String, String> _strings;
  final Map<String, String> _fallback;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// Locales the framework (Material/Cupertino) widgets can be built for.
  /// App strings themselves are not limited to this list.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
    Locale('zh'),
  ];

  static AppLocalizations? of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String _t(String key, [Map<String, Object>? args]) {
    var text = _strings[key] ?? _fallback[key] ?? key;
    if (args != null) {
      args.forEach((name, value) {
        text = text.replaceAll('{$name}', '$value');
      });
    }
    return text;
  }

  /// Home
  String get home => _t('home');

  /// Bible
  String get bible => _t('bible');

  /// About
  String get about => _t('about');

  /// Settings
  String get settings => _t('settings');

  /// Logout
  String get logout => _t('logout');

  /// Go to Other Page
  String get goToOther => _t('goToOther');

  /// This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart....
  String get aboutDescription => _t('aboutDescription');

  /// Language
  String get language => _t('language');

  /// Theme
  String get theme => _t('theme');

  /// Login
  String get login => _t('login');

  /// English
  String get english => _t('english');

  /// Spanish
  String get spanish => _t('spanish');

  /// French
  String get french => _t('french');

  /// German
  String get german => _t('german');

  /// Menu
  String get menu => _t('menu');

  /// View footnotes and references
  String get readerFootnotesTooltip => _t('readerFootnotesTooltip');

  /// View personal notes
  String get readerNotesTooltip => _t('readerNotesTooltip');

  /// Saved Note
  String get savedNoteLabel => _t('savedNoteLabel');

  /// Saved Notes
  String get savedNotesLabel => _t('savedNotesLabel');

  /// Open
  String get openAction => _t('openAction');

  /// Edit
  String get editAction => _t('editAction');

  /// Versions
  String get versionsTitle => _t('versionsTitle');

  /// Search translations
  String get searchTranslationsTooltip => _t('searchTranslationsTooltip');

  /// Import Bible File
  String get importBibleFileAction => _t('importBibleFileAction');

  /// Clear translation cache
  String get clearTranslationCacheAction => _t('clearTranslationCacheAction');

  /// Clear translation cache?
  String get clearTranslationCacheTitle => _t('clearTranslationCacheTitle');

  /// This removes downloaded translation files, imported source snapshots, and stale translation regis...
  String get clearTranslationCacheDescription => _t('clearTranslationCacheDescription');

  /// Clear cache
  String get clearCacheAction => _t('clearCacheAction');

  /// Translation cache cleared.
  String get clearedTranslationCacheMessage => _t('clearedTranslationCacheMessage');

  /// Could not clear translation cache: {error}
  String couldNotClearTranslationCache(Object error) => _t('couldNotClearTranslationCache', {'error': error});

  /// Bible files
  String get translationsFileTypeLabel => _t('translationsFileTypeLabel');

  /// Unable to load translations: {error}
  String unableToLoadTranslations(Object error) => _t('unableToLoadTranslations', {'error': error});

  /// Could not switch translation: {error}
  String couldNotSwitchTranslation(Object error) => _t('couldNotSwitchTranslation', {'error': error});

  /// Imported {name}.
  String importedTranslationMessage(Object name) => _t('importedTranslationMessage', {'name': name});

  /// Import failed: {error}
  String importFailedMessage(Object error) => _t('importFailedMessage', {'error': error});

  /// Delete {name}?
  String deleteTranslationTitle(Object name) => _t('deleteTranslationTitle', {'name': name});

  /// This removes the imported Bible from the app library and cache. The original file on disk will no...
  String get deleteImportedTranslationDescription => _t('deleteImportedTranslationDescription');

  /// Cancel
  String get cancelAction => _t('cancelAction');

  /// Delete
  String get deleteAction => _t('deleteAction');

  /// Deleted {name}.
  String deletedTranslationMessage(Object name) => _t('deletedTranslationMessage', {'name': name});

  /// Could not delete translation: {error}
  String couldNotDeleteTranslation(Object error) => _t('couldNotDeleteTranslation', {'error': error});

  /// Remove {name} download?
  String removeDownloadedTranslationTitle(Object name) => _t('removeDownloadedTranslationTitle', {'name': name});

  /// This removes the downloaded Bible from local app storage. It will stay in the library as a downlo...
  String get removeDownloadedTranslationDescription => _t('removeDownloadedTranslationDescription');

  /// Remove
  String get removeAction => _t('removeAction');

  /// Removed local download for {name}.
  String removedLocalDownloadMessage(Object name) => _t('removedLocalDownloadMessage', {'name': name});

  /// Could not remove download: {error}
  String couldNotRemoveDownload(Object error) => _t('couldNotRemoveDownload', {'error': error});

  /// More actions
  String get moreActionsTooltip => _t('moreActionsTooltip');

  /// Delete import
  String get deleteImportAction => _t('deleteImportAction');

  /// Remove download
  String get removeDownloadAction => _t('removeDownloadAction');

  /// Available offline
  String get availableOfflineTooltip => _t('availableOfflineTooltip');

  /// Download translation
  String get downloadTranslationTooltip => _t('downloadTranslationTooltip');

  /// Audio options
  String get audioOptionsTooltip => _t('audioOptionsTooltip');

  /// Bundled
  String get bundledTranslationSource => _t('bundledTranslationSource');

  /// Downloaded
  String get downloadedTranslationSource => _t('downloadedTranslationSource');

  /// Downloadable
  String get downloadableTranslationSource => _t('downloadableTranslationSource');

  /// Imported
  String get importedTranslationSource => _t('importedTranslationSource');

  /// Import Bible
  String get importBibleTitle => _t('importBibleTitle');

  /// Unable to prepare import: {error}
  String unableToPrepareImport(Object error) => _t('unableToPrepareImport', {'error': error});

  /// Translation Details
  String get translationDetailsTitle => _t('translationDetailsTitle');

  /// Set the library name, abbreviation, language code, and description before the import is saved.
  String get translationDetailsDescription => _t('translationDetailsDescription');

  /// Name
  String get translationNameLabel => _t('translationNameLabel');

  /// World English Bible
  String get translationNameHint => _t('translationNameHint');

  /// Enter a translation name.
  String get translationNameRequired => _t('translationNameRequired');

  /// Abbreviation
  String get translationAbbreviationLabel => _t('translationAbbreviationLabel');

  /// WEB
  String get translationAbbreviationHint => _t('translationAbbreviationHint');

  /// Used the same way built-in abbreviations like KJV and ASV are used.
  String get translationAbbreviationHelp => _t('translationAbbreviationHelp');

  /// Enter an abbreviation.
  String get translationAbbreviationRequired => _t('translationAbbreviationRequired');

  /// That abbreviation is already in use.
  String get translationAbbreviationTaken => _t('translationAbbreviationTaken');

  /// Language code
  String get translationLanguageCodeLabel => _t('translationLanguageCodeLabel');

  /// en
  String get translationLanguageCodeHint => _t('translationLanguageCodeHint');

  /// Use a short code like en, es, fr, or de.
  String get translationLanguageCodeHelp => _t('translationLanguageCodeHelp');

  /// Enter a language code.
  String get translationLanguageCodeRequired => _t('translationLanguageCodeRequired');

  /// Description
  String get translationDescriptionLabel => _t('translationDescriptionLabel');

  /// Imported from my_local_bible.xml or my_translation.sqlite
  String get translationDescriptionHint => _t('translationDescriptionHint');

  /// Importing...
  String get importingAction => _t('importingAction');

  /// Import Translation
  String get importTranslationAction => _t('importTranslationAction');

  /// Detected format: {format}
  String detectedFormatLabel(Object format) => _t('detectedFormatLabel', {'format': format});

  /// Books found: {count}
  String booksFoundLabel(int count) => _t('booksFoundLabel', {'count': count});

  /// Search translations...
  String get searchTranslationsHint => _t('searchTranslationsHint');

  /// Downloaded
  String get downloadedSectionHeader => _t('downloadedSectionHeader');

  /// Available
  String get availableSectionHeader => _t('availableSectionHeader');

  /// Download
  String get downloadAction => _t('downloadAction');

  /// Open for session
  String get openForSessionAction => _t('openForSessionAction');

  /// {name} opened for this session.
  String openedForSessionMessage(Object name) => _t('openedForSessionMessage', {'name': name});

  /// Could not open translation: {error}
  String couldNotOpenTranslation(Object error) => _t('couldNotOpenTranslation', {'error': error});

  /// {name} downloaded.
  String downloadedTranslationMessage(Object name) => _t('downloadedTranslationMessage', {'name': name});

  /// Could not download translation: {error}
  String couldNotDownloadTranslation(Object error) => _t('couldNotDownloadTranslation', {'error': error});

  /// Importing local Bible files is not available in the browser yet.
  String get importNotAvailableOnWeb => _t('importNotAvailableOnWeb');

  /// Language
  String get languageFilterLabel => _t('languageFilterLabel');

  /// All languages
  String get allLanguagesOption => _t('allLanguagesOption');

  /// Select language
  String get selectLanguageTitle => _t('selectLanguageTitle');

  /// Device language
  String get languageDeviceDefault => _t('languageDeviceDefault');

  /// Downloading…
  String get languageDownloading => _t('languageDownloading');

  /// Couldn't download {language}. Check your connection and try again.
  String languageDownloadFailed(Object language) => _t('languageDownloadFailed', {'language': language});

  /// Available offline
  String get languageAvailableOffline => _t('languageAvailableOffline');

  /// Downloads when selected
  String get languageNeedsDownload => _t('languageNeedsDownload');

  /// Retry
  String get retryAction => _t('retryAction');

  /// App Startup
  String get settingsAppStartup => _t('settingsAppStartup');

  /// Open Bible Tab By Default
  String get settingsOpenBibleTab => _t('settingsOpenBibleTab');

  /// Start on the Bible page instead of the Home tab when the app opens.
  String get settingsOpenBibleTabDesc => _t('settingsOpenBibleTabDesc');

  /// Require Dummy Login
  String get settingsRequireLogin => _t('settingsRequireLogin');

  /// Keep the sample login screen turned on before entering the app.
  String get settingsRequireLoginDesc => _t('settingsRequireLoginDesc');

  /// Bible Viewer
  String get settingsBibleViewer => _t('settingsBibleViewer');

  /// Show Introductions
  String get settingsShowIntroductions => _t('settingsShowIntroductions');

  /// Show book introductions and front-matter blocks when they exist.
  String get settingsShowIntroductionsDesc => _t('settingsShowIntroductionsDesc');

  /// Bold Divine Name (LORD)
  String get settingsBoldDivineName => _t('settingsBoldDivineName');

  /// Display the divine name (LORD / Yahweh) in bold. Off by default — turn on if your translation mar...
  String get settingsBoldDivineNameDesc => _t('settingsBoldDivineNameDesc');

  /// Bold Words of Jesus
  String get settingsBoldWordsOfJesus => _t('settingsBoldWordsOfJesus');

  /// Show the words of Jesus in bold as well as red. Off by default, like most red-letter Bibles.
  String get settingsBoldWordsOfJesusDesc => _t('settingsBoldWordsOfJesusDesc');

  /// Underline Proper Names
  String get settingsUnderlineProperNames => _t('settingsUnderlineProperNames');

  /// Underline proper nouns when the source marks them.
  String get settingsUnderlineProperNamesDesc => _t('settingsUnderlineProperNamesDesc');

  /// Underline Word Tags
  String get settingsUnderlineWordTags => _t('settingsUnderlineWordTags');

  /// Underline source-tagged word metadata such as Strong's-linked words. Off by default.
  String get settingsUnderlineWordTagsDesc => _t('settingsUnderlineWordTagsDesc');

  /// Bracket Translator Additions
  String get settingsBracketAdditions => _t('settingsBracketAdditions');

  /// Show translator-supplied words in [brackets]. Turn this off if you prefer italic-only rendering.
  String get settingsBracketAdditionsDesc => _t('settingsBracketAdditionsDesc');

  /// Use Source Bold Styling
  String get settingsSourceBold => _t('settingsSourceBold');

  /// Respect bold-style emphasis from the source format for tags such as keywords and explicit bold sp...
  String get settingsSourceBoldDesc => _t('settingsSourceBoldDesc');

  /// Show Source Details
  String get settingsSourceDetails => _t('settingsSourceDetails');

  /// Show study metadata such as Strong's numbers, lemmas, morphology, and quote speakers in the verse...
  String get settingsSourceDetailsDesc => _t('settingsSourceDetailsDesc');

  /// Enable Verse Selector
  String get settingsVerseSelector => _t('settingsVerseSelector');

  /// Allow the reference picker to drill into verse selection instead of only picking chapters. Off by...
  String get settingsVerseSelectorDesc => _t('settingsVerseSelectorDesc');

  /// Notes
  String get settingsNotes => _t('settingsNotes');

  /// Confirm Before Removing Linked Verses
  String get settingsConfirmUnlink => _t('settingsConfirmUnlink');

  /// Show a confirmation dialog before unlinking a verse from a note.
  String get settingsConfirmUnlinkDesc => _t('settingsConfirmUnlinkDesc');

  /// Show Notes On Other Translations
  String get settingsNotesAcrossTranslations => _t('settingsNotesAcrossTranslations');

  /// Show notes and highlights on a verse even if they were saved while reading a different translatio...
  String get settingsNotesAcrossTranslationsDesc => _t('settingsNotesAcrossTranslationsDesc');

  /// Advanced
  String get settingsAdvanced => _t('settingsAdvanced');

  /// Developer tools — export translation databases
  String get settingsAdvancedDesc => _t('settingsAdvancedDesc');

  /// Open-source licenses
  String get settingsLicenses => _t('settingsLicenses');

  /// Libraries and code used by this app
  String get settingsLicensesDesc => _t('settingsLicensesDesc');

  /// Save
  String get saveAction => _t('saveAction');

  /// Clear
  String get clearAction => _t('clearAction');

  /// Back
  String get backTooltip => _t('backTooltip');

  /// {title} is not built yet.
  String comingSoonTitle(Object title) => _t('comingSoonTitle', {'title': title});

  /// This menu entry is now routed intentionally instead of pointing to a missing screen.
  String get comingSoonBody => _t('comingSoonBody');

  /// Other Page
  String get otherPageTitle => _t('otherPageTitle');

  /// This page is not part of the bottom tabs
  String get otherPageBody => _t('otherPageBody');

  /// Sign in with Google
  String get signInWithGoogle => _t('signInWithGoogle');

  /// Previous chapter
  String get previousChapterTooltip => _t('previousChapterTooltip');

  /// Next chapter
  String get nextChapterTooltip => _t('nextChapterTooltip');

  /// Preview unavailable for this reference.
  String get previewUnavailable => _t('previewUnavailable');

  /// Open in Bible
  String get openInBibleAction => _t('openInBibleAction');

  /// Cross-References
  String get crossReferencesTitle => _t('crossReferencesTitle');

  /// No cross-references available for this verse.
  String get noCrossReferences => _t('noCrossReferences');

  /// Could not parse reference: {reference}
  String couldNotParseReference(Object reference) => _t('couldNotParseReference', {'reference': reference});

  /// No reference history yet.
  String get noReferenceHistory => _t('noReferenceHistory');

  /// Recent References
  String get recentReferencesTitle => _t('recentReferencesTitle');

  /// References
  String get referencesTitle => _t('referencesTitle');

  /// History
  String get historyTooltip => _t('historyTooltip');

  /// Search books
  String get searchBooksHint => _t('searchBooksHint');

  /// Pick a chapter.
  String get pickChapterPrompt => _t('pickChapterPrompt');

  /// Pick a chapter and optionally a verse.
  String get pickChapterOrVersePrompt => _t('pickChapterOrVersePrompt');

  /// Chapters
  String get chaptersLabel => _t('chaptersLabel');

  /// Go to {reference}
  String goToReferenceAction(Object reference) => _t('goToReferenceAction', {'reference': reference});

  /// Verses in {chapter}
  String versesInChapterLabel(Object chapter) => _t('versesInChapterLabel', {'chapter': chapter});

  /// Read
  String get readLabel => _t('readLabel');

  /// Search the Bible
  String get searchBibleHint => _t('searchBibleHint');

  /// Type a word or phrase to search.
  String get searchPrompt => _t('searchPrompt');

  /// Search failed: {error}
  String searchFailed(Object error) => _t('searchFailed', {'error': error});

  /// No verses found.
  String get noVersesFound => _t('noVersesFound');

  /// Showing the first {count} verses. Add words to narrow it down.
  String searchShowingFirst(Object count) => _t('searchShowingFirst', {'count': count});

  /// {count} verse
  String searchVerseCountOne(Object count) => _t('searchVerseCountOne', {'count': count});

  /// {count} verses
  String searchVerseCountMany(Object count) => _t('searchVerseCountMany', {'count': count});

  /// System
  String get themeSystem => _t('themeSystem');

  /// Light
  String get themeLight => _t('themeLight');

  /// Dark
  String get themeDark => _t('themeDark');

  /// Soft
  String get themeSoft => _t('themeSoft');

  /// Black
  String get themeBlack => _t('themeBlack');

  /// White
  String get themeWhite => _t('themeWhite');

  /// Blue
  String get themeBlue => _t('themeBlue');

  /// Red
  String get themeRed => _t('themeRed');

  /// Translation not available.
  String get translationNotAvailable => _t('translationNotAvailable');

  /// Only standalone highlights can be removed here. Edit a note to change its highlight.
  String get onlyStandaloneHighlightsRemovable => _t('onlyStandaloneHighlightsRemovable');

  /// Notes can be linked to up to {max} verses at once. Please select a smaller range.
  String noteVerseLimit(Object max) => _t('noteVerseLimit', {'max': max});

  /// Highlight
  String get highlightAction => _t('highlightAction');

  /// Note
  String get noteAction => _t('noteAction');

  /// Copy
  String get copyAction => _t('copyAction');

  /// Share
  String get shareAction => _t('shareAction');

  /// Note highlights are edited from the note itself.
  String get noteHighlightsEditedFromNote => _t('noteHighlightsEditedFromNote');

  /// Chapter not found
  String get chapterNotFound => _t('chapterNotFound');

  /// Error: {error}
  String errorMessage(Object error) => _t('errorMessage', {'error': error});

  /// Failed to load Bible: {error}
  String failedToLoadBible(Object error) => _t('failedToLoadBible', {'error': error});

  /// Could not load this translation: {error}
  String couldNotLoadTranslation(Object error) => _t('couldNotLoadTranslation', {'error': error});

  /// Translation for this pane
  String get translationForPaneTooltip => _t('translationForPaneTooltip');

  /// Source details
  String get sourceDetailsTitle => _t('sourceDetailsTitle');

  /// Quote speaker
  String get quoteSpeakerLabel => _t('quoteSpeakerLabel');

  /// Lemma
  String get lemmaLabel => _t('lemmaLabel');

  /// Morphology
  String get morphologyLabel => _t('morphologyLabel');

  /// License
  String get licenseLabel => _t('licenseLabel');

  /// Source
  String get sourceLabel => _t('sourceLabel');

  /// Delete?
  String get deleteConfirmTitle => _t('deleteConfirmTitle');

  /// This note or highlight will be permanently removed.
  String get deleteNoteOrHighlightBody => _t('deleteNoteOrHighlightBody');

  /// Add Note
  String get addNoteAction => _t('addNoteAction');

  /// View
  String get viewAction => _t('viewAction');

  /// Introduction
  String get introductionLabel => _t('introductionLabel');

  /// "{preferred}" is not installed. Opening in {fallback}.
  String notesOpeningFallbackNamed(Object preferred, Object fallback) => _t('notesOpeningFallbackNamed', {'preferred': preferred, 'fallback': fallback});

  /// "{preferred}" is not installed. Opening in current translation.
  String notesOpeningFallbackCurrent(Object preferred) => _t('notesOpeningFallbackCurrent', {'preferred': preferred});

  /// the current translation
  String get theCurrentTranslation => _t('theCurrentTranslation');

  /// Failed to open reference.
  String get failedToOpenReference => _t('failedToOpenReference');

  /// No saved notes or highlights yet. Select a verse in the reader to create one.
  String get notesEmpty => _t('notesEmpty');

  /// No notes match your search or filters.
  String get notesNoMatches => _t('notesNoMatches');

  /// Clear filters
  String get clearFiltersAction => _t('clearFiltersAction');

  /// This note and all its linked verses will be permanently removed.
  String get deleteNoteBody => _t('deleteNoteBody');

  /// Failed to delete note.
  String get failedToDeleteNote => _t('failedToDeleteNote');

  /// Failed to load notes: {error}
  String failedToLoadNotes(Object error) => _t('failedToLoadNotes', {'error': error});

  /// Notes
  String get notesTitle => _t('notesTitle');

  /// Search notes
  String get searchNotesTooltip => _t('searchNotesTooltip');

  /// Search notes, tags, or a verse like John 3:16
  String get searchNotesHint => _t('searchNotesHint');

  /// Type
  String get filterTypeLabel => _t('filterTypeLabel');

  /// Translation
  String get filterTranslationLabel => _t('filterTranslationLabel');

  /// Tags
  String get filterTagsLabel => _t('filterTagsLabel');

  /// Open in Reader
  String get openInReaderAction => _t('openInReaderAction');

  /// Note
  String get noteTypeNote => _t('noteTypeNote');

  /// Highlight
  String get noteTypeHighlight => _t('noteTypeHighlight');

  /// Highlight only
  String get noteTypeHighlightOnly => _t('noteTypeHighlightOnly');

  /// Last modified
  String get dateLastModified => _t('dateLastModified');

  /// Created
  String get dateCreated => _t('dateCreated');

  /// Any time
  String get dateAnyTime => _t('dateAnyTime');

  /// Today
  String get dateToday => _t('dateToday');

  /// Past week
  String get datePastWeek => _t('datePastWeek');

  /// Past month
  String get datePastMonth => _t('datePastMonth');

  /// Past year
  String get datePastYear => _t('datePastYear');

  /// Created: {range}
  String dateButtonCreatedRange(Object range) => _t('dateButtonCreatedRange', {'range': range});

  /// Date: Created
  String get dateButtonCreated => _t('dateButtonCreated');

  /// Date
  String get dateButton => _t('dateButton');

  /// Show
  String get dateMenuShow => _t('dateMenuShow');

  /// By date (newest first)
  String get dateMenuSortBy => _t('dateMenuSortBy');

  /// Current translation is not available.
  String get currentTranslationUnavailable => _t('currentTranslationUnavailable');

  /// Failed to save note. Please try again.
  String get failedToSaveNote => _t('failedToSaveNote');

  /// Note
  String get noteFieldLabel => _t('noteFieldLabel');

  /// Write your note here.
  String get noteFieldHint => _t('noteFieldHint');

  /// Linked Verses
  String get linkedVersesTitle => _t('linkedVersesTitle');

  /// Primary Verse
  String get primaryVerseTitle => _t('primaryVerseTitle');

  /// Remove verse?
  String get removeVerseTitle => _t('removeVerseTitle');

  /// {reference} will be unlinked from this note.
  String removeVerseBody(Object reference) => _t('removeVerseBody', {'reference': reference});

  /// Add Verse
  String get addVerseAction => _t('addVerseAction');

  /// Connected Highlight
  String get connectedHighlightTitle => _t('connectedHighlightTitle');

  /// None
  String get highlightNone => _t('highlightNone');

  /// This note will keep a connected verse highlight on its primary verse.
  String get connectedHighlightBody => _t('connectedHighlightBody');

  /// Labels
  String get labelsLabel => _t('labelsLabel');

  /// Comma separated labels
  String get labelsHint => _t('labelsHint');

  /// Show less
  String get showLessAction => _t('showLessAction');

  /// Show all (+{count})
  String showAllAction(Object count) => _t('showAllAction', {'count': count});

  /// Prayer List
  String get menuPrayerList => _t('menuPrayerList');

  /// Verses of the Day
  String get menuVersesOfTheDay => _t('menuVersesOfTheDay');

  /// Donate
  String get menuDonate => _t('menuDonate');

  /// Help
  String get menuHelp => _t('menuHelp');

  /// GitHub Repository
  String get menuGithubRepository => _t('menuGithubRepository');

  /// Feature
  String get featureDefaultName => _t('featureDefaultName');

  /// Play Audio
  String get playAudioTooltip => _t('playAudioTooltip');

  /// Search
  String get searchTooltip => _t('searchTooltip');

  /// Reader options
  String get readerOptionsTooltip => _t('readerOptionsTooltip');

  /// Related Content
  String get relatedContentAction => _t('relatedContentAction');

  /// Fonts & Settings
  String get fontsAndSettingsAction => _t('fontsAndSettingsAction');

  /// Font
  String get fontLabel => _t('fontLabel');

  /// System Default
  String get fontSystemDefault => _t('fontSystemDefault');

  /// Continuous Scrolling
  String get continuousScrollingLabel => _t('continuousScrollingLabel');

  /// Document Mode
  String get documentModeLabel => _t('documentModeLabel');

  /// All Settings
  String get allSettingsAction => _t('allSettingsAction');

  /// Open Settings
  String get openSettingsAction => _t('openSettingsAction');

  /// Sync
  String get syncTitle => _t('syncTitle');

  /// Google sync is not available in the browser
  String get syncUnavailableWeb => _t('syncUnavailableWeb');

  /// Use the mobile or desktop app to sync notes.
  String get syncUnavailableWebDesc => _t('syncUnavailableWebDesc');

  /// Google sync is not configured for this build
  String get syncNotConfigured => _t('syncNotConfigured');

  /// OAuth client ids are missing — see docs/google_sync_setup.md.
  String get syncNotConfiguredDesc => _t('syncNotConfiguredDesc');

  /// Back up notes and highlights to your own Google Drive and sync them across your devices.
  String get syncSignInDesc => _t('syncSignInDesc');

  /// Sync mode
  String get syncModeTitle => _t('syncModeTitle');

  /// Automatic syncs after note changes and on app resume. Manual sync only runs when you tap Sync now.
  String get syncModeDesc => _t('syncModeDesc');

  /// Automatic
  String get syncModeAutomatic => _t('syncModeAutomatic');

  /// Manual
  String get syncModeManual => _t('syncModeManual');

  /// Syncing…
  String get syncing => _t('syncing');

  /// Not synced yet
  String get notSyncedYet => _t('notSyncedYet');

  /// Last synced {when}
  String lastSynced(Object when) => _t('lastSynced', {'when': when});

  /// just now
  String get syncJustNow => _t('syncJustNow');

  /// {count} min ago
  String syncMinutesAgo(Object count) => _t('syncMinutesAgo', {'count': count});

  /// {count} h ago
  String syncHoursAgo(Object count) => _t('syncHoursAgo', {'count': count});

  /// Sync now
  String get syncNowAction => _t('syncNowAction');

  /// Sign out
  String get signOutAction => _t('signOutAction');

  /// Notes exported.
  String get notesExported => _t('notesExported');

  /// Export failed: {error}
  String exportFailed(Object error) => _t('exportFailed', {'error': error});

  /// Import finished — all {total} notes were already up to date.
  String importUpToDate(Object total) => _t('importUpToDate', {'total': total});

  /// Imported {applied} of {total} notes.
  String importedNotesCount(Object applied, Object total) => _t('importedNotesCount', {'applied': applied, 'total': total});

  /// Imported {applied} of {total} notes ({upToDate} already up to date).
  String importedNotesCountWithUpToDate(Object applied, Object total, Object upToDate) => _t('importedNotesCountWithUpToDate', {'applied': applied, 'total': total, 'upToDate': upToDate});

  /// Removed {count} old deleted notes.
  String cleanupRemoved(Object count) => _t('cleanupRemoved', {'count': count});

  /// No old deleted notes needed cleanup yet.
  String get cleanupNothing => _t('cleanupNothing');

  /// Cleanup failed: {error}
  String cleanupFailed(Object error) => _t('cleanupFailed', {'error': error});

  /// Reset all notes?
  String get resetAllNotesTitle => _t('resetAllNotesTitle');

  /// This removes every saved note and highlight from this device only. Notes synced to Google Drive w...
  String get resetAllNotesSignedIn => _t('resetAllNotesSignedIn');

  /// This permanently deletes every saved note and highlight on this device.
  String get resetAllNotesLocal => _t('resetAllNotesLocal');

  /// Delete all
  String get deleteAllAction => _t('deleteAllAction');

  /// All notes deleted from this device.
  String get allNotesDeleted => _t('allNotesDeleted');

  /// Reset failed: {error}
  String resetFailed(Object error) => _t('resetFailed', {'error': error});

  /// Import failed: {error}
  String importFailedShort(Object error) => _t('importFailedShort', {'error': error});

  /// Calculating local note database size…
  String get noteStorageCalculating => _t('noteStorageCalculating');

  /// {active} active • {deleted} deleted tombstones
  String noteStorageDetail(Object active, Object deleted) => _t('noteStorageDetail', {'active': active, 'deleted': deleted});

  /// Note storage
  String get noteStorageTitle => _t('noteStorageTitle');

  /// Delete old deleted notes
  String get purgeDeletedNotesTitle => _t('purgeDeletedNotesTitle');

  /// Removes tombstones older than 30 days so storage stays tidy without deleting active notes.
  String get purgeDeletedNotesDesc => _t('purgeDeletedNotesDesc');

  /// Reset all saved notes
  String get resetAllSavedNotesTitle => _t('resetAllSavedNotesTitle');

  /// Clears every note and highlight from this device.
  String get resetAllSavedNotesDesc => _t('resetAllSavedNotesDesc');

  /// Export Notes
  String get exportNotesTitle => _t('exportNotesTitle');

  /// Import Notes
  String get importNotesTitle => _t('importNotesTitle');

  /// Not available in the browser.
  String get notAvailableInBrowser => _t('notAvailableInBrowser');

  /// Save all notes and highlights as a SQLite backup file.
  String get exportNotesDesc => _t('exportNotesDesc');

  /// Merge notes from a backup file. Never overwrites newer local edits.
  String get importNotesDesc => _t('importNotesDesc');

  /// Enter a full URL like https://example.com/catalog.json
  String get catalogUrlInvalid => _t('catalogUrlInvalid');

  /// Catalog URLs must use https:// (http:// is only allowed for localhost).
  String get catalogUrlMustBeHttps => _t('catalogUrlMustBeHttps');

  /// Translation catalog URL reset to default.
  String get catalogUrlReset => _t('catalogUrlReset');

  /// Translation catalog URL saved.
  String get catalogUrlSaved => _t('catalogUrlSaved');

  /// Could not save catalog URL: {error}
  String couldNotSaveCatalogUrl(Object error) => _t('couldNotSaveCatalogUrl', {'error': error});

  /// Could not reset catalog URL: {error}
  String couldNotResetCatalogUrl(Object error) => _t('couldNotResetCatalogUrl', {'error': error});

  /// Advanced
  String get advancedTitle => _t('advancedTitle');

  /// These tools are intended for development and debugging. Exported database files contain parsed Bi...
  String get advancedWarning => _t('advancedWarning');

  /// Export Translation Databases
  String get exportDatabasesTitle => _t('exportDatabasesTitle');

  /// Exports the SQLite file for a translation stored on this device. Download a translation from Tran...
  String get exportDatabasesDesc => _t('exportDatabasesDesc');

  /// Browser builds can read and cache translations, but exporting cached database files is not availa...
  String get exportWebUnavailable => _t('exportWebUnavailable');

  /// No downloaded translations to export.
  String get noDownloadedToExport => _t('noDownloadedToExport');

  /// Failed to load translations: {error}
  String failedToLoadTranslationsShort(Object error) => _t('failedToLoadTranslationsShort', {'error': error});

  /// Translation Catalog URL
  String get catalogUrlTitle => _t('catalogUrlTitle');

  /// Override the remote JSON catalog used to load available translations. Leave blank or tap Reset to...
  String get catalogUrlDesc => _t('catalogUrlDesc');

  /// Catalog URL
  String get catalogUrlLabel => _t('catalogUrlLabel');

  /// Using built-in default catalog endpoint.
  String get catalogUrlUsingDefault => _t('catalogUrlUsingDefault');

  /// Using custom catalog endpoint override.
  String get catalogUrlUsingCustom => _t('catalogUrlUsingCustom');

  /// Default: {url}
  String catalogUrlDefaultLine(Object url) => _t('catalogUrlDefaultLine', {'url': url});

  /// Reset To Default
  String get resetToDefaultAction => _t('resetToDefaultAction');

  /// Export completed for {name}.
  String exportCompletedFor(Object name) => _t('exportCompletedFor', {'name': name});

  /// Export
  String get exportAction => _t('exportAction');

  /// Free and open source under the Apache License 2.0. Bible texts are public domain; see the notice ...
  String get aboutLegalese => _t('aboutLegalese');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  // Packs can finish downloading after the first load.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}
