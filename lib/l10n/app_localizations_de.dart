// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get home => 'Startseite';

  @override
  String get bible => 'Bibel';

  @override
  String get about => 'Über';

  @override
  String get settings => 'Einstellungen';

  @override
  String get logout => 'Abmelden';

  @override
  String get goToOther => 'Zur anderen Seite gehen';

  @override
  String get aboutDescription => 'Diese Bibel-App ist ein kostenloses Projekt von PopGTN. Es ist ein Übungsprojekt zum Lernen von Flutter und Dart. Die App ermöglicht das Lesen der Bibel, das Erstellen von Notizen, TTS-Unterstützung und mehr. Sie ist inspiriert von Apps wie YouVersion Bible, jedoch mit zusätzlichen Funktionen und einer verbesserten Benutzeroberfläche.';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

  @override
  String get login => 'Anmelden';

  @override
  String get english => 'Englisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get french => 'Französisch';

  @override
  String get german => 'Deutsch';

  @override
  String get menu => 'Menu';

  @override
  String get readerFootnotesTooltip => 'Fußnoten und Verweise anzeigen';

  @override
  String get readerNotesTooltip => 'Persönliche Notizen anzeigen';

  @override
  String get savedNoteLabel => 'Gespeicherte Notiz';

  @override
  String get savedNotesLabel => 'Gespeicherte Notizen';

  @override
  String get openAction => 'Öffnen';

  @override
  String get editAction => 'Bearbeiten';

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
  String get languageFilterLabel => 'Sprache';

  @override
  String get allLanguagesOption => 'Alle Sprachen';

  @override
  String get selectLanguageTitle => 'Sprache auswählen';

  @override
  String get readerFontTitle => 'Schriftart';

  @override
  String get readerFontSystemDefault => 'Systemstandard';

  @override
  String get readerFontSectionDefault => 'Standard';

  @override
  String get readerFontSectionBundled => 'In der App enthalten';

  @override
  String get readerFontSectionImported => 'Deine Schriftarten';

  @override
  String get readerFontSectionInstalled => 'Auf diesem Gerät installiert';

  @override
  String get readerFontImportAction => 'Schriftartdatei importieren';

  @override
  String get readerFontImportHint => 'Wähle eine .ttf- oder .otf-Datei';

  @override
  String get readerFontFileTypeLabel => 'Schriftarten';

  @override
  String get readerFontRemoveTooltip => 'Schriftart entfernen';

  @override
  String readerFontRemoveTitle(Object fontName) {
    return '$fontName entfernen?';
  }

  @override
  String get readerFontRemoveDescription => 'Die importierte Schriftartdatei wird von diesem Gerät gelöscht.';

  @override
  String get readerFontSearchHint => 'Installierte Schriftarten durchsuchen';

  @override
  String get readerFontNoInstalled => 'Keine installierten Schriftarten gefunden.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Keine Schriftart passt zu „$query“.';
  }

  @override
  String get readerFontScanUnsupported => 'Installierte Schriftarten können auf dieser Plattform nicht aufgelistet werden';

  @override
  String get readerFontScanUnsupportedHint => 'Importiere stattdessen eine Schriftartdatei.';

  @override
  String readerFontImported(Object fontName) {
    return '$fontName importiert.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return '$fontName konnte nicht geladen werden.';
  }

  @override
  String get readerFontUnsupportedType => 'Nur .ttf- und .otf-Schriftartdateien können importiert werden.';

  @override
  String get readerFontNotAFont => 'Diese Datei scheint keine gültige Schriftart zu sein.';

  @override
  String get readerFontUnloadable => 'Diese Schriftartdatei konnte nicht geladen werden.';

  @override
  String get readerFontImportFailed => 'Die Schriftart konnte nicht importiert werden.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return '$fontName konnte nicht entfernt werden.';
  }

  @override
  String get readerFontPreviewSample => 'Am Anfang schuf Gott Himmel und Erde.';

  @override
  String get readerDecreaseTextSize => 'Text verkleinern';

  @override
  String get readerIncreaseTextSize => 'Text vergrößern';

  @override
  String get readerLineSpacingTitle => 'Zeilenabstand';

  @override
  String get readerLineSpacingCompact => 'Eng';

  @override
  String get readerLineSpacingNormal => 'Normal';

  @override
  String get readerLineSpacingRelaxed => 'Locker';

  @override
  String get readerLineSpacingLoose => 'Weit';

  @override
  String get translationAboutAction => 'Über diese Übersetzung';

  @override
  String get translationRightsLicenseLabel => 'Lizenz';

  @override
  String get translationRightsNoticeLabel => 'Urheberrechtshinweis';

  @override
  String get translationRightsPermissionsLabel => 'Berechtigungen';

  @override
  String get translationRightsPublicDomain => 'Gemeinfrei';

  @override
  String get translationRightsViewLicense => 'Lizenz ansehen';

  @override
  String get translationRightsSourceLabel => 'Offizielle Quelle';

  @override
  String get translationRightsNotesAction => 'Vollständige Lizenzhinweise';

  @override
  String get translationRightsDownloadNotPermitted => 'Der Rechteinhaber erlaubt nicht, diese Übersetzung in der App herunterzuladen.';

  @override
  String get translationRightsUnknown => 'Für diese Übersetzung sind keine Urheberrechts- oder Lizenzangaben verfügbar.';

  @override
  String get translationRightsUnknownImported => 'Sie haben diese Übersetzung aus einer Datei importiert, daher hat die App keine Urheberrechts- oder Lizenzangaben dazu. Stellen Sie sicher, dass Sie sie verwenden dürfen.';
}
