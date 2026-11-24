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
  String get aboutDescription =>
      'Diese Bibel-App ist ein kostenloses Projekt von PopGTN. Es ist ein Übungsprojekt zum Lernen von Flutter und Dart. Die App ermöglicht das Lesen der Bibel, das Erstellen von Notizen, TTS-Unterstützung und mehr. Sie ist inspiriert von Apps wie YouVersion Bible, jedoch mit zusätzlichen Funktionen und einer verbesserten Benutzeroberfläche.';

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
  String get clearTranslationCacheDescription =>
      'Dadurch werden heruntergeladene Übersetzungsdateien, importierte Quellkopien und veraltete Registereinträge aus dem lokalen App-Speicher entfernt. Mitgelieferte Übersetzungen bleiben verfügbar.';

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
  String get deleteImportedTranslationDescription =>
      'Dadurch wird die importierte Bibel aus der App-Bibliothek und dem Cache entfernt. Die Originaldatei auf dem Datenträger wird nicht gelöscht.';

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
  String get removeDownloadedTranslationDescription =>
      'Dadurch wird die heruntergeladene Bibel aus dem lokalen App-Speicher entfernt. Sie bleibt in der Bibliothek zum Herunterladen verfügbar, sodass du sie später erneut laden kannst.';

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
  String get translationDetailsDescription =>
      'Lege Name, Abkürzung, Sprachcode und Beschreibung fest, bevor der Import gespeichert wird.';

  @override
  String get translationNameLabel => 'Name';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired =>
      'Gib einen Namen für die Übersetzung ein.';

  @override
  String get translationAbbreviationLabel => 'Abkürzung';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp =>
      'Wird genauso verwendet wie die mitgelieferten Abkürzungen KJV und ASV.';

  @override
  String get translationAbbreviationRequired => 'Gib eine Abkürzung ein.';

  @override
  String get translationAbbreviationTaken =>
      'Diese Abkürzung wird bereits verwendet.';

  @override
  String get translationLanguageCodeLabel => 'Sprachcode';

  @override
  String get translationLanguageCodeHint => 'de';

  @override
  String get translationLanguageCodeHelp =>
      'Verwende einen kurzen Code wie en, es, fr oder de.';

  @override
  String get translationLanguageCodeRequired => 'Gib einen Sprachcode ein.';

  @override
  String get translationDescriptionLabel => 'Beschreibung';

  @override
  String get translationDescriptionHint =>
      'Importiert aus my_local_bible.xml oder my_translation.sqlite';

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
  String get importNotAvailableOnWeb =>
      'Importing local Bible files is not available in the browser yet.';

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
  String get readerFontRemoveDescription =>
      'Die importierte Schriftartdatei wird von diesem Gerät gelöscht.';

  @override
  String get readerFontSearchHint => 'Installierte Schriftarten durchsuchen';

  @override
  String get readerFontNoInstalled =>
      'Keine installierten Schriftarten gefunden.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Keine Schriftart passt zu „$query“.';
  }

  @override
  String get readerFontScanUnsupported =>
      'Installierte Schriftarten können auf dieser Plattform nicht aufgelistet werden';

  @override
  String get readerFontScanUnsupportedHint =>
      'Importiere stattdessen eine Schriftartdatei.';

  @override
  String readerFontImported(Object fontName) {
    return '$fontName importiert.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return '$fontName konnte nicht geladen werden.';
  }

  @override
  String get readerFontUnsupportedType =>
      'Nur .ttf- und .otf-Schriftartdateien können importiert werden.';

  @override
  String get readerFontNotAFont =>
      'Diese Datei scheint keine gültige Schriftart zu sein.';

  @override
  String get readerFontUnloadable =>
      'Diese Schriftartdatei konnte nicht geladen werden.';

  @override
  String get readerFontImportFailed =>
      'Die Schriftart konnte nicht importiert werden.';

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
  String get translationRightsDownloadNotPermitted =>
      'Der Rechteinhaber erlaubt nicht, diese Übersetzung in der App herunterzuladen.';

  @override
  String get translationRightsUnknown =>
      'Für diese Übersetzung sind keine Urheberrechts- oder Lizenzangaben verfügbar.';

  @override
  String get translationRightsUnknownImported =>
      'Sie haben diese Übersetzung aus einer Datei importiert, daher hat die App keine Urheberrechts- oder Lizenzangaben dazu. Stellen Sie sicher, dass Sie sie verwenden dürfen.';

  @override
  String get searchBibleHint => 'Bibel durchsuchen';

  @override
  String get clearAction => 'Löschen';

  @override
  String get searchTypePrompt =>
      'Gib ein Wort oder einen Ausdruck ein, um zu suchen.';

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
  String get boldWordsOfJesusSubtitle =>
      'Zeigt die Worte Jesu fett und rot an. Standardmäßig aus, wie bei den meisten Bibeln mit roten Jesusworten.';

  @override
  String get openSourceLicensesTitle => 'Open-Source-Lizenzen';

  @override
  String get openSourceLicensesSubtitle =>
      'Von dieser App verwendete Bibliotheken und Code';

  @override
  String get exportTranslationHelp =>
      'Exportiert die SQLite-Datei einer auf diesem Gerät gespeicherten Übersetzung. Lade eine Übersetzung unter Übersetzungen herunter, um sie zu exportieren.';

  @override
  String get noDownloadedTranslationsToExport =>
      'Keine heruntergeladenen Übersetzungen zum Exportieren.';

  @override
  String get downloadNotificationChannelName => 'Bibel-Downloads';

  @override
  String get downloadNotificationChannelDescription =>
      'Fortschritt beim Herunterladen von Bibelübersetzungen';

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

  @override
  String get playAudioTooltip => 'Audio abspielen';

  @override
  String get splitFollowMainTitle =>
      'Geteilte Ansicht beim aktuellen Kapitel öffnen';

  @override
  String get splitFollowMainSubtitle =>
      'Beim Öffnen der geteilten Ansicht beginnt der zweite Bereich jedes Mal beim Kapitel des Hauptlesers. Standardmäßig aus: Der Bereich bleibt, wo du ihn verlassen hast, bis die App neu gestartet wird.';

  @override
  String get searchTooltip => 'Suchen';

  @override
  String get readerOptionsTooltip => 'Leseoptionen';

  @override
  String get relatedContentAction => 'Verwandte Inhalte';

  @override
  String get fontsAndSettingsAction => 'Schriften & Einstellungen';

  @override
  String get continuousScrollingTitle => 'Fortlaufendes Scrollen';

  @override
  String get documentModeTitle => 'Dokumentmodus';

  @override
  String get showNotesAcrossTranslationsTitle =>
      'Notizen in anderen Übersetzungen anzeigen';

  @override
  String get allSettingsAction => 'Alle Einstellungen';

  @override
  String get retryAction => 'Erneut versuchen';

  @override
  String get addNoteAction => 'Notiz hinzufügen';

  @override
  String get viewAction => 'Ansehen';

  @override
  String get crossReferencesTitle => 'Querverweise';

  @override
  String get noCrossReferences =>
      'Für diesen Vers sind keine Querverweise verfügbar.';

  @override
  String couldNotParseReference(Object label) {
    return 'Verweis konnte nicht gelesen werden: $label';
  }

  @override
  String get currentTranslationLabel => 'Aktuelle Übersetzung';

  @override
  String get backToDetailsAction => 'Zurück zu den Details';

  @override
  String get backToNoteAction => 'Zurück zur Notiz';

  @override
  String readerErrorMessage(Object error) {
    return 'Fehler: $error';
  }

  @override
  String failedToLoadBible(Object error) {
    return 'Bibel konnte nicht geladen werden: $error';
  }

  @override
  String get shareTextCopied =>
      'Text zum Teilen kopiert. Natives Teilen kann später hinzugefügt werden, ohne deine Notizen zu ändern.';

  @override
  String get highlightAction => 'Markieren';

  @override
  String get noteAction => 'Notiz';

  @override
  String get copyAction => 'Kopieren';

  @override
  String get shareAction => 'Teilen';

  @override
  String get noteHighlightsEditedFromNote =>
      'Notiz-Markierungen werden in der Notiz selbst bearbeitet.';

  @override
  String get previewUnavailable =>
      'Für diesen Verweis ist keine Vorschau verfügbar.';

  @override
  String get openInBibleAction => 'In der Bibel öffnen';

  @override
  String get previousChapterTooltip => 'Vorheriges Kapitel';

  @override
  String get nextChapterTooltip => 'Nächstes Kapitel';

  @override
  String get sourceDetailsTitle => 'Quelldetails';

  @override
  String get quoteSpeakerLabel => 'Sprecher des Zitats';

  @override
  String get lemmaLabel => 'Lemma';

  @override
  String get morphologyLabel => 'Morphologie';

  @override
  String get translationNotAvailable => 'Übersetzung nicht verfügbar.';

  @override
  String get currentTranslationNotAvailable =>
      'Die aktuelle Übersetzung ist nicht verfügbar.';

  @override
  String get saveNoteFailed =>
      'Notiz konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get saveAction => 'Speichern';

  @override
  String get noteFieldLabel => 'Notiz';

  @override
  String get noteFieldHint => 'Schreibe hier deine Notiz.';

  @override
  String get primaryVerseTitle => 'Hauptvers';

  @override
  String get removeVerseTitle => 'Vers entfernen?';

  @override
  String get addVerseAction => 'Vers hinzufügen';

  @override
  String get connectedHighlightTitle => 'Verknüpfte Markierung';

  @override
  String get noneOption => 'Keine';

  @override
  String get connectedHighlightDescription =>
      'Diese Notiz behält eine verknüpfte Markierung auf ihrem Hauptvers.';

  @override
  String get labelsFieldLabel => 'Labels';

  @override
  String get labelsFieldHint => 'Labels durch Kommas getrennt';

  @override
  String get onlyStandaloneHighlightsRemovable =>
      'Hier können nur eigenständige Markierungen entfernt werden. Bearbeite eine Notiz, um ihre Markierung zu ändern.';

  @override
  String noteVerseLimit(int count) {
    return 'Notizen können mit bis zu $count Versen gleichzeitig verknüpft werden. Bitte wähle einen kleineren Bereich.';
  }

  @override
  String get deleteAnnotationTitle => 'Löschen?';

  @override
  String get deleteAnnotationDescription =>
      'Diese Notiz oder Markierung wird dauerhaft entfernt.';

  @override
  String get noReferenceHistory => 'Noch kein Verlauf.';

  @override
  String get recentReferencesTitle => 'Zuletzt geöffnet';

  @override
  String get referencesTitle => 'Bibelstellen';

  @override
  String get historyTooltip => 'Verlauf';

  @override
  String get searchBooksHint => 'Bücher suchen';

  @override
  String get chaptersLabel => 'Kapitel';

  @override
  String goToReference(Object reference) {
    return 'Gehe zu $reference';
  }

  @override
  String versesInChapter(Object chapter) {
    return 'Verse in $chapter';
  }

  @override
  String get keepOneTranslationMessage =>
      'Mindestens eine Übersetzung muss auf diesem Gerät bleiben. Lade eine andere herunter oder importiere sie, bevor du diese entfernst.';

  @override
  String get hymnsTab => 'Lieder';

  @override
  String get hymnSearchHint => 'Nummer, Titel, Text oder Autor';

  @override
  String get hymnSortTooltip => 'Sortieren';

  @override
  String get hymnSortNumber => 'Nach Nummer';

  @override
  String get hymnSortAlphabetical => 'Alphabetisch';

  @override
  String get hymnFavoritesOnly => 'Favoriten anzeigen';

  @override
  String get hymnShowAll => 'Alle Lieder anzeigen';

  @override
  String get hymnCountLabel => 'Lieder';

  @override
  String get hymnNoResults => 'Keine Lieder passen zu deiner Suche.';

  @override
  String get hymnNoFavorites =>
      'Noch keine Favoriten. Tippe auf den Stern bei einem Lied.';

  @override
  String get hymnPickHint => 'Wähle ein Lied, um es hier zu lesen.';

  @override
  String get hymnalLoadError =>
      'Dieses Liederbuch konnte nicht geöffnet werden.';

  @override
  String get hymnChorusLabel => 'Refrain';

  @override
  String get hymnOptionalChorus => 'Optionaler Refrain';

  @override
  String get hymnOptionalVerse => 'Optionale Strophe';

  @override
  String get hymnAddFavorite => 'Zu Favoriten hinzufügen';

  @override
  String get hymnRemoveFavorite => 'Aus Favoriten entfernen';

  @override
  String get hymnCopied => 'Lied kopiert';

  @override
  String get hymnPrint => 'Drucken';

  @override
  String get hymnPrevious => 'Vorheriges Lied';

  @override
  String get hymnNext => 'Nächstes Lied';

  @override
  String get hymnDisplaySettings => 'Anzeige';

  @override
  String get hymnTextSize => 'Textgröße';

  @override
  String get hymnChorusEveryVerse => 'Refrain nach jeder Strophe zeigen';

  @override
  String get hymnChorusEveryVerseSubtitle =>
      'Wenn aus, erscheint der Refrain einmal nach Strophe 1, wie im gedruckten Buch.';

  @override
  String get hymnShowDetails => 'Autor, Versmaß und Melodie zeigen';

  @override
  String get hymnShowOptional => 'Optionale Strophen und Refrains zeigen';

  @override
  String get hymnAboutBook => 'Über dieses Buch';

  @override
  String get hymnReportConcern => 'Urheberrechtsproblem melden';

  @override
  String get hymnReportUnavailable =>
      'Die Meldeseite konnte nicht geöffnet werden. Bitte später erneut versuchen.';

  @override
  String get hymnalPublisher => 'Verlag';

  @override
  String get hymnalEdition => 'Ausgabe';

  @override
  String get hymnalIsbn => 'ISBN';

  @override
  String get hymnalCopyright => 'Urheberrecht';

  @override
  String get hymnalPermission => 'Genehmigung';

  @override
  String get hymnalSource => 'Quelle';

  @override
  String get hymnalSourceBundled => 'In der App enthalten';

  @override
  String get hymnalSourceImported =>
      'Aus einer Datei auf diesem Gerät importiert';

  @override
  String hymnalSourceRepository(String source) {
    return 'Heruntergeladen von $source';
  }

  @override
  String get hymnalSourceBundledShort => 'Enthalten';

  @override
  String get hymnalSourceImportedShort => 'Importiert';

  @override
  String get hymnalSourceRepositoryShort => 'Heruntergeladen';

  @override
  String get hymnalThirdPartyNotice =>
      'Dieses Buch ist nicht Teil der App. Für die Rechte ist verantwortlich, wer es bereitgestellt hat.';

  @override
  String get hymnalLibraryTitle => 'Liederbücher';

  @override
  String get hymnalManageBooks => 'Liederbücher verwalten';

  @override
  String get hymnalInstalledSection => 'Auf diesem Gerät';

  @override
  String get hymnalAvailableSection => 'Aus Quellen verfügbar';

  @override
  String get hymnalImportFile => 'Liederbuch-Datei importieren';

  @override
  String get hymnalImportSubtitle =>
      'Liederbuch-JSON-Dateien (.json oder .json.gz)';

  @override
  String hymnalImported(String title) {
    return '„$title“ hinzugefügt';
  }

  @override
  String hymnalImportFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get hymnalOpenBook => 'Öffnen';

  @override
  String hymnalDeleteTitle(String title) {
    return '„$title“ entfernen?';
  }

  @override
  String get hymnalDeleteMessage =>
      'Das Buch wird von diesem Gerät entfernt. Deine Favoriten bleiben erhalten, falls du es erneut hinzufügst.';

  @override
  String get hymnalNoRepoBooks =>
      'Deine Quellen bieten noch keine Liederbücher an.';

  @override
  String get hymnalDownload => 'Herunterladen';

  @override
  String get hymnalDownloaded => 'Installiert';

  @override
  String get hymnalNotDownloadable =>
      'Nur gelistet – nicht zum Download angeboten';

  @override
  String hymnalDownloadFailed(String error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String get manageRepositories => 'Quellen verwalten';

  @override
  String get manageRepositoriesSubtitle =>
      'Woher Liederbücher heruntergeladen werden können';

  @override
  String get repositoriesTitle => 'Quellen';

  @override
  String get repositoriesIntro =>
      'Quellen listen Liederbücher zum Herunterladen auf. Die offizielle Quelle wird von den Entwicklern dieser App betrieben, alle anderen von Dritten.';

  @override
  String get repositoryOfficial => 'Offiziell';

  @override
  String get repositoryAdd => 'Quelle hinzufügen';

  @override
  String get repositoryUrlLabel => 'Adresse der Quelle (https://…)';

  @override
  String get repositoryCheck => 'Prüfen';

  @override
  String repositoryAdded(String name) {
    return '„$name“ hinzugefügt';
  }

  @override
  String repositoryAddFailed(String error) {
    return 'Quelle konnte nicht hinzugefügt werden: $error';
  }

  @override
  String get repositoryRefresh => 'Aktualisieren';

  @override
  String get repositoryRemove => 'Entfernen';

  @override
  String repositoryRemoveTitle(String name) {
    return '„$name“ entfernen?';
  }

  @override
  String get repositoryRemoveMessage =>
      'Von dieser Quelle heruntergeladene Liederbücher werden ebenfalls von diesem Gerät entfernt.';

  @override
  String get repositoryLoadFailed =>
      'Diese Quelle kann gerade nicht geladen werden.';

  @override
  String repositoryMaintainer(String name) {
    return 'Betreut von $name';
  }

  @override
  String get repositoryOwnerNote => 'Vom Betreiber der Quelle:';

  @override
  String get repositoryDisclaimerTitle => 'Quelle eines Drittanbieters';

  @override
  String get repositoryDisclaimerBody =>
      'Diese Quelle wird von Dritten betrieben, nicht von den Entwicklern dieser App. Wir hosten, prüfen oder verbreiten ihre Inhalte nicht und können nicht bestätigen, dass der Betreiber sie weitergeben darf. Du bist für deine Downloads verantwortlich. Urheberrechtsprobleme meldest du über „Urheberrechtsproblem melden“ auf der Infoseite des Buches; dies kontaktiert den Betreiber der Quelle.';

  @override
  String get repositoryDisclaimerAccept =>
      'Mir ist klar, dass diese Inhalte nicht von dieser App stammen';

  @override
  String get legalTitle => 'Rechtliches & Entfernungsanfragen';

  @override
  String get legalSubtitle =>
      'Inhaltsrechte, Drittquellen und Entfernungsanfragen';

  @override
  String get legalBundledHeading => 'In der App enthaltene Inhalte';

  @override
  String get legalBundledBody =>
      'Die in der App enthaltenen Liederbücher werden mit Genehmigung ihrer Verlage verbreitet. Urheberrechts- und Genehmigungshinweise stehen auf der Infoseite jedes Buches und werden jedem kopierten, geteilten oder gedruckten Lied beigefügt.';

  @override
  String get legalThirdPartyHeading => 'Quellen von Drittanbietern';

  @override
  String get legalThirdPartyBody =>
      'Selbst hinzugefügte Quellen werden von anderen betrieben. Ihre Inhalte werden von den Entwicklern dieser App weder gehostet noch geprüft oder verbreitet, und wir garantieren nicht, dass die Betreiber sie weitergeben dürfen. Anfragen zu diesen Inhalten richten sich an den Betreiber der Quelle; der Kontakt steht auf der Infoseite jedes Buches.';

  @override
  String get legalImportedHeading => 'Importierte Dateien';

  @override
  String get legalImportedBody =>
      'Importierte Dateien bleiben auf deinem Gerät und werden von der App nie geteilt. Importiere nur Dateien, die du nutzen darfst.';

  @override
  String get legalTakedownHeading => 'Entfernungsanfragen';

  @override
  String get legalTakedownBody =>
      'Wenn du Rechte an Inhalten der App oder der offiziellen Quelle hast und sie entfernen lassen möchtest, sende eine Entfernungsanfrage. Nenne Buch und Liednummern, dein Werk und wie wir dich erreichen. Nach Bestätigung wird der Inhalt aus der offiziellen Quelle zurückgezogen und beim nächsten Aktualisieren der Quellen von den Geräten entfernt.';

  @override
  String get legalReportButton => 'Entfernungsanfrage senden';

  @override
  String hymnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lieder',
      one: '1 Lied',
    );
    return '$_temp0';
  }

  @override
  String get repositoryGuide =>
      'Wie Quellen funktionieren und wie du eine eigene erstellst';

  @override
  String get hymnalNameTitle => 'Liederbuch benennen';

  @override
  String get hymnalNameLabel => 'Name';

  @override
  String get hymnalNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get hymnalShortNameLabel => 'Kurzname (optional)';

  @override
  String get hymnalShortNameHelper =>
      'Oben im Liederbereich angezeigt, z. B. BHB';

  @override
  String get hymnalImportAction => 'Importieren';

  @override
  String hymnalImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lieder gefunden.',
      one: '1 Lied gefunden.',
    );
    return '$_temp0';
  }

  @override
  String get hymnalImportReplaces =>
      'Dieses Buch ist bereits auf dem Gerät. Der Import ersetzt es; deine Favoriten bleiben erhalten.';

  @override
  String get hymnalRename => 'Umbenennen';

  @override
  String get hymnalRenameAction => 'Speichern';

  @override
  String get hymnalImportGuide => 'So importierst du';

  @override
  String get hymnalMakeGuide => 'Eigene Liederbuch-Datei erstellen';

  @override
  String get linkOpenFailed => 'Der Link konnte nicht geöffnet werden.';
}
