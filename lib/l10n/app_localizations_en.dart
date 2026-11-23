// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get bible => 'Bible';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get goToOther => 'Go to Other Page';

  @override
  String get aboutDescription => 'This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart. The app allows reading the Bible, taking notes, TTS support, and more. It is inspired by apps like YouVersion Bible but with extra features and improved UI.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get login => 'Login';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get french => 'French';

  @override
  String get german => 'German';

  @override
  String get menu => 'Menu';

  @override
  String get readerFootnotesTooltip => 'View footnotes and references';

  @override
  String get readerNotesTooltip => 'View personal notes';

  @override
  String get savedNoteLabel => 'Saved Note';

  @override
  String get savedNotesLabel => 'Saved Notes';

  @override
  String get openAction => 'Open';

  @override
  String get editAction => 'Edit';

  @override
  String get versionsTitle => 'Versions';

  @override
  String get searchTranslationsTooltip => 'Search translations';

  @override
  String get importBibleFileAction => 'Import Bible File';

  @override
  String get clearTranslationCacheAction => 'Clear translation cache';

  @override
  String get clearTranslationCacheTitle => 'Clear translation cache?';

  @override
  String get clearTranslationCacheDescription => 'This removes downloaded translation files, imported source snapshots, and stale translation registry entries from local app storage. Bundled translations will remain available.';

  @override
  String get clearCacheAction => 'Clear cache';

  @override
  String get clearedTranslationCacheMessage => 'Translation cache cleared.';

  @override
  String couldNotClearTranslationCache(Object error) {
    return 'Could not clear translation cache: $error';
  }

  @override
  String get translationsFileTypeLabel => 'Bible files';

  @override
  String unableToLoadTranslations(Object error) {
    return 'Unable to load translations: $error';
  }

  @override
  String couldNotSwitchTranslation(Object error) {
    return 'Could not switch translation: $error';
  }

  @override
  String importedTranslationMessage(Object name) {
    return 'Imported $name.';
  }

  @override
  String importFailedMessage(Object error) {
    return 'Import failed: $error';
  }

  @override
  String deleteTranslationTitle(Object name) {
    return 'Delete $name?';
  }

  @override
  String get deleteImportedTranslationDescription => 'This removes the imported Bible from the app library and cache. The original file on disk will not be deleted.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String deletedTranslationMessage(Object name) {
    return 'Deleted $name.';
  }

  @override
  String couldNotDeleteTranslation(Object error) {
    return 'Could not delete translation: $error';
  }

  @override
  String removeDownloadedTranslationTitle(Object name) {
    return 'Remove $name download?';
  }

  @override
  String get removeDownloadedTranslationDescription => 'This removes the downloaded Bible from local app storage. It will stay in the library as a downloadable option so you can download it again later.';

  @override
  String get removeAction => 'Remove';

  @override
  String removedLocalDownloadMessage(Object name) {
    return 'Removed local download for $name.';
  }

  @override
  String couldNotRemoveDownload(Object error) {
    return 'Could not remove download: $error';
  }

  @override
  String get moreActionsTooltip => 'More actions';

  @override
  String get deleteImportAction => 'Delete import';

  @override
  String get removeDownloadAction => 'Remove download';

  @override
  String get availableOfflineTooltip => 'Available offline';

  @override
  String get downloadTranslationTooltip => 'Download translation';

  @override
  String get audioOptionsTooltip => 'Audio options';

  @override
  String get bundledTranslationSource => 'Bundled';

  @override
  String get downloadedTranslationSource => 'Downloaded';

  @override
  String get downloadableTranslationSource => 'Downloadable';

  @override
  String get importedTranslationSource => 'Imported';

  @override
  String get importBibleTitle => 'Import Bible';

  @override
  String unableToPrepareImport(Object error) {
    return 'Unable to prepare import: $error';
  }

  @override
  String get translationDetailsTitle => 'Translation Details';

  @override
  String get translationDetailsDescription => 'Set the library name, abbreviation, language code, and description before the import is saved.';

  @override
  String get translationNameLabel => 'Name';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired => 'Enter a translation name.';

  @override
  String get translationAbbreviationLabel => 'Abbreviation';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp => 'Used the same way built-in abbreviations like KJV and ASV are used.';

  @override
  String get translationAbbreviationRequired => 'Enter an abbreviation.';

  @override
  String get translationAbbreviationTaken => 'That abbreviation is already in use.';

  @override
  String get translationLanguageCodeLabel => 'Language code';

  @override
  String get translationLanguageCodeHint => 'en';

  @override
  String get translationLanguageCodeHelp => 'Use a short code like en, es, fr, or de.';

  @override
  String get translationLanguageCodeRequired => 'Enter a language code.';

  @override
  String get translationDescriptionLabel => 'Description';

  @override
  String get translationDescriptionHint => 'Imported from my_local_bible.xml or my_translation.sqlite';

  @override
  String get importingAction => 'Importing...';

  @override
  String get importTranslationAction => 'Import Translation';

  @override
  String detectedFormatLabel(Object format) {
    return 'Detected format: $format';
  }

  @override
  String booksFoundLabel(int count) {
    return 'Books found: $count';
  }

  @override
  String get searchTranslationsHint => 'Search translations...';

  @override
  String get downloadedSectionHeader => 'Downloaded';

  @override
  String get availableSectionHeader => 'Available';

  @override
  String get downloadAction => 'Download';

  @override
  String get openForSessionAction => 'Open for session';

  @override
  String openedForSessionMessage(Object name) {
    return '$name opened for this session.';
  }

  @override
  String couldNotOpenTranslation(Object error) {
    return 'Could not open translation: $error';
  }

  @override
  String downloadedTranslationMessage(Object name) {
    return '$name downloaded.';
  }

  @override
  String couldNotDownloadTranslation(Object error) {
    return 'Could not download translation: $error';
  }

  @override
  String get importNotAvailableOnWeb => 'Importing local Bible files is not available in the browser yet.';

  @override
  String get languageFilterLabel => 'Language';

  @override
  String get allLanguagesOption => 'All languages';

  @override
  String get selectLanguageTitle => 'Select language';

  @override
  String get readerFontTitle => 'Font';

  @override
  String get readerFontSystemDefault => 'System Default';

  @override
  String get readerFontSectionDefault => 'Default';

  @override
  String get readerFontSectionBundled => 'Included with the app';

  @override
  String get readerFontSectionImported => 'Your fonts';

  @override
  String get readerFontSectionInstalled => 'Installed on this device';

  @override
  String get readerFontImportAction => 'Import a font file';

  @override
  String get readerFontImportHint => 'Choose a .ttf or .otf file';

  @override
  String get readerFontFileTypeLabel => 'Fonts';

  @override
  String get readerFontRemoveTooltip => 'Remove font';

  @override
  String readerFontRemoveTitle(Object fontName) {
    return 'Remove $fontName?';
  }

  @override
  String get readerFontRemoveDescription => 'The imported font file will be deleted from this device.';

  @override
  String get readerFontSearchHint => 'Search installed fonts';

  @override
  String get readerFontNoInstalled => 'No installed fonts were found.';

  @override
  String readerFontNoMatches(Object query) {
    return 'No fonts match “$query”.';
  }

  @override
  String get readerFontScanUnsupported => 'Installed fonts can’t be listed on this platform';

  @override
  String get readerFontScanUnsupportedHint => 'Import a font file instead.';

  @override
  String readerFontImported(Object fontName) {
    return 'Imported $fontName.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return '$fontName could not be loaded.';
  }

  @override
  String get readerFontUnsupportedType => 'Only .ttf and .otf font files can be imported.';

  @override
  String get readerFontNotAFont => 'That file does not look like a valid font.';

  @override
  String get readerFontUnloadable => 'That font file could not be loaded.';

  @override
  String get readerFontImportFailed => 'Could not import that font.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return 'Could not remove $fontName.';
  }

  @override
  String get readerFontPreviewSample => 'In the beginning God created the heaven and the earth.';

  @override
  String get readerDecreaseTextSize => 'Decrease text size';

  @override
  String get readerIncreaseTextSize => 'Increase text size';

  @override
  String get readerLineSpacingTitle => 'Line spacing';

  @override
  String get readerLineSpacingCompact => 'Compact';

  @override
  String get readerLineSpacingNormal => 'Normal';

  @override
  String get readerLineSpacingRelaxed => 'Relaxed';

  @override
  String get readerLineSpacingLoose => 'Loose';

  @override
  String get translationAboutAction => 'About this translation';

  @override
  String get translationRightsLicenseLabel => 'License';

  @override
  String get translationRightsNoticeLabel => 'Copyright notice';

  @override
  String get translationRightsPermissionsLabel => 'Permissions';

  @override
  String get translationRightsPublicDomain => 'Public domain';

  @override
  String get translationRightsViewLicense => 'View license';

  @override
  String get translationRightsSourceLabel => 'Official source';

  @override
  String get translationRightsNotesAction => 'Full license notes';

  @override
  String get translationRightsDownloadNotPermitted => 'The rights holder does not permit downloading this translation in the app.';

  @override
  String get translationRightsUnknown => 'No copyright or license information is available for this translation.';

  @override
  String get translationRightsUnknownImported => 'You imported this translation from a file, so the app has no copyright or license information for it. Make sure you have the right to use it.';

  @override
  String get searchBibleHint => 'Search the Bible';

  @override
  String get clearAction => 'Clear';

  @override
  String get searchTypePrompt => 'Type a word or phrase to search.';

  @override
  String searchFailed(Object error) {
    return 'Search failed: $error';
  }

  @override
  String get searchNoResults => 'No verses found.';

  @override
  String searchResultsCapped(int limit) {
    return 'Showing the first $limit verses. Add words to narrow it down.';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get searchScopeAll => 'Whole Bible';

  @override
  String get searchScopeOldTestament => 'Old Testament';

  @override
  String get searchScopeNewTestament => 'New Testament';

  @override
  String get searchScopeCurrentBook => 'This book';

  @override
  String get searchScopeCurrentChapter => 'This chapter';

  @override
  String get splitViewTooltip => 'Split view';

  @override
  String get closeSplitViewTooltip => 'Close split view';

  @override
  String get paneTranslationTooltip => 'Translation for this pane';

  @override
  String couldNotLoadTranslation(Object error) {
    return 'Could not load this translation: $error';
  }

  @override
  String get chapterNotFound => 'Chapter not found';

  @override
  String get noteDateFieldModified => 'Last modified';

  @override
  String get noteDateFieldCreated => 'Created';

  @override
  String get noteDateRangeAny => 'Any time';

  @override
  String get noteDateRangeToday => 'Today';

  @override
  String get noteDateRangePastWeek => 'Past week';

  @override
  String get noteDateRangePastMonth => 'Past month';

  @override
  String get noteDateRangePastYear => 'Past year';

  @override
  String get noteTypeNote => 'Note';

  @override
  String get noteTypeHighlightOnly => 'Highlight only';

  @override
  String get notesDateButton => 'Date';

  @override
  String get notesDateButtonCreated => 'Date: Created';

  @override
  String notesDateCreatedRange(Object range) {
    return 'Created: $range';
  }

  @override
  String get notesDateShowSection => 'Show';

  @override
  String get notesDateSortSection => 'By date (newest first)';

  @override
  String get linkedVersesTitle => 'Linked Verses';

  @override
  String get showLessAction => 'Show less';

  @override
  String showAllCountAction(int count) {
    return 'Show all (+$count)';
  }

  @override
  String get readFrontMatterAction => 'Read';

  @override
  String get boldWordsOfJesusTitle => 'Bold Words of Jesus';

  @override
  String get boldWordsOfJesusSubtitle => 'Show the words of Jesus in bold as well as red. Off by default, like most red-letter Bibles.';

  @override
  String get openSourceLicensesTitle => 'Open-source licenses';

  @override
  String get openSourceLicensesSubtitle => 'Libraries and code used by this app';

  @override
  String get exportTranslationHelp => 'Exports the SQLite file for a translation stored on this device. Download a translation from Translations to export it.';

  @override
  String get noDownloadedTranslationsToExport => 'No downloaded translations to export.';

  @override
  String get downloadNotificationChannelName => 'Bible downloads';

  @override
  String get downloadNotificationChannelDescription => 'Progress of Bible translation downloads';

  @override
  String get downloadNotificationStarting => 'Starting…';

  @override
  String get downloadNotificationInstalling => 'Installing…';

  @override
  String downloadNotificationProgressTitle(Object name) {
    return 'Downloading $name';
  }

  @override
  String downloadNotificationDoneTitle(Object name) {
    return '$name downloaded';
  }

  @override
  String get downloadNotificationDoneBody => 'Ready to read offline.';

  @override
  String get downloadNotificationFailedTitle => 'Download failed';

  @override
  String downloadNotificationFailedBody(Object name) {
    return 'Could not download $name.';
  }
}
