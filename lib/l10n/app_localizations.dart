import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('zh'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bible.
  ///
  /// In en, this message translates to:
  /// **'Bible'**
  String get bible;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @goToOther.
  ///
  /// In en, this message translates to:
  /// **'Go to Other Page'**
  String get goToOther;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart. The app allows reading the Bible, taking notes, TTS support, and more. It is inspired by apps like YouVersion Bible but with extra features and improved UI.'**
  String get aboutDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @readerFootnotesTooltip.
  ///
  /// In en, this message translates to:
  /// **'View footnotes and references'**
  String get readerFootnotesTooltip;

  /// No description provided for @readerNotesTooltip.
  ///
  /// In en, this message translates to:
  /// **'View personal notes'**
  String get readerNotesTooltip;

  /// No description provided for @savedNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved Note'**
  String get savedNoteLabel;

  /// No description provided for @savedNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved Notes'**
  String get savedNotesLabel;

  /// No description provided for @openAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openAction;

  /// No description provided for @editAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editAction;

  /// No description provided for @versionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get versionsTitle;

  /// No description provided for @searchTranslationsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search translations'**
  String get searchTranslationsTooltip;

  /// No description provided for @importBibleFileAction.
  ///
  /// In en, this message translates to:
  /// **'Import Bible File'**
  String get importBibleFileAction;

  /// No description provided for @clearTranslationCacheAction.
  ///
  /// In en, this message translates to:
  /// **'Clear translation cache'**
  String get clearTranslationCacheAction;

  /// No description provided for @clearTranslationCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear translation cache?'**
  String get clearTranslationCacheTitle;

  /// No description provided for @clearTranslationCacheDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes downloaded translation files, imported source snapshots, and stale translation registry entries from local app storage. Bundled translations will remain available.'**
  String get clearTranslationCacheDescription;

  /// No description provided for @clearCacheAction.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCacheAction;

  /// No description provided for @clearedTranslationCacheMessage.
  ///
  /// In en, this message translates to:
  /// **'Translation cache cleared.'**
  String get clearedTranslationCacheMessage;

  /// No description provided for @couldNotClearTranslationCache.
  ///
  /// In en, this message translates to:
  /// **'Could not clear translation cache: {error}'**
  String couldNotClearTranslationCache(Object error);

  /// No description provided for @translationsFileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Bible files'**
  String get translationsFileTypeLabel;

  /// No description provided for @unableToLoadTranslations.
  ///
  /// In en, this message translates to:
  /// **'Unable to load translations: {error}'**
  String unableToLoadTranslations(Object error);

  /// No description provided for @couldNotSwitchTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not switch translation: {error}'**
  String couldNotSwitchTranslation(Object error);

  /// No description provided for @importedTranslationMessage.
  ///
  /// In en, this message translates to:
  /// **'Imported {name}.'**
  String importedTranslationMessage(Object name);

  /// No description provided for @importFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailedMessage(Object error);

  /// No description provided for @deleteTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteTranslationTitle(Object name);

  /// No description provided for @deleteImportedTranslationDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes the imported Bible from the app library and cache. The original file on disk will not be deleted.'**
  String get deleteImportedTranslationDescription;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @deletedTranslationMessage.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}.'**
  String deletedTranslationMessage(Object name);

  /// No description provided for @couldNotDeleteTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not delete translation: {error}'**
  String couldNotDeleteTranslation(Object error);

  /// No description provided for @removeDownloadedTranslationTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} download?'**
  String removeDownloadedTranslationTitle(Object name);

  /// No description provided for @removeDownloadedTranslationDescription.
  ///
  /// In en, this message translates to:
  /// **'This removes the downloaded Bible from local app storage. It will stay in the library as a downloadable option so you can download it again later.'**
  String get removeDownloadedTranslationDescription;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @removedLocalDownloadMessage.
  ///
  /// In en, this message translates to:
  /// **'Removed local download for {name}.'**
  String removedLocalDownloadMessage(Object name);

  /// No description provided for @couldNotRemoveDownload.
  ///
  /// In en, this message translates to:
  /// **'Could not remove download: {error}'**
  String couldNotRemoveDownload(Object error);

  /// No description provided for @moreActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get moreActionsTooltip;

  /// No description provided for @deleteImportAction.
  ///
  /// In en, this message translates to:
  /// **'Delete import'**
  String get deleteImportAction;

  /// No description provided for @removeDownloadAction.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownloadAction;

  /// No description provided for @availableOfflineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get availableOfflineTooltip;

  /// No description provided for @downloadTranslationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Download translation'**
  String get downloadTranslationTooltip;

  /// No description provided for @audioOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Audio options'**
  String get audioOptionsTooltip;

  /// No description provided for @bundledTranslationSource.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get bundledTranslationSource;

  /// No description provided for @downloadedTranslationSource.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadedTranslationSource;

  /// No description provided for @downloadableTranslationSource.
  ///
  /// In en, this message translates to:
  /// **'Downloadable'**
  String get downloadableTranslationSource;

  /// No description provided for @importedTranslationSource.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importedTranslationSource;

  /// No description provided for @importBibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Bible'**
  String get importBibleTitle;

  /// No description provided for @unableToPrepareImport.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare import: {error}'**
  String unableToPrepareImport(Object error);

  /// No description provided for @translationDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Translation Details'**
  String get translationDetailsTitle;

  /// No description provided for @translationDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Set the library name, abbreviation, language code, and description before the import is saved.'**
  String get translationDetailsDescription;

  /// No description provided for @translationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get translationNameLabel;

  /// No description provided for @translationNameHint.
  ///
  /// In en, this message translates to:
  /// **'World English Bible'**
  String get translationNameHint;

  /// No description provided for @translationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a translation name.'**
  String get translationNameRequired;

  /// No description provided for @translationAbbreviationLabel.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get translationAbbreviationLabel;

  /// No description provided for @translationAbbreviationHint.
  ///
  /// In en, this message translates to:
  /// **'WEB'**
  String get translationAbbreviationHint;

  /// No description provided for @translationAbbreviationHelp.
  ///
  /// In en, this message translates to:
  /// **'Used the same way built-in abbreviations like KJV and ASV are used.'**
  String get translationAbbreviationHelp;

  /// No description provided for @translationAbbreviationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an abbreviation.'**
  String get translationAbbreviationRequired;

  /// No description provided for @translationAbbreviationTaken.
  ///
  /// In en, this message translates to:
  /// **'That abbreviation is already in use.'**
  String get translationAbbreviationTaken;

  /// No description provided for @translationLanguageCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Language code'**
  String get translationLanguageCodeLabel;

  /// No description provided for @translationLanguageCodeHint.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String get translationLanguageCodeHint;

  /// No description provided for @translationLanguageCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Use a short code like en, es, fr, or de.'**
  String get translationLanguageCodeHelp;

  /// No description provided for @translationLanguageCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a language code.'**
  String get translationLanguageCodeRequired;

  /// No description provided for @translationDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get translationDescriptionLabel;

  /// No description provided for @translationDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Imported from my_local_bible.xml or my_translation.sqlite'**
  String get translationDescriptionHint;

  /// No description provided for @importingAction.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importingAction;

  /// No description provided for @importTranslationAction.
  ///
  /// In en, this message translates to:
  /// **'Import Translation'**
  String get importTranslationAction;

  /// No description provided for @detectedFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Detected format: {format}'**
  String detectedFormatLabel(Object format);

  /// No description provided for @booksFoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Books found: {count}'**
  String booksFoundLabel(int count);

  /// No description provided for @searchTranslationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search translations...'**
  String get searchTranslationsHint;

  /// No description provided for @downloadedSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloadedSectionHeader;

  /// No description provided for @availableSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableSectionHeader;

  /// No description provided for @downloadAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadAction;

  /// No description provided for @openForSessionAction.
  ///
  /// In en, this message translates to:
  /// **'Open for session'**
  String get openForSessionAction;

  /// No description provided for @openedForSessionMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} opened for this session.'**
  String openedForSessionMessage(Object name);

  /// No description provided for @couldNotOpenTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not open translation: {error}'**
  String couldNotOpenTranslation(Object error);

  /// No description provided for @downloadedTranslationMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} downloaded.'**
  String downloadedTranslationMessage(Object name);

  /// No description provided for @couldNotDownloadTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not download translation: {error}'**
  String couldNotDownloadTranslation(Object error);

  /// No description provided for @importNotAvailableOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Importing local Bible files is not available in the browser yet.'**
  String get importNotAvailableOnWeb;

  /// No description provided for @languageFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageFilterLabel;

  /// No description provided for @allLanguagesOption.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get allLanguagesOption;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguageTitle;

  /// No description provided for @readerFontTitle.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get readerFontTitle;

  /// No description provided for @readerFontSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get readerFontSystemDefault;

  /// No description provided for @readerFontSectionDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get readerFontSectionDefault;

  /// No description provided for @readerFontSectionBundled.
  ///
  /// In en, this message translates to:
  /// **'Included with the app'**
  String get readerFontSectionBundled;

  /// No description provided for @readerFontSectionImported.
  ///
  /// In en, this message translates to:
  /// **'Your fonts'**
  String get readerFontSectionImported;

  /// No description provided for @readerFontSectionInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed on this device'**
  String get readerFontSectionInstalled;

  /// No description provided for @readerFontImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import a font file'**
  String get readerFontImportAction;

  /// No description provided for @readerFontImportHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a .ttf or .otf file'**
  String get readerFontImportHint;

  /// No description provided for @readerFontFileTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get readerFontFileTypeLabel;

  /// No description provided for @readerFontRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove font'**
  String get readerFontRemoveTooltip;

  /// No description provided for @readerFontRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {fontName}?'**
  String readerFontRemoveTitle(Object fontName);

  /// No description provided for @readerFontRemoveDescription.
  ///
  /// In en, this message translates to:
  /// **'The imported font file will be deleted from this device.'**
  String get readerFontRemoveDescription;

  /// No description provided for @readerFontSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search installed fonts'**
  String get readerFontSearchHint;

  /// No description provided for @readerFontNoInstalled.
  ///
  /// In en, this message translates to:
  /// **'No installed fonts were found.'**
  String get readerFontNoInstalled;

  /// No description provided for @readerFontNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No fonts match “{query}”.'**
  String readerFontNoMatches(Object query);

  /// No description provided for @readerFontScanUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Installed fonts can’t be listed on this platform'**
  String get readerFontScanUnsupported;

  /// No description provided for @readerFontScanUnsupportedHint.
  ///
  /// In en, this message translates to:
  /// **'Import a font file instead.'**
  String get readerFontScanUnsupportedHint;

  /// No description provided for @readerFontImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {fontName}.'**
  String readerFontImported(Object fontName);

  /// No description provided for @readerFontLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'{fontName} could not be loaded.'**
  String readerFontLoadFailed(Object fontName);

  /// No description provided for @readerFontUnsupportedType.
  ///
  /// In en, this message translates to:
  /// **'Only .ttf and .otf font files can be imported.'**
  String get readerFontUnsupportedType;

  /// No description provided for @readerFontNotAFont.
  ///
  /// In en, this message translates to:
  /// **'That file does not look like a valid font.'**
  String get readerFontNotAFont;

  /// No description provided for @readerFontUnloadable.
  ///
  /// In en, this message translates to:
  /// **'That font file could not be loaded.'**
  String get readerFontUnloadable;

  /// No description provided for @readerFontImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import that font.'**
  String get readerFontImportFailed;

  /// No description provided for @readerFontDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove {fontName}.'**
  String readerFontDeleteFailed(Object fontName);

  /// No description provided for @readerFontPreviewSample.
  ///
  /// In en, this message translates to:
  /// **'In the beginning God created the heaven and the earth.'**
  String get readerFontPreviewSample;

  /// No description provided for @readerDecreaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Decrease text size'**
  String get readerDecreaseTextSize;

  /// No description provided for @readerIncreaseTextSize.
  ///
  /// In en, this message translates to:
  /// **'Increase text size'**
  String get readerIncreaseTextSize;

  /// No description provided for @readerLineSpacingTitle.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get readerLineSpacingTitle;

  /// No description provided for @readerLineSpacingCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get readerLineSpacingCompact;

  /// No description provided for @readerLineSpacingNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get readerLineSpacingNormal;

  /// No description provided for @readerLineSpacingRelaxed.
  ///
  /// In en, this message translates to:
  /// **'Relaxed'**
  String get readerLineSpacingRelaxed;

  /// No description provided for @readerLineSpacingLoose.
  ///
  /// In en, this message translates to:
  /// **'Loose'**
  String get readerLineSpacingLoose;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'About this translation'**
  String get translationAboutAction;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get translationRightsLicenseLabel;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'Copyright notice'**
  String get translationRightsNoticeLabel;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get translationRightsPermissionsLabel;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'Public domain'**
  String get translationRightsPublicDomain;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'View license'**
  String get translationRightsViewLicense;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'Official source'**
  String get translationRightsSourceLabel;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'Full license notes'**
  String get translationRightsNotesAction;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'The rights holder does not permit downloading this translation in the app.'**
  String get translationRightsDownloadNotPermitted;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'No copyright or license information is available for this translation.'**
  String get translationRightsUnknown;

  /// Translation copyright/license sheet in the Bible versions library.
  ///
  /// In en, this message translates to:
  /// **'You imported this translation from a file, so the app has no copyright or license information for it. Make sure you have the right to use it.'**
  String get translationRightsUnknownImported;

  /// No description provided for @searchBibleHint.
  ///
  /// In en, this message translates to:
  /// **'Search the Bible'**
  String get searchBibleHint;

  /// No description provided for @clearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearAction;

  /// No description provided for @searchTypePrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a word or phrase to search.'**
  String get searchTypePrompt;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(Object error);

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No verses found.'**
  String get searchNoResults;

  /// No description provided for @searchResultsCapped.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {limit} verses. Add words to narrow it down.'**
  String searchResultsCapped(int limit);

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 verse} other{{count} verses}}'**
  String searchResultCount(int count);

  /// No description provided for @searchScopeAll.
  ///
  /// In en, this message translates to:
  /// **'Whole Bible'**
  String get searchScopeAll;

  /// No description provided for @searchScopeOldTestament.
  ///
  /// In en, this message translates to:
  /// **'Old Testament'**
  String get searchScopeOldTestament;

  /// No description provided for @searchScopeNewTestament.
  ///
  /// In en, this message translates to:
  /// **'New Testament'**
  String get searchScopeNewTestament;

  /// No description provided for @searchScopeCurrentBook.
  ///
  /// In en, this message translates to:
  /// **'This book'**
  String get searchScopeCurrentBook;

  /// No description provided for @searchScopeCurrentChapter.
  ///
  /// In en, this message translates to:
  /// **'This chapter'**
  String get searchScopeCurrentChapter;

  /// No description provided for @splitViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Split view'**
  String get splitViewTooltip;

  /// No description provided for @closeSplitViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close split view'**
  String get closeSplitViewTooltip;

  /// No description provided for @paneTranslationTooltip.
  ///
  /// In en, this message translates to:
  /// **'Translation for this pane'**
  String get paneTranslationTooltip;

  /// No description provided for @couldNotLoadTranslation.
  ///
  /// In en, this message translates to:
  /// **'Could not load this translation: {error}'**
  String couldNotLoadTranslation(Object error);

  /// No description provided for @chapterNotFound.
  ///
  /// In en, this message translates to:
  /// **'Chapter not found'**
  String get chapterNotFound;

  /// No description provided for @noteDateFieldModified.
  ///
  /// In en, this message translates to:
  /// **'Last modified'**
  String get noteDateFieldModified;

  /// No description provided for @noteDateFieldCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get noteDateFieldCreated;

  /// No description provided for @noteDateRangeAny.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get noteDateRangeAny;

  /// No description provided for @noteDateRangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get noteDateRangeToday;

  /// No description provided for @noteDateRangePastWeek.
  ///
  /// In en, this message translates to:
  /// **'Past week'**
  String get noteDateRangePastWeek;

  /// No description provided for @noteDateRangePastMonth.
  ///
  /// In en, this message translates to:
  /// **'Past month'**
  String get noteDateRangePastMonth;

  /// No description provided for @noteDateRangePastYear.
  ///
  /// In en, this message translates to:
  /// **'Past year'**
  String get noteDateRangePastYear;

  /// No description provided for @noteTypeNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteTypeNote;

  /// No description provided for @noteTypeHighlightOnly.
  ///
  /// In en, this message translates to:
  /// **'Highlight only'**
  String get noteTypeHighlightOnly;

  /// No description provided for @notesDateButton.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get notesDateButton;

  /// No description provided for @notesDateButtonCreated.
  ///
  /// In en, this message translates to:
  /// **'Date: Created'**
  String get notesDateButtonCreated;

  /// No description provided for @notesDateCreatedRange.
  ///
  /// In en, this message translates to:
  /// **'Created: {range}'**
  String notesDateCreatedRange(Object range);

  /// No description provided for @notesDateShowSection.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get notesDateShowSection;

  /// No description provided for @notesDateSortSection.
  ///
  /// In en, this message translates to:
  /// **'By date (newest first)'**
  String get notesDateSortSection;

  /// No description provided for @linkedVersesTitle.
  ///
  /// In en, this message translates to:
  /// **'Linked Verses'**
  String get linkedVersesTitle;

  /// No description provided for @showLessAction.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLessAction;

  /// No description provided for @showAllCountAction.
  ///
  /// In en, this message translates to:
  /// **'Show all (+{count})'**
  String showAllCountAction(int count);

  /// Tile for a book's single front-matter page (preface, glossary), which has no chapter number.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readFrontMatterAction;

  /// No description provided for @boldWordsOfJesusTitle.
  ///
  /// In en, this message translates to:
  /// **'Bold Words of Jesus'**
  String get boldWordsOfJesusTitle;

  /// No description provided for @boldWordsOfJesusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the words of Jesus in bold as well as red. Off by default, like most red-letter Bibles.'**
  String get boldWordsOfJesusSubtitle;

  /// No description provided for @openSourceLicensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get openSourceLicensesTitle;

  /// No description provided for @openSourceLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Libraries and code used by this app'**
  String get openSourceLicensesSubtitle;

  /// No description provided for @exportTranslationHelp.
  ///
  /// In en, this message translates to:
  /// **'Exports the SQLite file for a translation stored on this device. Download a translation from Translations to export it.'**
  String get exportTranslationHelp;

  /// No description provided for @noDownloadedTranslationsToExport.
  ///
  /// In en, this message translates to:
  /// **'No downloaded translations to export.'**
  String get noDownloadedTranslationsToExport;

  /// No description provided for @downloadNotificationChannelName.
  ///
  /// In en, this message translates to:
  /// **'Bible downloads'**
  String get downloadNotificationChannelName;

  /// No description provided for @downloadNotificationChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Progress of Bible translation downloads'**
  String get downloadNotificationChannelDescription;

  /// No description provided for @downloadNotificationStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get downloadNotificationStarting;

  /// No description provided for @downloadNotificationInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get downloadNotificationInstalling;

  /// No description provided for @downloadNotificationProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading {name}'**
  String downloadNotificationProgressTitle(Object name);

  /// No description provided for @downloadNotificationDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} downloaded'**
  String downloadNotificationDoneTitle(Object name);

  /// No description provided for @downloadNotificationDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Ready to read offline.'**
  String get downloadNotificationDoneBody;

  /// No description provided for @downloadNotificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadNotificationFailedTitle;

  /// No description provided for @downloadNotificationFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Could not download {name}.'**
  String downloadNotificationFailedBody(Object name);

  /// No description provided for @playAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play audio'**
  String get playAudioTooltip;

  /// No description provided for @splitFollowMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Split View At The Current Chapter'**
  String get splitFollowMainTitle;

  /// No description provided for @splitFollowMainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each time split view opens, start the second pane at the chapter the main reader is on. Off by default: the pane stays where you left it until the app is relaunched.'**
  String get splitFollowMainSubtitle;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @readerOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reader options'**
  String get readerOptionsTooltip;

  /// No description provided for @relatedContentAction.
  ///
  /// In en, this message translates to:
  /// **'Related Content'**
  String get relatedContentAction;

  /// No description provided for @fontsAndSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Fonts & Settings'**
  String get fontsAndSettingsAction;

  /// No description provided for @continuousScrollingTitle.
  ///
  /// In en, this message translates to:
  /// **'Continuous Scrolling'**
  String get continuousScrollingTitle;

  /// No description provided for @documentModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Mode'**
  String get documentModeTitle;

  /// No description provided for @showNotesAcrossTranslationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Notes On Other Translations'**
  String get showNotesAcrossTranslationsTitle;

  /// No description provided for @allSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'All Settings'**
  String get allSettingsAction;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @addNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNoteAction;

  /// No description provided for @viewAction.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// No description provided for @crossReferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Cross-References'**
  String get crossReferencesTitle;

  /// No description provided for @noCrossReferences.
  ///
  /// In en, this message translates to:
  /// **'No cross-references available for this verse.'**
  String get noCrossReferences;

  /// No description provided for @couldNotParseReference.
  ///
  /// In en, this message translates to:
  /// **'Could not parse reference: {label}'**
  String couldNotParseReference(Object label);

  /// No description provided for @currentTranslationLabel.
  ///
  /// In en, this message translates to:
  /// **'Current translation'**
  String get currentTranslationLabel;

  /// No description provided for @backToDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Details'**
  String get backToDetailsAction;

  /// No description provided for @backToNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Back to Note'**
  String get backToNoteAction;

  /// No description provided for @readerErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String readerErrorMessage(Object error);

  /// No description provided for @failedToLoadBible.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Bible: {error}'**
  String failedToLoadBible(Object error);

  /// No description provided for @shareTextCopied.
  ///
  /// In en, this message translates to:
  /// **'Share text copied. Native share can be added later without changing your notes data.'**
  String get shareTextCopied;

  /// No description provided for @highlightAction.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get highlightAction;

  /// No description provided for @noteAction.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteAction;

  /// No description provided for @copyAction.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyAction;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @noteHighlightsEditedFromNote.
  ///
  /// In en, this message translates to:
  /// **'Note highlights are edited from the note itself.'**
  String get noteHighlightsEditedFromNote;

  /// No description provided for @previewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable for this reference.'**
  String get previewUnavailable;

  /// No description provided for @openInBibleAction.
  ///
  /// In en, this message translates to:
  /// **'Open in Bible'**
  String get openInBibleAction;

  /// No description provided for @previousChapterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous chapter'**
  String get previousChapterTooltip;

  /// No description provided for @nextChapterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next chapter'**
  String get nextChapterTooltip;

  /// No description provided for @sourceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Source details'**
  String get sourceDetailsTitle;

  /// No description provided for @quoteSpeakerLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote speaker'**
  String get quoteSpeakerLabel;

  /// No description provided for @lemmaLabel.
  ///
  /// In en, this message translates to:
  /// **'Lemma'**
  String get lemmaLabel;

  /// No description provided for @morphologyLabel.
  ///
  /// In en, this message translates to:
  /// **'Morphology'**
  String get morphologyLabel;

  /// No description provided for @translationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Translation not available.'**
  String get translationNotAvailable;

  /// No description provided for @currentTranslationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Current translation is not available.'**
  String get currentTranslationNotAvailable;

  /// No description provided for @saveNoteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save note. Please try again.'**
  String get saveNoteFailed;

  /// No description provided for @saveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAction;

  /// No description provided for @noteFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteFieldLabel;

  /// No description provided for @noteFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note here.'**
  String get noteFieldHint;

  /// No description provided for @primaryVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary Verse'**
  String get primaryVerseTitle;

  /// No description provided for @removeVerseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove verse?'**
  String get removeVerseTitle;

  /// No description provided for @addVerseAction.
  ///
  /// In en, this message translates to:
  /// **'Add Verse'**
  String get addVerseAction;

  /// No description provided for @connectedHighlightTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected Highlight'**
  String get connectedHighlightTitle;

  /// No description provided for @noneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneOption;

  /// No description provided for @connectedHighlightDescription.
  ///
  /// In en, this message translates to:
  /// **'This note will keep a connected verse highlight on its primary verse.'**
  String get connectedHighlightDescription;

  /// No description provided for @labelsFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get labelsFieldLabel;

  /// No description provided for @labelsFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Comma separated labels'**
  String get labelsFieldHint;

  /// No description provided for @onlyStandaloneHighlightsRemovable.
  ///
  /// In en, this message translates to:
  /// **'Only standalone highlights can be removed here. Edit a note to change its highlight.'**
  String get onlyStandaloneHighlightsRemovable;

  /// No description provided for @noteVerseLimit.
  ///
  /// In en, this message translates to:
  /// **'Notes can be linked to up to {count} verses at once. Please select a smaller range.'**
  String noteVerseLimit(int count);

  /// No description provided for @deleteAnnotationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete?'**
  String get deleteAnnotationTitle;

  /// No description provided for @deleteAnnotationDescription.
  ///
  /// In en, this message translates to:
  /// **'This note or highlight will be permanently removed.'**
  String get deleteAnnotationDescription;

  /// No description provided for @noReferenceHistory.
  ///
  /// In en, this message translates to:
  /// **'No reference history yet.'**
  String get noReferenceHistory;

  /// No description provided for @recentReferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent References'**
  String get recentReferencesTitle;

  /// No description provided for @referencesTitle.
  ///
  /// In en, this message translates to:
  /// **'References'**
  String get referencesTitle;

  /// No description provided for @historyTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTooltip;

  /// No description provided for @searchBooksHint.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get searchBooksHint;

  /// No description provided for @chaptersLabel.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chaptersLabel;

  /// No description provided for @goToReference.
  ///
  /// In en, this message translates to:
  /// **'Go to {reference}'**
  String goToReference(Object reference);

  /// No description provided for @versesInChapter.
  ///
  /// In en, this message translates to:
  /// **'Verses in {chapter}'**
  String versesInChapter(Object chapter);

  /// No description provided for @keepOneTranslationMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one translation on this device. Download or import another one before removing this one.'**
  String get keepOneTranslationMessage;

  /// No description provided for @hymnsTab.
  ///
  /// In en, this message translates to:
  /// **'Hymns'**
  String get hymnsTab;

  /// No description provided for @hymnSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Number, title, words or author'**
  String get hymnSearchHint;

  /// No description provided for @hymnSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get hymnSortTooltip;

  /// No description provided for @hymnSortNumber.
  ///
  /// In en, this message translates to:
  /// **'By number'**
  String get hymnSortNumber;

  /// No description provided for @hymnSortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get hymnSortAlphabetical;

  /// No description provided for @hymnFavoritesOnly.
  ///
  /// In en, this message translates to:
  /// **'Show favorites'**
  String get hymnFavoritesOnly;

  /// No description provided for @hymnShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all hymns'**
  String get hymnShowAll;

  /// No description provided for @hymnCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Hymns'**
  String get hymnCountLabel;

  /// No description provided for @hymnNoResults.
  ///
  /// In en, this message translates to:
  /// **'No hymns match your search.'**
  String get hymnNoResults;

  /// No description provided for @hymnNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet. Tap the star on a hymn to add it.'**
  String get hymnNoFavorites;

  /// No description provided for @hymnPickHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a hymn to read it here.'**
  String get hymnPickHint;

  /// No description provided for @hymnalLoadError.
  ///
  /// In en, this message translates to:
  /// **'This hymn book could not be opened.'**
  String get hymnalLoadError;

  /// No description provided for @hymnChorusLabel.
  ///
  /// In en, this message translates to:
  /// **'Chorus'**
  String get hymnChorusLabel;

  /// No description provided for @hymnOptionalChorus.
  ///
  /// In en, this message translates to:
  /// **'Optional chorus'**
  String get hymnOptionalChorus;

  /// No description provided for @hymnOptionalVerse.
  ///
  /// In en, this message translates to:
  /// **'Optional verse'**
  String get hymnOptionalVerse;

  /// No description provided for @hymnAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get hymnAddFavorite;

  /// No description provided for @hymnRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get hymnRemoveFavorite;

  /// No description provided for @hymnCopied.
  ///
  /// In en, this message translates to:
  /// **'Hymn copied'**
  String get hymnCopied;

  /// No description provided for @hymnPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get hymnPrint;

  /// No description provided for @hymnPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous hymn'**
  String get hymnPrevious;

  /// No description provided for @hymnNext.
  ///
  /// In en, this message translates to:
  /// **'Next hymn'**
  String get hymnNext;

  /// No description provided for @hymnDisplaySettings.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get hymnDisplaySettings;

  /// No description provided for @hymnTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get hymnTextSize;

  /// No description provided for @hymnChorusEveryVerse.
  ///
  /// In en, this message translates to:
  /// **'Show chorus after every verse'**
  String get hymnChorusEveryVerse;

  /// No description provided for @hymnChorusEveryVerseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When off, the chorus appears once after verse 1, as in the printed book.'**
  String get hymnChorusEveryVerseSubtitle;

  /// No description provided for @hymnShowDetails.
  ///
  /// In en, this message translates to:
  /// **'Show author, meter and tune'**
  String get hymnShowDetails;

  /// No description provided for @hymnShowOptional.
  ///
  /// In en, this message translates to:
  /// **'Show optional verses and choruses'**
  String get hymnShowOptional;

  /// No description provided for @hymnAboutBook.
  ///
  /// In en, this message translates to:
  /// **'About this book'**
  String get hymnAboutBook;

  /// No description provided for @hymnReportConcern.
  ///
  /// In en, this message translates to:
  /// **'Report a copyright concern'**
  String get hymnReportConcern;

  /// No description provided for @hymnReportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open the report page. Please try again later.'**
  String get hymnReportUnavailable;

  /// No description provided for @hymnalPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get hymnalPublisher;

  /// No description provided for @hymnalEdition.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get hymnalEdition;

  /// No description provided for @hymnalIsbn.
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get hymnalIsbn;

  /// No description provided for @hymnalCopyright.
  ///
  /// In en, this message translates to:
  /// **'Copyright'**
  String get hymnalCopyright;

  /// No description provided for @hymnalPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get hymnalPermission;

  /// No description provided for @hymnalSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get hymnalSource;

  /// No description provided for @hymnalSourceBundled.
  ///
  /// In en, this message translates to:
  /// **'Included with the app'**
  String get hymnalSourceBundled;

  /// No description provided for @hymnalSourceImported.
  ///
  /// In en, this message translates to:
  /// **'Imported from a file on this device'**
  String get hymnalSourceImported;

  /// No description provided for @hymnalSourceRepository.
  ///
  /// In en, this message translates to:
  /// **'Downloaded from {source}'**
  String hymnalSourceRepository(String source);

  /// No description provided for @hymnalSourceBundledShort.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get hymnalSourceBundledShort;

  /// No description provided for @hymnalSourceImportedShort.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get hymnalSourceImportedShort;

  /// No description provided for @hymnalSourceRepositoryShort.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get hymnalSourceRepositoryShort;

  /// No description provided for @hymnalThirdPartyNotice.
  ///
  /// In en, this message translates to:
  /// **'This book did not come with the app. Its rights are the responsibility of whoever provided it.'**
  String get hymnalThirdPartyNotice;

  /// No description provided for @hymnalLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Hymn books'**
  String get hymnalLibraryTitle;

  /// No description provided for @hymnalManageBooks.
  ///
  /// In en, this message translates to:
  /// **'Manage hymn books'**
  String get hymnalManageBooks;

  /// No description provided for @hymnalInstalledSection.
  ///
  /// In en, this message translates to:
  /// **'On this device'**
  String get hymnalInstalledSection;

  /// No description provided for @hymnalAvailableSection.
  ///
  /// In en, this message translates to:
  /// **'Available from repositories'**
  String get hymnalAvailableSection;

  /// No description provided for @hymnalImportFile.
  ///
  /// In en, this message translates to:
  /// **'Import a hymn book file'**
  String get hymnalImportFile;

  /// No description provided for @hymnalImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hymn book JSON files (.json or .json.gz)'**
  String get hymnalImportSubtitle;

  /// No description provided for @hymnalImported.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\"'**
  String hymnalImported(String title);

  /// No description provided for @hymnalImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not import: {error}'**
  String hymnalImportFailed(String error);

  /// No description provided for @hymnalOpenBook.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get hymnalOpenBook;

  /// No description provided for @hymnalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\"?'**
  String hymnalDeleteTitle(String title);

  /// No description provided for @hymnalDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The book is removed from this device. Your favorites for it are kept in case you add it again.'**
  String get hymnalDeleteMessage;

  /// No description provided for @hymnalNoRepoBooks.
  ///
  /// In en, this message translates to:
  /// **'No hymn books are available from your repositories yet.'**
  String get hymnalNoRepoBooks;

  /// No description provided for @hymnalDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get hymnalDownload;

  /// No description provided for @hymnalDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get hymnalDownloaded;

  /// No description provided for @hymnalNotDownloadable.
  ///
  /// In en, this message translates to:
  /// **'Listed only — not offered for download'**
  String get hymnalNotDownloadable;

  /// No description provided for @hymnalDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String hymnalDownloadFailed(String error);

  /// No description provided for @manageRepositories.
  ///
  /// In en, this message translates to:
  /// **'Manage repositories'**
  String get manageRepositories;

  /// No description provided for @manageRepositoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where hymn books can be downloaded from'**
  String get manageRepositoriesSubtitle;

  /// No description provided for @repositoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Repositories'**
  String get repositoriesTitle;

  /// No description provided for @repositoriesIntro.
  ///
  /// In en, this message translates to:
  /// **'Repositories list hymn books you can download. The official repository is run by this app\'s developers; any others are run by third parties.'**
  String get repositoriesIntro;

  /// No description provided for @repositoryOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get repositoryOfficial;

  /// No description provided for @repositoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add repository'**
  String get repositoryAdd;

  /// No description provided for @repositoryUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Repository address (https://…)'**
  String get repositoryUrlLabel;

  /// No description provided for @repositoryCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get repositoryCheck;

  /// No description provided for @repositoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\"'**
  String repositoryAdded(String name);

  /// No description provided for @repositoryAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the repository: {error}'**
  String repositoryAddFailed(String error);

  /// No description provided for @repositoryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get repositoryRefresh;

  /// No description provided for @repositoryRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get repositoryRemove;

  /// No description provided for @repositoryRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"?'**
  String repositoryRemoveTitle(String name);

  /// No description provided for @repositoryRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Hymn books downloaded from this repository will also be removed from this device.'**
  String get repositoryRemoveMessage;

  /// No description provided for @repositoryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this repository right now.'**
  String get repositoryLoadFailed;

  /// No description provided for @repositoryMaintainer.
  ///
  /// In en, this message translates to:
  /// **'Maintained by {name}'**
  String repositoryMaintainer(String name);

  /// No description provided for @repositoryOwnerNote.
  ///
  /// In en, this message translates to:
  /// **'From the repository owner:'**
  String get repositoryOwnerNote;

  /// No description provided for @repositoryDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-party repository'**
  String get repositoryDisclaimerTitle;

  /// No description provided for @repositoryDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'This repository is run by a third party, not by the developers of this app. We do not host, review or distribute its content, and we cannot confirm that its owner has permission to share it. You are responsible for what you download. To report a copyright problem with a book from this repository, use \"Report a copyright concern\" on that book\'s About page, which contacts the repository owner.'**
  String get repositoryDisclaimerBody;

  /// No description provided for @repositoryDisclaimerAccept.
  ///
  /// In en, this message translates to:
  /// **'I understand this content is not provided by this app'**
  String get repositoryDisclaimerAccept;

  /// No description provided for @legalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & takedown requests'**
  String get legalTitle;

  /// No description provided for @legalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content rights, third-party sources and how to request removal'**
  String get legalSubtitle;

  /// No description provided for @legalBundledHeading.
  ///
  /// In en, this message translates to:
  /// **'Content included with the app'**
  String get legalBundledHeading;

  /// No description provided for @legalBundledBody.
  ///
  /// In en, this message translates to:
  /// **'Hymn books included with the app are distributed with their publishers\' permission. Each book\'s copyright and permission notices are shown on its About page and are added to every hymn you copy, share or print.'**
  String get legalBundledBody;

  /// No description provided for @legalThirdPartyHeading.
  ///
  /// In en, this message translates to:
  /// **'Third-party repositories'**
  String get legalThirdPartyHeading;

  /// No description provided for @legalThirdPartyBody.
  ///
  /// In en, this message translates to:
  /// **'Repositories you add yourself are run by other people. Their content is not hosted, reviewed or distributed by the developers of this app, and we make no promise that their owners have the right to share it. Requests about that content should go to the repository owner, whose contact is shown on each book\'s About page.'**
  String get legalThirdPartyBody;

  /// No description provided for @legalImportedHeading.
  ///
  /// In en, this message translates to:
  /// **'Files you import'**
  String get legalImportedHeading;

  /// No description provided for @legalImportedBody.
  ///
  /// In en, this message translates to:
  /// **'Imported files stay on your device and are never shared by the app. Only import files you have the right to use.'**
  String get legalImportedBody;

  /// No description provided for @legalTakedownHeading.
  ///
  /// In en, this message translates to:
  /// **'Takedown requests'**
  String get legalTakedownHeading;

  /// No description provided for @legalTakedownBody.
  ///
  /// In en, this message translates to:
  /// **'If you hold the rights to content included with the app or listed in the official repository and want it removed, send a takedown request. Name the book and hymn numbers, the work you own, and how we can reach you. Once a request is confirmed, the content is withdrawn from the official repository, and withdrawn books are removed from devices the next time the app refreshes its repositories.'**
  String get legalTakedownBody;

  /// No description provided for @legalReportButton.
  ///
  /// In en, this message translates to:
  /// **'Send a takedown request'**
  String get legalReportButton;

  /// No description provided for @hymnCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hymn} other{{count} hymns}}'**
  String hymnCount(int count);

  /// No description provided for @repositoryGuide.
  ///
  /// In en, this message translates to:
  /// **'How repositories work, and how to make your own'**
  String get repositoryGuide;

  /// No description provided for @hymnalNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name this hymn book'**
  String get hymnalNameTitle;

  /// No description provided for @hymnalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get hymnalNameLabel;

  /// No description provided for @hymnalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get hymnalNameRequired;

  /// No description provided for @hymnalShortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Short name (optional)'**
  String get hymnalShortNameLabel;

  /// No description provided for @hymnalShortNameHelper.
  ///
  /// In en, this message translates to:
  /// **'Shown at the top of the Hymns tab, e.g. BHB'**
  String get hymnalShortNameHelper;

  /// No description provided for @hymnalImportAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get hymnalImportAction;

  /// No description provided for @hymnalImportFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Found 1 hymn.} other{Found {count} hymns.}}'**
  String hymnalImportFound(int count);

  /// No description provided for @hymnalImportReplaces.
  ///
  /// In en, this message translates to:
  /// **'This book is already on this device. Importing replaces it; your favorites are kept.'**
  String get hymnalImportReplaces;

  /// No description provided for @hymnalRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get hymnalRename;

  /// No description provided for @hymnalRenameAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get hymnalRenameAction;

  /// No description provided for @hymnalImportGuide.
  ///
  /// In en, this message translates to:
  /// **'How to import'**
  String get hymnalImportGuide;

  /// No description provided for @hymnalMakeGuide.
  ///
  /// In en, this message translates to:
  /// **'Make your own hymn book file'**
  String get hymnalMakeGuide;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get linkOpenFailed;

  /// No description provided for @reportChooseRoute.
  ///
  /// In en, this message translates to:
  /// **'How would you like to send it?'**
  String get reportChooseRoute;

  /// No description provided for @reportByEmail.
  ///
  /// In en, this message translates to:
  /// **'Email {email}'**
  String reportByEmail(String email);

  /// No description provided for @reportByEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Private. Opens your email app.'**
  String get reportByEmailSubtitle;

  /// No description provided for @reportByGitHub.
  ///
  /// In en, this message translates to:
  /// **'Open a GitHub issue'**
  String get reportByGitHub;

  /// No description provided for @reportByGitHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public: anyone can read it. Needs a GitHub account.'**
  String get reportByGitHubSubtitle;

  /// No description provided for @reportNoEmailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app opened. Write to {email}.'**
  String reportNoEmailApp(String email);

  /// No description provided for @hymnTextSmaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get hymnTextSmaller;

  /// No description provided for @hymnTextLarger.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get hymnTextLarger;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
