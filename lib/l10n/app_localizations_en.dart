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
  String get aboutDescription =>
      'This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart. The app allows reading the Bible, taking notes, TTS support, and more. It is inspired by apps like YouVersion Bible but with extra features and improved UI.';

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
  String get clearTranslationCacheDescription =>
      'This removes downloaded translation files, imported source snapshots, and stale translation registry entries from local app storage. Bundled translations will remain available.';

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
  String get deleteImportedTranslationDescription =>
      'This removes the imported Bible from the app library and cache. The original file on disk will not be deleted.';

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
  String get removeDownloadedTranslationDescription =>
      'This removes the downloaded Bible from local app storage. It will stay in the library as a downloadable option so you can download it again later.';

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
  String get translationDetailsDescription =>
      'Set the library name, abbreviation, language code, and description before the import is saved.';

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
  String get translationAbbreviationHelp =>
      'Used the same way built-in abbreviations like KJV and ASV are used.';

  @override
  String get translationAbbreviationRequired => 'Enter an abbreviation.';

  @override
  String get translationAbbreviationTaken =>
      'That abbreviation is already in use.';

  @override
  String get translationLanguageCodeLabel => 'Language code';

  @override
  String get translationLanguageCodeHint => 'en';

  @override
  String get translationLanguageCodeHelp =>
      'Use a short code like en, es, fr, or de.';

  @override
  String get translationLanguageCodeRequired => 'Enter a language code.';

  @override
  String get translationDescriptionLabel => 'Description';

  @override
  String get translationDescriptionHint =>
      'Imported from my_local_bible.xml or my_translation.sqlite';

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
  String get importNotAvailableOnWeb =>
      'Importing local Bible files is not available in the browser yet.';

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
  String get readerFontRemoveDescription =>
      'The imported font file will be deleted from this device.';

  @override
  String get readerFontSearchHint => 'Search installed fonts';

  @override
  String get readerFontNoInstalled => 'No installed fonts were found.';

  @override
  String readerFontNoMatches(Object query) {
    return 'No fonts match “$query”.';
  }

  @override
  String get readerFontScanUnsupported =>
      'Installed fonts can’t be listed on this platform';

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
  String get readerFontUnsupportedType =>
      'Only .ttf and .otf font files can be imported.';

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
  String get readerFontPreviewSample =>
      'In the beginning God created the heaven and the earth.';

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
  String get translationRightsDownloadNotPermitted =>
      'The rights holder does not permit downloading this translation in the app.';

  @override
  String get translationRightsUnknown =>
      'No copyright or license information is available for this translation.';

  @override
  String get translationRightsUnknownImported =>
      'You imported this translation from a file, so the app has no copyright or license information for it. Make sure you have the right to use it.';

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
  String get boldWordsOfJesusSubtitle =>
      'Show the words of Jesus in bold as well as red. Off by default, like most red-letter Bibles.';

  @override
  String get openSourceLicensesTitle => 'Open-source licenses';

  @override
  String get openSourceLicensesSubtitle =>
      'Libraries and code used by this app';

  @override
  String get exportTranslationHelp =>
      'Exports the SQLite file for a translation stored on this device. Download a translation from Translations to export it.';

  @override
  String get noDownloadedTranslationsToExport =>
      'No downloaded translations to export.';

  @override
  String get downloadNotificationChannelName => 'Bible downloads';

  @override
  String get downloadNotificationChannelDescription =>
      'Progress of Bible translation downloads';

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

  @override
  String get playAudioTooltip => 'Play audio';

  @override
  String get splitFollowMainTitle => 'Open Split View At The Current Chapter';

  @override
  String get splitFollowMainSubtitle =>
      'Each time split view opens, start the second pane at the chapter the main reader is on. Off by default: the pane stays where you left it until the app is relaunched.';

  @override
  String get searchTooltip => 'Search';

  @override
  String get readerOptionsTooltip => 'Reader options';

  @override
  String get relatedContentAction => 'Related Content';

  @override
  String get fontsAndSettingsAction => 'Fonts & Settings';

  @override
  String get continuousScrollingTitle => 'Continuous Scrolling';

  @override
  String get documentModeTitle => 'Document Mode';

  @override
  String get showNotesAcrossTranslationsTitle =>
      'Show Notes On Other Translations';

  @override
  String get allSettingsAction => 'All Settings';

  @override
  String get retryAction => 'Retry';

  @override
  String get addNoteAction => 'Add Note';

  @override
  String get viewAction => 'View';

  @override
  String get crossReferencesTitle => 'Cross-References';

  @override
  String get noCrossReferences =>
      'No cross-references available for this verse.';

  @override
  String couldNotParseReference(Object label) {
    return 'Could not parse reference: $label';
  }

  @override
  String get currentTranslationLabel => 'Current translation';

  @override
  String get backToDetailsAction => 'Back to Details';

  @override
  String get backToNoteAction => 'Back to Note';

  @override
  String readerErrorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String failedToLoadBible(Object error) {
    return 'Failed to load Bible: $error';
  }

  @override
  String get shareTextCopied =>
      'Share text copied. Native share can be added later without changing your notes data.';

  @override
  String get highlightAction => 'Highlight';

  @override
  String get noteAction => 'Note';

  @override
  String get copyAction => 'Copy';

  @override
  String get shareAction => 'Share';

  @override
  String get noteHighlightsEditedFromNote =>
      'Note highlights are edited from the note itself.';

  @override
  String get previewUnavailable => 'Preview unavailable for this reference.';

  @override
  String get openInBibleAction => 'Open in Bible';

  @override
  String get previousChapterTooltip => 'Previous chapter';

  @override
  String get nextChapterTooltip => 'Next chapter';

  @override
  String get sourceDetailsTitle => 'Source details';

  @override
  String get quoteSpeakerLabel => 'Quote speaker';

  @override
  String get lemmaLabel => 'Lemma';

  @override
  String get morphologyLabel => 'Morphology';

  @override
  String get translationNotAvailable => 'Translation not available.';

  @override
  String get currentTranslationNotAvailable =>
      'Current translation is not available.';

  @override
  String get saveNoteFailed => 'Failed to save note. Please try again.';

  @override
  String get saveAction => 'Save';

  @override
  String get noteFieldLabel => 'Note';

  @override
  String get noteFieldHint => 'Write your note here.';

  @override
  String get primaryVerseTitle => 'Primary Verse';

  @override
  String get removeVerseTitle => 'Remove verse?';

  @override
  String get addVerseAction => 'Add Verse';

  @override
  String get connectedHighlightTitle => 'Connected Highlight';

  @override
  String get noneOption => 'None';

  @override
  String get connectedHighlightDescription =>
      'This note will keep a connected verse highlight on its primary verse.';

  @override
  String get labelsFieldLabel => 'Labels';

  @override
  String get labelsFieldHint => 'Comma separated labels';

  @override
  String get onlyStandaloneHighlightsRemovable =>
      'Only standalone highlights can be removed here. Edit a note to change its highlight.';

  @override
  String noteVerseLimit(int count) {
    return 'Notes can be linked to up to $count verses at once. Please select a smaller range.';
  }

  @override
  String get deleteAnnotationTitle => 'Delete?';

  @override
  String get deleteAnnotationDescription =>
      'This note or highlight will be permanently removed.';

  @override
  String get noReferenceHistory => 'No reference history yet.';

  @override
  String get recentReferencesTitle => 'Recent References';

  @override
  String get referencesTitle => 'References';

  @override
  String get historyTooltip => 'History';

  @override
  String get searchBooksHint => 'Search books';

  @override
  String get chaptersLabel => 'Chapters';

  @override
  String goToReference(Object reference) {
    return 'Go to $reference';
  }

  @override
  String versesInChapter(Object chapter) {
    return 'Verses in $chapter';
  }

  @override
  String get keepOneTranslationMessage =>
      'Keep at least one translation on this device. Download or import another one before removing this one.';

  @override
  String get hymnsTab => 'Hymns';

  @override
  String get hymnSearchHint => 'Number, title, words or author';

  @override
  String get hymnSortTooltip => 'Sort';

  @override
  String get hymnSortNumber => 'By number';

  @override
  String get hymnSortAlphabetical => 'Alphabetical';

  @override
  String get hymnFavoritesOnly => 'Show favorites';

  @override
  String get hymnShowAll => 'Show all hymns';

  @override
  String get hymnCountLabel => 'Hymns';

  @override
  String get hymnNoResults => 'No hymns match your search.';

  @override
  String get hymnNoFavorites =>
      'No favorites yet. Tap the star on a hymn to add it.';

  @override
  String get hymnPickHint => 'Choose a hymn to read it here.';

  @override
  String get hymnalLoadError => 'This hymn book could not be opened.';

  @override
  String get hymnChorusLabel => 'Chorus';

  @override
  String get hymnOptionalChorus => 'Optional chorus';

  @override
  String get hymnOptionalVerse => 'Optional verse';

  @override
  String get hymnAddFavorite => 'Add to favorites';

  @override
  String get hymnRemoveFavorite => 'Remove from favorites';

  @override
  String get hymnCopied => 'Hymn copied';

  @override
  String get hymnPrint => 'Print';

  @override
  String get hymnPrevious => 'Previous hymn';

  @override
  String get hymnNext => 'Next hymn';

  @override
  String get hymnDisplaySettings => 'Display settings';

  @override
  String get hymnTextSize => 'Text size';

  @override
  String get hymnChorusEveryVerse => 'Show chorus after every verse';

  @override
  String get hymnChorusEveryVerseSubtitle =>
      'When off, the chorus appears once after verse 1, as in the printed book.';

  @override
  String get hymnShowDetails => 'Show author, meter and tune';

  @override
  String get hymnShowOptional => 'Show optional verses and choruses';

  @override
  String get hymnAboutBook => 'About this book';

  @override
  String get hymnReportConcern => 'Report a copyright concern';

  @override
  String get hymnReportUnavailable =>
      'Could not open the report page. Please try again later.';

  @override
  String get hymnalPublisher => 'Publisher';

  @override
  String get hymnalEdition => 'Edition';

  @override
  String get hymnalIsbn => 'ISBN';

  @override
  String get hymnalCopyright => 'Copyright';

  @override
  String get hymnalPermission => 'Permission';

  @override
  String get hymnalSource => 'Source';

  @override
  String get hymnalSourceBundled => 'Included with the app';

  @override
  String get hymnalSourceImported => 'Imported from a file on this device';

  @override
  String hymnalSourceRepository(String source) {
    return 'Downloaded from $source';
  }

  @override
  String get hymnalSourceBundledShort => 'Included';

  @override
  String get hymnalSourceImportedShort => 'Imported';

  @override
  String get hymnalSourceRepositoryShort => 'Downloaded';

  @override
  String get hymnalThirdPartyNotice =>
      'This book did not come with the app. Its rights are the responsibility of whoever provided it.';

  @override
  String get hymnalLibraryTitle => 'Hymn books';

  @override
  String get hymnalManageBooks => 'Manage hymn books';

  @override
  String get hymnalInstalledSection => 'On this device';

  @override
  String get hymnalAvailableSection => 'Available from repositories';

  @override
  String get hymnalImportFile => 'Import a hymn book file';

  @override
  String get hymnalImportSubtitle => 'Hymn book JSON files (.json or .json.gz)';

  @override
  String hymnalImported(String title) {
    return 'Added \"$title\"';
  }

  @override
  String hymnalImportFailed(String error) {
    return 'Could not import: $error';
  }

  @override
  String get hymnalOpenBook => 'Open';

  @override
  String hymnalDeleteTitle(String title) {
    return 'Remove \"$title\"?';
  }

  @override
  String get hymnalDeleteMessage =>
      'The book is removed from this device. Your favorites for it are kept in case you add it again.';

  @override
  String get hymnalNoRepoBooks =>
      'No hymn books are available from your repositories yet.';

  @override
  String get hymnalDownload => 'Download';

  @override
  String get hymnalDownloaded => 'Installed';

  @override
  String get hymnalNotDownloadable => 'Listed only — not offered for download';

  @override
  String hymnalDownloadFailed(String error) {
    return 'Download failed: $error';
  }

  @override
  String get manageRepositories => 'Manage repositories';

  @override
  String get manageRepositoriesSubtitle =>
      'Where hymn books can be downloaded from';

  @override
  String get repositoriesTitle => 'Repositories';

  @override
  String get repositoriesIntro =>
      'Repositories list hymn books you can download. The official repository is run by this app\'s developers; any others are run by third parties.';

  @override
  String get repositoryOfficial => 'Official';

  @override
  String get repositoryAdd => 'Add repository';

  @override
  String get repositoryUrlLabel => 'Repository address (https://…)';

  @override
  String get repositoryCheck => 'Check';

  @override
  String repositoryAdded(String name) {
    return 'Added \"$name\"';
  }

  @override
  String repositoryAddFailed(String error) {
    return 'Could not add the repository: $error';
  }

  @override
  String get repositoryRefresh => 'Refresh';

  @override
  String get repositoryRemove => 'Remove';

  @override
  String repositoryRemoveTitle(String name) {
    return 'Remove \"$name\"?';
  }

  @override
  String get repositoryRemoveMessage =>
      'Hymn books downloaded from this repository will also be removed from this device.';

  @override
  String get repositoryLoadFailed =>
      'Could not load this repository right now.';

  @override
  String repositoryMaintainer(String name) {
    return 'Maintained by $name';
  }

  @override
  String get repositoryOwnerNote => 'From the repository owner:';

  @override
  String get repositoryDisclaimerTitle => 'Third-party repository';

  @override
  String get repositoryDisclaimerBody =>
      'This repository is run by a third party, not by the developers of this app. We do not host, review or distribute its content, and we cannot confirm that its owner has permission to share it. You are responsible for what you download. To report a copyright problem with a book from this repository, use \"Report a copyright concern\" on that book\'s About page, which contacts the repository owner.';

  @override
  String get repositoryDisclaimerAccept =>
      'I understand this content is not provided by this app';

  @override
  String get legalTitle => 'Legal & takedown requests';

  @override
  String get legalSubtitle =>
      'Content rights, third-party sources and how to request removal';

  @override
  String get legalBundledHeading => 'Content included with the app';

  @override
  String get legalBundledBody =>
      'Hymn books included with the app are distributed with their publishers\' permission. Each book\'s copyright and permission notices are shown on its About page and are added to every hymn you copy, share or print.';

  @override
  String get legalThirdPartyHeading => 'Third-party repositories';

  @override
  String get legalThirdPartyBody =>
      'Repositories you add yourself are run by other people. Their content is not hosted, reviewed or distributed by the developers of this app, and we make no promise that their owners have the right to share it. Requests about that content should go to the repository owner, whose contact is shown on each book\'s About page.';

  @override
  String get legalImportedHeading => 'Files you import';

  @override
  String get legalImportedBody =>
      'Imported files stay on your device and are never shared by the app. Only import files you have the right to use.';

  @override
  String get legalTakedownHeading => 'Takedown requests';

  @override
  String get legalTakedownBody =>
      'If you hold the rights to content included with the app or listed in the official repository and want it removed, send a takedown request. Name the book and hymn numbers, the work you own, and how we can reach you. Once a request is confirmed, the content is withdrawn from the official repository, and withdrawn books are removed from devices the next time the app refreshes its repositories.';

  @override
  String get legalReportButton => 'Send a takedown request';

  @override
  String hymnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hymns',
      one: '1 hymn',
    );
    return '$_temp0';
  }

  @override
  String get repositoryGuide =>
      'How repositories work, and how to make your own';

  @override
  String get hymnalNameTitle => 'Name this hymn book';

  @override
  String get hymnalNameLabel => 'Name';

  @override
  String get hymnalNameRequired => 'Enter a name';

  @override
  String get hymnalShortNameLabel => 'Short name (optional)';

  @override
  String get hymnalShortNameHelper =>
      'Shown at the top of the Hymns tab, e.g. BHB';

  @override
  String get hymnalImportAction => 'Import';

  @override
  String hymnalImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Found $count hymns.',
      one: 'Found 1 hymn.',
    );
    return '$_temp0';
  }

  @override
  String get hymnalImportReplaces =>
      'This book is already on this device. Importing replaces it; your favorites are kept.';

  @override
  String get hymnalRename => 'Rename';

  @override
  String get hymnalRenameAction => 'Save';

  @override
  String get hymnalImportGuide => 'How to import';

  @override
  String get hymnalMakeGuide => 'Make your own hymn book file';

  @override
  String get linkOpenFailed => 'Could not open the link.';
}
