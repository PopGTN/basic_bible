// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get home => 'Accueil';

  @override
  String get bible => 'Bible';

  @override
  String get about => 'À propos';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get goToOther => 'Aller à l\'autre page';

  @override
  String get aboutDescription => 'Cette application Bible est un projet gratuit de PopGTN. C\'est un projet pratique pour apprendre Flutter et Dart. L\'application permet de lire la Bible, de prendre des notes, de bénéficier du support TTS, et plus encore. Elle est inspirée d\'applications comme YouVersion Bible mais avec des fonctionnalités supplémentaires et une interface améliorée.';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get login => 'Connexion';

  @override
  String get english => 'Anglais';

  @override
  String get spanish => 'Espagnol';

  @override
  String get french => 'Français';

  @override
  String get german => 'Allemand';

  @override
  String get menu => 'Menu';

  @override
  String get readerFootnotesTooltip => 'Voir les notes de bas de page et les références';

  @override
  String get readerNotesTooltip => 'Voir les notes personnelles';

  @override
  String get savedNoteLabel => 'Note enregistrée';

  @override
  String get savedNotesLabel => 'Notes enregistrées';

  @override
  String get openAction => 'Ouvrir';

  @override
  String get editAction => 'Modifier';

  @override
  String get versionsTitle => 'Versions';

  @override
  String get searchTranslationsTooltip => 'Rechercher des traductions';

  @override
  String get importBibleFileAction => 'Importer un fichier biblique';

  @override
  String get clearTranslationCacheAction => 'Vider le cache des traductions';

  @override
  String get clearTranslationCacheTitle => 'Vider le cache des traductions ?';

  @override
  String get clearTranslationCacheDescription => 'Cela supprime du stockage local de l\'application les fichiers de traductions téléchargées, les copies de sources importées et les entrées obsolètes du registre des traductions. Les traductions intégrées resteront disponibles.';

  @override
  String get clearCacheAction => 'Vider le cache';

  @override
  String get clearedTranslationCacheMessage => 'Cache des traductions vidé.';

  @override
  String couldNotClearTranslationCache(Object error) {
    return 'Impossible de vider le cache des traductions : $error';
  }

  @override
  String get translationsFileTypeLabel => 'Fichiers bibliques';

  @override
  String unableToLoadTranslations(Object error) {
    return 'Impossible de charger les traductions : $error';
  }

  @override
  String couldNotSwitchTranslation(Object error) {
    return 'Impossible de changer de traduction : $error';
  }

  @override
  String importedTranslationMessage(Object name) {
    return '$name importée.';
  }

  @override
  String importFailedMessage(Object error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String deleteTranslationTitle(Object name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteImportedTranslationDescription => 'Cela supprime la Bible importée de la bibliothèque et du cache de l\'application. Le fichier d\'origine sur le disque ne sera pas supprimé.';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String deletedTranslationMessage(Object name) {
    return '$name supprimée.';
  }

  @override
  String couldNotDeleteTranslation(Object error) {
    return 'Impossible de supprimer la traduction : $error';
  }

  @override
  String removeDownloadedTranslationTitle(Object name) {
    return 'Retirer le téléchargement de $name ?';
  }

  @override
  String get removeDownloadedTranslationDescription => 'Cela supprime la Bible téléchargée du stockage local de l\'application. Elle restera dans la bibliothèque comme option téléchargeable afin que vous puissiez la retélécharger plus tard.';

  @override
  String get removeAction => 'Retirer';

  @override
  String removedLocalDownloadMessage(Object name) {
    return 'Téléchargement local de $name retiré.';
  }

  @override
  String couldNotRemoveDownload(Object error) {
    return 'Impossible de retirer le téléchargement : $error';
  }

  @override
  String get moreActionsTooltip => 'Plus d\'actions';

  @override
  String get deleteImportAction => 'Supprimer l\'importation';

  @override
  String get removeDownloadAction => 'Retirer le téléchargement';

  @override
  String get availableOfflineTooltip => 'Disponible hors ligne';

  @override
  String get downloadTranslationTooltip => 'Télécharger la traduction';

  @override
  String get audioOptionsTooltip => 'Options audio';

  @override
  String get bundledTranslationSource => 'Intégrée';

  @override
  String get downloadedTranslationSource => 'Téléchargée';

  @override
  String get downloadableTranslationSource => 'Téléchargeable';

  @override
  String get importedTranslationSource => 'Importée';

  @override
  String get importBibleTitle => 'Importer une Bible';

  @override
  String unableToPrepareImport(Object error) {
    return 'Impossible de préparer l\'importation : $error';
  }

  @override
  String get translationDetailsTitle => 'Détails de la traduction';

  @override
  String get translationDetailsDescription => 'Définissez le nom, l\'abréviation, le code de langue et la description avant d\'enregistrer l\'importation.';

  @override
  String get translationNameLabel => 'Nom';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired => 'Saisissez un nom de traduction.';

  @override
  String get translationAbbreviationLabel => 'Abréviation';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp => 'Utilisée de la même façon que les abréviations intégrées comme KJV et ASV.';

  @override
  String get translationAbbreviationRequired => 'Saisissez une abréviation.';

  @override
  String get translationAbbreviationTaken => 'Cette abréviation est déjà utilisée.';

  @override
  String get translationLanguageCodeLabel => 'Code de langue';

  @override
  String get translationLanguageCodeHint => 'fr';

  @override
  String get translationLanguageCodeHelp => 'Utilisez un code court comme en, es, fr ou de.';

  @override
  String get translationLanguageCodeRequired => 'Saisissez un code de langue.';

  @override
  String get translationDescriptionLabel => 'Description';

  @override
  String get translationDescriptionHint => 'Importée depuis my_local_bible.xml ou my_translation.sqlite';

  @override
  String get importingAction => 'Importation...';

  @override
  String get importTranslationAction => 'Importer la traduction';

  @override
  String detectedFormatLabel(Object format) {
    return 'Format détecté : $format';
  }

  @override
  String booksFoundLabel(int count) {
    return 'Livres trouvés : $count';
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
  String get languageFilterLabel => 'Langue';

  @override
  String get allLanguagesOption => 'Toutes les langues';

  @override
  String get selectLanguageTitle => 'Sélectionner la langue';

  @override
  String get readerFontTitle => 'Police';

  @override
  String get readerFontSystemDefault => 'Par défaut du système';

  @override
  String get readerFontSectionDefault => 'Par défaut';

  @override
  String get readerFontSectionBundled => 'Incluses dans l’app';

  @override
  String get readerFontSectionImported => 'Vos polices';

  @override
  String get readerFontSectionInstalled => 'Installées sur cet appareil';

  @override
  String get readerFontImportAction => 'Importer un fichier de police';

  @override
  String get readerFontImportHint => 'Choisissez un fichier .ttf ou .otf';

  @override
  String get readerFontFileTypeLabel => 'Polices';

  @override
  String get readerFontRemoveTooltip => 'Supprimer la police';

  @override
  String readerFontRemoveTitle(Object fontName) {
    return 'Supprimer $fontName ?';
  }

  @override
  String get readerFontRemoveDescription => 'Le fichier de police importé sera supprimé de cet appareil.';

  @override
  String get readerFontSearchHint => 'Rechercher parmi les polices installées';

  @override
  String get readerFontNoInstalled => 'Aucune police installée n’a été trouvée.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Aucune police ne correspond à « $query ».';
  }

  @override
  String get readerFontScanUnsupported => 'Les polices installées ne peuvent pas être listées sur cette plateforme';

  @override
  String get readerFontScanUnsupportedHint => 'Importez plutôt un fichier de police.';

  @override
  String readerFontImported(Object fontName) {
    return '$fontName importée.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return 'Impossible de charger $fontName.';
  }

  @override
  String get readerFontUnsupportedType => 'Seuls les fichiers de police .ttf et .otf peuvent être importés.';

  @override
  String get readerFontNotAFont => 'Ce fichier ne semble pas être une police valide.';

  @override
  String get readerFontUnloadable => 'Impossible de charger ce fichier de police.';

  @override
  String get readerFontImportFailed => 'Impossible d’importer cette police.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return 'Impossible de supprimer $fontName.';
  }

  @override
  String get readerFontPreviewSample => 'Au commencement, Dieu créa les cieux et la terre.';

  @override
  String get readerDecreaseTextSize => 'Réduire le texte';

  @override
  String get readerIncreaseTextSize => 'Agrandir le texte';

  @override
  String get readerLineSpacingTitle => 'Interligne';

  @override
  String get readerLineSpacingCompact => 'Serré';

  @override
  String get readerLineSpacingNormal => 'Normal';

  @override
  String get readerLineSpacingRelaxed => 'Aéré';

  @override
  String get readerLineSpacingLoose => 'Large';

  @override
  String get translationAboutAction => 'À propos de cette traduction';

  @override
  String get translationRightsLicenseLabel => 'Licence';

  @override
  String get translationRightsNoticeLabel => 'Mention de droits d’auteur';

  @override
  String get translationRightsPermissionsLabel => 'Autorisations';

  @override
  String get translationRightsPublicDomain => 'Domaine public';

  @override
  String get translationRightsViewLicense => 'Voir la licence';

  @override
  String get translationRightsSourceLabel => 'Source officielle';

  @override
  String get translationRightsNotesAction => 'Notes de licence complètes';

  @override
  String get translationRightsDownloadNotPermitted => 'Le titulaire des droits n’autorise pas le téléchargement de cette traduction dans l’application.';

  @override
  String get translationRightsUnknown => 'Aucune information de droits d’auteur ni de licence n’est disponible pour cette traduction.';

  @override
  String get translationRightsUnknownImported => 'Vous avez importé cette traduction depuis un fichier ; l’application n’a donc aucune information de droits d’auteur ni de licence. Assurez-vous d’avoir le droit de l’utiliser.';

  @override
  String get searchBibleHint => 'Rechercher dans la Bible';

  @override
  String get clearAction => 'Effacer';

  @override
  String get searchTypePrompt => 'Saisissez un mot ou une expression à rechercher.';

  @override
  String searchFailed(Object error) {
    return 'La recherche a échoué : $error';
  }

  @override
  String get searchNoResults => 'Aucun verset trouvé.';

  @override
  String searchResultsCapped(int limit) {
    return 'Affichage des $limit premiers versets. Ajoutez des mots pour affiner la recherche.';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versets',
      one: '1 verset',
    );
    return '$_temp0';
  }

  @override
  String get searchScopeAll => 'Toute la Bible';

  @override
  String get searchScopeOldTestament => 'Ancien Testament';

  @override
  String get searchScopeNewTestament => 'Nouveau Testament';

  @override
  String get searchScopeCurrentBook => 'Ce livre';

  @override
  String get searchScopeCurrentChapter => 'Ce chapitre';

  @override
  String get splitViewTooltip => 'Vue partagée';

  @override
  String get closeSplitViewTooltip => 'Fermer la vue partagée';

  @override
  String get paneTranslationTooltip => 'Traduction pour ce panneau';

  @override
  String couldNotLoadTranslation(Object error) {
    return 'Impossible de charger cette traduction : $error';
  }

  @override
  String get chapterNotFound => 'Chapitre introuvable';

  @override
  String get noteDateFieldModified => 'Dernière modification';

  @override
  String get noteDateFieldCreated => 'Création';

  @override
  String get noteDateRangeAny => 'N\'importe quand';

  @override
  String get noteDateRangeToday => 'Aujourd\'hui';

  @override
  String get noteDateRangePastWeek => 'Semaine passée';

  @override
  String get noteDateRangePastMonth => 'Mois passé';

  @override
  String get noteDateRangePastYear => 'Année passée';

  @override
  String get noteTypeNote => 'Note';

  @override
  String get noteTypeHighlightOnly => 'Surlignage uniquement';

  @override
  String get notesDateButton => 'Date';

  @override
  String get notesDateButtonCreated => 'Date : création';

  @override
  String notesDateCreatedRange(Object range) {
    return 'Création : $range';
  }

  @override
  String get notesDateShowSection => 'Afficher';

  @override
  String get notesDateSortSection => 'Par date (plus récentes d\'abord)';

  @override
  String get linkedVersesTitle => 'Versets liés';

  @override
  String get showLessAction => 'Afficher moins';

  @override
  String showAllCountAction(int count) {
    return 'Tout afficher (+$count)';
  }

  @override
  String get readFrontMatterAction => 'Lire';

  @override
  String get boldWordsOfJesusTitle => 'Paroles de Jésus en gras';

  @override
  String get boldWordsOfJesusSubtitle => 'Affiche les paroles de Jésus en gras en plus du rouge. Désactivé par défaut, comme dans la plupart des Bibles à lettres rouges.';

  @override
  String get openSourceLicensesTitle => 'Licences open source';

  @override
  String get openSourceLicensesSubtitle => 'Bibliothèques et code utilisés par cette application';

  @override
  String get exportTranslationHelp => 'Exporte le fichier SQLite d\'une traduction enregistrée sur cet appareil. Téléchargez une traduction depuis Traductions pour l\'exporter.';

  @override
  String get noDownloadedTranslationsToExport => 'Aucune traduction téléchargée à exporter.';

  @override
  String get downloadNotificationChannelName => 'Téléchargements de la Bible';

  @override
  String get downloadNotificationChannelDescription => 'Progression des téléchargements de traductions de la Bible';

  @override
  String get downloadNotificationStarting => 'Démarrage…';

  @override
  String get downloadNotificationInstalling => 'Installation…';

  @override
  String downloadNotificationProgressTitle(Object name) {
    return 'Téléchargement de $name';
  }

  @override
  String downloadNotificationDoneTitle(Object name) {
    return '$name téléchargée';
  }

  @override
  String get downloadNotificationDoneBody => 'Prête à être lue hors ligne.';

  @override
  String get downloadNotificationFailedTitle => 'Échec du téléchargement';

  @override
  String downloadNotificationFailedBody(Object name) {
    return 'Impossible de télécharger $name.';
  }
}
