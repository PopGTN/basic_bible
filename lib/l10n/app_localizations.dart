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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
    Locale('zh')
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
