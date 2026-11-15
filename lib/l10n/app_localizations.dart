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
