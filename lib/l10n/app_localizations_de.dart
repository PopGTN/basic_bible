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
  String get menu => 'Menü';

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
  String get versionsTitle => 'Versionen';

  @override
  String get searchTranslationsTooltip => 'Übersetzungen suchen';

  @override
  String get importBibleFileAction => 'Bibeldatei importieren';

  @override
  String get clearTranslationCacheAction => 'Übersetzungs-Cache leeren';

  @override
  String get clearTranslationCacheTitle => 'Übersetzungs-Cache leeren?';

  @override
  String get clearTranslationCacheDescription => 'Dadurch werden heruntergeladene Übersetzungsdateien, importierte Quellkopien und veraltete Registereinträge aus dem lokalen App-Speicher entfernt. Mitgelieferte Übersetzungen bleiben verfügbar.';

  @override
  String get clearCacheAction => 'Cache leeren';

  @override
  String get clearedTranslationCacheMessage => 'Übersetzungs-Cache geleert.';

  @override
  String couldNotClearTranslationCache(Object error) {
    return 'Übersetzungs-Cache konnte nicht geleert werden: $error';
  }

  @override
  String get translationsFileTypeLabel => 'Bibeldateien';

  @override
  String unableToLoadTranslations(Object error) {
    return 'Übersetzungen konnten nicht geladen werden: $error';
  }

  @override
  String couldNotSwitchTranslation(Object error) {
    return 'Übersetzung konnte nicht gewechselt werden: $error';
  }

  @override
  String importedTranslationMessage(Object name) {
    return '$name importiert.';
  }

  @override
  String importFailedMessage(Object error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String deleteTranslationTitle(Object name) {
    return '$name löschen?';
  }

  @override
  String get deleteImportedTranslationDescription => 'Dadurch wird die importierte Bibel aus der App-Bibliothek und dem Cache entfernt. Die Originaldatei auf dem Datenträger wird nicht gelöscht.';

  @override
  String get cancelAction => 'Abbrechen';

  @override
  String get deleteAction => 'Löschen';

  @override
  String deletedTranslationMessage(Object name) {
    return '$name gelöscht.';
  }

  @override
  String couldNotDeleteTranslation(Object error) {
    return 'Übersetzung konnte nicht gelöscht werden: $error';
  }

  @override
  String removeDownloadedTranslationTitle(Object name) {
    return 'Download von $name entfernen?';
  }

  @override
  String get removeDownloadedTranslationDescription => 'Dadurch wird die heruntergeladene Bibel aus dem lokalen App-Speicher entfernt. Sie bleibt in der Bibliothek zum Herunterladen verfügbar, sodass du sie später erneut laden kannst.';

  @override
  String get removeAction => 'Entfernen';

  @override
  String removedLocalDownloadMessage(Object name) {
    return 'Lokaler Download von $name entfernt.';
  }

  @override
  String couldNotRemoveDownload(Object error) {
    return 'Download konnte nicht entfernt werden: $error';
  }

  @override
  String get moreActionsTooltip => 'Weitere Aktionen';

  @override
  String get deleteImportAction => 'Import löschen';

  @override
  String get removeDownloadAction => 'Download entfernen';

  @override
  String get availableOfflineTooltip => 'Offline verfügbar';

  @override
  String get downloadTranslationTooltip => 'Übersetzung herunterladen';

  @override
  String get audioOptionsTooltip => 'Audiooptionen';

  @override
  String get bundledTranslationSource => 'Mitgeliefert';

  @override
  String get downloadedTranslationSource => 'Heruntergeladen';

  @override
  String get downloadableTranslationSource => 'Herunterladbar';

  @override
  String get importedTranslationSource => 'Importiert';

  @override
  String get importBibleTitle => 'Bibel importieren';

  @override
  String unableToPrepareImport(Object error) {
    return 'Import konnte nicht vorbereitet werden: $error';
  }

  @override
  String get translationDetailsTitle => 'Übersetzungsdetails';

  @override
  String get translationDetailsDescription => 'Lege Name, Abkürzung, Sprachcode und Beschreibung fest, bevor der Import gespeichert wird.';

  @override
  String get translationNameLabel => 'Name';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired => 'Gib einen Namen für die Übersetzung ein.';

  @override
  String get translationAbbreviationLabel => 'Abkürzung';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp => 'Wird genauso verwendet wie die mitgelieferten Abkürzungen KJV und ASV.';

  @override
  String get translationAbbreviationRequired => 'Gib eine Abkürzung ein.';

  @override
  String get translationAbbreviationTaken => 'Diese Abkürzung wird bereits verwendet.';

  @override
  String get translationLanguageCodeLabel => 'Sprachcode';

  @override
  String get translationLanguageCodeHint => 'de';

  @override
  String get translationLanguageCodeHelp => 'Verwende einen kurzen Code wie en, es, fr oder de.';

  @override
  String get translationLanguageCodeRequired => 'Gib einen Sprachcode ein.';

  @override
  String get translationDescriptionLabel => 'Beschreibung';

  @override
  String get translationDescriptionHint => 'Importiert aus my_local_bible.xml oder my_translation.sqlite';

  @override
  String get importingAction => 'Wird importiert...';

  @override
  String get importTranslationAction => 'Übersetzung importieren';

  @override
  String detectedFormatLabel(Object format) {
    return 'Erkanntes Format: $format';
  }

  @override
  String booksFoundLabel(int count) {
    return 'Gefundene Bücher: $count';
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

  @override
  String get searchBibleHint => 'Bibel durchsuchen';

  @override
  String get clearAction => 'Löschen';

  @override
  String get searchTypePrompt => 'Gib ein Wort oder einen Ausdruck ein, um zu suchen.';

  @override
  String searchFailed(Object error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get searchNoResults => 'Keine Verse gefunden.';

  @override
  String searchResultsCapped(int limit) {
    return 'Die ersten $limit Verse werden angezeigt. Füge Wörter hinzu, um die Suche einzugrenzen.';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Verse',
      one: '1 Vers',
    );
    return '$_temp0';
  }

  @override
  String get searchScopeAll => 'Ganze Bibel';

  @override
  String get searchScopeOldTestament => 'Altes Testament';

  @override
  String get searchScopeNewTestament => 'Neues Testament';

  @override
  String get searchScopeCurrentBook => 'Dieses Buch';

  @override
  String get searchScopeCurrentChapter => 'Dieses Kapitel';

  @override
  String get splitViewTooltip => 'Geteilte Ansicht';

  @override
  String get closeSplitViewTooltip => 'Geteilte Ansicht schließen';

  @override
  String get paneTranslationTooltip => 'Übersetzung für diesen Bereich';

  @override
  String couldNotLoadTranslation(Object error) {
    return 'Diese Übersetzung konnte nicht geladen werden: $error';
  }

  @override
  String get chapterNotFound => 'Kapitel nicht gefunden';

  @override
  String get noteDateFieldModified => 'Zuletzt geändert';

  @override
  String get noteDateFieldCreated => 'Erstellt';

  @override
  String get noteDateRangeAny => 'Beliebiger Zeitraum';

  @override
  String get noteDateRangeToday => 'Heute';

  @override
  String get noteDateRangePastWeek => 'Letzte Woche';

  @override
  String get noteDateRangePastMonth => 'Letzter Monat';

  @override
  String get noteDateRangePastYear => 'Letztes Jahr';

  @override
  String get noteTypeNote => 'Notiz';

  @override
  String get noteTypeHighlightOnly => 'Nur Markierung';

  @override
  String get notesDateButton => 'Datum';

  @override
  String get notesDateButtonCreated => 'Datum: Erstellt';

  @override
  String notesDateCreatedRange(Object range) {
    return 'Erstellt: $range';
  }

  @override
  String get notesDateShowSection => 'Anzeigen';

  @override
  String get notesDateSortSection => 'Nach Datum (neueste zuerst)';

  @override
  String get linkedVersesTitle => 'Verknüpfte Verse';

  @override
  String get showLessAction => 'Weniger anzeigen';

  @override
  String showAllCountAction(int count) {
    return 'Alle anzeigen (+$count)';
  }

  @override
  String get readFrontMatterAction => 'Lesen';

  @override
  String get boldWordsOfJesusTitle => 'Worte Jesu fett';

  @override
  String get boldWordsOfJesusSubtitle => 'Zeigt die Worte Jesu fett und rot an. Standardmäßig aus, wie bei den meisten Bibeln mit roten Jesusworten.';

  @override
  String get openSourceLicensesTitle => 'Open-Source-Lizenzen';

  @override
  String get openSourceLicensesSubtitle => 'Von dieser App verwendete Bibliotheken und Code';

  @override
  String get exportTranslationHelp => 'Exportiert die SQLite-Datei einer auf diesem Gerät gespeicherten Übersetzung. Lade eine Übersetzung unter Übersetzungen herunter, um sie zu exportieren.';

  @override
  String get noDownloadedTranslationsToExport => 'Keine heruntergeladenen Übersetzungen zum Exportieren.';

  @override
  String get downloadNotificationChannelName => 'Bibel-Downloads';

  @override
  String get downloadNotificationChannelDescription => 'Fortschritt beim Herunterladen von Bibelübersetzungen';

  @override
  String get downloadNotificationStarting => 'Wird gestartet…';

  @override
  String get downloadNotificationInstalling => 'Wird installiert…';

  @override
  String downloadNotificationProgressTitle(Object name) {
    return '$name wird heruntergeladen';
  }

  @override
  String downloadNotificationDoneTitle(Object name) {
    return '$name heruntergeladen';
  }

  @override
  String get downloadNotificationDoneBody => 'Bereit zum Offline-Lesen.';

  @override
  String get downloadNotificationFailedTitle => 'Download fehlgeschlagen';

  @override
  String downloadNotificationFailedBody(Object name) {
    return '$name konnte nicht heruntergeladen werden.';
  }
}
