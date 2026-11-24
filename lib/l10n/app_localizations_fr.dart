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
  String get aboutDescription =>
      'Cette application Bible est un projet gratuit de PopGTN. C\'est un projet pratique pour apprendre Flutter et Dart. L\'application permet de lire la Bible, de prendre des notes, de bénéficier du support TTS, et plus encore. Elle est inspirée d\'applications comme YouVersion Bible mais avec des fonctionnalités supplémentaires et une interface améliorée.';

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
  String get readerFootnotesTooltip =>
      'Voir les notes de bas de page et les références';

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
  String get clearTranslationCacheDescription =>
      'Cela supprime du stockage local de l\'application les fichiers de traductions téléchargées, les copies de sources importées et les entrées obsolètes du registre des traductions. Les traductions intégrées resteront disponibles.';

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
  String get deleteImportedTranslationDescription =>
      'Cela supprime la Bible importée de la bibliothèque et du cache de l\'application. Le fichier d\'origine sur le disque ne sera pas supprimé.';

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
  String get removeDownloadedTranslationDescription =>
      'Cela supprime la Bible téléchargée du stockage local de l\'application. Elle restera dans la bibliothèque comme option téléchargeable afin que vous puissiez la retélécharger plus tard.';

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
  String get translationDetailsDescription =>
      'Définissez le nom, l\'abréviation, le code de langue et la description avant d\'enregistrer l\'importation.';

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
  String get translationAbbreviationHelp =>
      'Utilisée de la même façon que les abréviations intégrées comme KJV et ASV.';

  @override
  String get translationAbbreviationRequired => 'Saisissez une abréviation.';

  @override
  String get translationAbbreviationTaken =>
      'Cette abréviation est déjà utilisée.';

  @override
  String get translationLanguageCodeLabel => 'Code de langue';

  @override
  String get translationLanguageCodeHint => 'fr';

  @override
  String get translationLanguageCodeHelp =>
      'Utilisez un code court comme en, es, fr ou de.';

  @override
  String get translationLanguageCodeRequired => 'Saisissez un code de langue.';

  @override
  String get translationDescriptionLabel => 'Description';

  @override
  String get translationDescriptionHint =>
      'Importée depuis my_local_bible.xml ou my_translation.sqlite';

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
  String get importNotAvailableOnWeb =>
      'Importing local Bible files is not available in the browser yet.';

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
  String get readerFontRemoveDescription =>
      'Le fichier de police importé sera supprimé de cet appareil.';

  @override
  String get readerFontSearchHint => 'Rechercher parmi les polices installées';

  @override
  String get readerFontNoInstalled =>
      'Aucune police installée n’a été trouvée.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Aucune police ne correspond à « $query ».';
  }

  @override
  String get readerFontScanUnsupported =>
      'Les polices installées ne peuvent pas être listées sur cette plateforme';

  @override
  String get readerFontScanUnsupportedHint =>
      'Importez plutôt un fichier de police.';

  @override
  String readerFontImported(Object fontName) {
    return '$fontName importée.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return 'Impossible de charger $fontName.';
  }

  @override
  String get readerFontUnsupportedType =>
      'Seuls les fichiers de police .ttf et .otf peuvent être importés.';

  @override
  String get readerFontNotAFont =>
      'Ce fichier ne semble pas être une police valide.';

  @override
  String get readerFontUnloadable =>
      'Impossible de charger ce fichier de police.';

  @override
  String get readerFontImportFailed => 'Impossible d’importer cette police.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return 'Impossible de supprimer $fontName.';
  }

  @override
  String get readerFontPreviewSample =>
      'Au commencement, Dieu créa les cieux et la terre.';

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
  String get translationRightsDownloadNotPermitted =>
      'Le titulaire des droits n’autorise pas le téléchargement de cette traduction dans l’application.';

  @override
  String get translationRightsUnknown =>
      'Aucune information de droits d’auteur ni de licence n’est disponible pour cette traduction.';

  @override
  String get translationRightsUnknownImported =>
      'Vous avez importé cette traduction depuis un fichier ; l’application n’a donc aucune information de droits d’auteur ni de licence. Assurez-vous d’avoir le droit de l’utiliser.';

  @override
  String get searchBibleHint => 'Rechercher dans la Bible';

  @override
  String get clearAction => 'Effacer';

  @override
  String get searchTypePrompt =>
      'Saisissez un mot ou une expression à rechercher.';

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
  String get boldWordsOfJesusSubtitle =>
      'Affiche les paroles de Jésus en gras en plus du rouge. Désactivé par défaut, comme dans la plupart des Bibles à lettres rouges.';

  @override
  String get openSourceLicensesTitle => 'Licences open source';

  @override
  String get openSourceLicensesSubtitle =>
      'Bibliothèques et code utilisés par cette application';

  @override
  String get exportTranslationHelp =>
      'Exporte le fichier SQLite d\'une traduction enregistrée sur cet appareil. Téléchargez une traduction depuis Traductions pour l\'exporter.';

  @override
  String get noDownloadedTranslationsToExport =>
      'Aucune traduction téléchargée à exporter.';

  @override
  String get downloadNotificationChannelName => 'Téléchargements de la Bible';

  @override
  String get downloadNotificationChannelDescription =>
      'Progression des téléchargements de traductions de la Bible';

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

  @override
  String get playAudioTooltip => 'Lire l’audio';

  @override
  String get splitFollowMainTitle =>
      'Ouvrir la vue partagée au chapitre actuel';

  @override
  String get splitFollowMainSubtitle =>
      'À chaque ouverture de la vue partagée, le second panneau commence au chapitre du lecteur principal. Désactivé par défaut : le panneau reste où vous l’avez laissé jusqu’au redémarrage de l’app.';

  @override
  String get searchTooltip => 'Rechercher';

  @override
  String get readerOptionsTooltip => 'Options de lecture';

  @override
  String get relatedContentAction => 'Contenu associé';

  @override
  String get fontsAndSettingsAction => 'Polices et paramètres';

  @override
  String get continuousScrollingTitle => 'Défilement continu';

  @override
  String get documentModeTitle => 'Mode document';

  @override
  String get showNotesAcrossTranslationsTitle =>
      'Afficher les notes dans les autres traductions';

  @override
  String get allSettingsAction => 'Tous les paramètres';

  @override
  String get retryAction => 'Réessayer';

  @override
  String get addNoteAction => 'Ajouter une note';

  @override
  String get viewAction => 'Voir';

  @override
  String get crossReferencesTitle => 'Références croisées';

  @override
  String get noCrossReferences => 'Aucune référence croisée pour ce verset.';

  @override
  String couldNotParseReference(Object label) {
    return 'Impossible de lire la référence : $label';
  }

  @override
  String get currentTranslationLabel => 'Traduction actuelle';

  @override
  String get backToDetailsAction => 'Retour aux détails';

  @override
  String get backToNoteAction => 'Retour à la note';

  @override
  String readerErrorMessage(Object error) {
    return 'Erreur : $error';
  }

  @override
  String failedToLoadBible(Object error) {
    return 'Impossible de charger la Bible : $error';
  }

  @override
  String get shareTextCopied =>
      'Texte à partager copié. Le partage natif pourra être ajouté plus tard sans modifier vos notes.';

  @override
  String get highlightAction => 'Surligner';

  @override
  String get noteAction => 'Note';

  @override
  String get copyAction => 'Copier';

  @override
  String get shareAction => 'Partager';

  @override
  String get noteHighlightsEditedFromNote =>
      'Les surlignages de note se modifient depuis la note elle-même.';

  @override
  String get previewUnavailable => 'Aperçu indisponible pour cette référence.';

  @override
  String get openInBibleAction => 'Ouvrir dans la Bible';

  @override
  String get previousChapterTooltip => 'Chapitre précédent';

  @override
  String get nextChapterTooltip => 'Chapitre suivant';

  @override
  String get sourceDetailsTitle => 'Détails de la source';

  @override
  String get quoteSpeakerLabel => 'Locuteur de la citation';

  @override
  String get lemmaLabel => 'Lemme';

  @override
  String get morphologyLabel => 'Morphologie';

  @override
  String get translationNotAvailable => 'Traduction indisponible.';

  @override
  String get currentTranslationNotAvailable =>
      'La traduction actuelle est indisponible.';

  @override
  String get saveNoteFailed =>
      'Impossible d’enregistrer la note. Veuillez réessayer.';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get noteFieldLabel => 'Note';

  @override
  String get noteFieldHint => 'Écrivez votre note ici.';

  @override
  String get primaryVerseTitle => 'Verset principal';

  @override
  String get removeVerseTitle => 'Retirer le verset ?';

  @override
  String get addVerseAction => 'Ajouter un verset';

  @override
  String get connectedHighlightTitle => 'Surlignage associé';

  @override
  String get noneOption => 'Aucun';

  @override
  String get connectedHighlightDescription =>
      'Cette note conservera un surlignage associé sur son verset principal.';

  @override
  String get labelsFieldLabel => 'Étiquettes';

  @override
  String get labelsFieldHint => 'Étiquettes séparées par des virgules';

  @override
  String get onlyStandaloneHighlightsRemovable =>
      'Seuls les surlignages indépendants peuvent être retirés ici. Modifiez une note pour changer son surlignage.';

  @override
  String noteVerseLimit(int count) {
    return 'Une note peut être liée à $count versets au maximum. Veuillez sélectionner une plage plus petite.';
  }

  @override
  String get deleteAnnotationTitle => 'Supprimer ?';

  @override
  String get deleteAnnotationDescription =>
      'Cette note ou ce surlignage sera définitivement supprimé.';

  @override
  String get noReferenceHistory =>
      'Aucun historique de références pour l’instant.';

  @override
  String get recentReferencesTitle => 'Références récentes';

  @override
  String get referencesTitle => 'Références';

  @override
  String get historyTooltip => 'Historique';

  @override
  String get searchBooksHint => 'Rechercher des livres';

  @override
  String get chaptersLabel => 'Chapitres';

  @override
  String goToReference(Object reference) {
    return 'Aller à $reference';
  }

  @override
  String versesInChapter(Object chapter) {
    return 'Versets du chapitre $chapter';
  }

  @override
  String get keepOneTranslationMessage =>
      'Au moins une traduction doit rester sur cet appareil. Téléchargez ou importez-en une autre avant de retirer celle-ci.';

  @override
  String get hymnsTab => 'Cantiques';

  @override
  String get hymnSearchHint => 'Numéro, titre, paroles ou auteur';

  @override
  String get hymnSortTooltip => 'Trier';

  @override
  String get hymnSortNumber => 'Par numéro';

  @override
  String get hymnSortAlphabetical => 'Alphabétique';

  @override
  String get hymnFavoritesOnly => 'Afficher les favoris';

  @override
  String get hymnShowAll => 'Afficher tous les cantiques';

  @override
  String get hymnCountLabel => 'Cantiques';

  @override
  String get hymnNoResults => 'Aucun cantique ne correspond à votre recherche.';

  @override
  String get hymnNoFavorites =>
      'Aucun favori pour l\'instant. Touchez l\'étoile d\'un cantique pour l\'ajouter.';

  @override
  String get hymnPickHint => 'Choisissez un cantique pour le lire ici.';

  @override
  String get hymnalLoadError => 'Impossible d\'ouvrir ce recueil.';

  @override
  String get hymnChorusLabel => 'Refrain';

  @override
  String get hymnOptionalChorus => 'Refrain facultatif';

  @override
  String get hymnOptionalVerse => 'Strophe facultative';

  @override
  String get hymnAddFavorite => 'Ajouter aux favoris';

  @override
  String get hymnRemoveFavorite => 'Retirer des favoris';

  @override
  String get hymnCopied => 'Cantique copié';

  @override
  String get hymnPrint => 'Imprimer';

  @override
  String get hymnPrevious => 'Cantique précédent';

  @override
  String get hymnNext => 'Cantique suivant';

  @override
  String get hymnDisplaySettings => 'Affichage';

  @override
  String get hymnTextSize => 'Taille du texte';

  @override
  String get hymnChorusEveryVerse => 'Afficher le refrain après chaque strophe';

  @override
  String get hymnChorusEveryVerseSubtitle =>
      'Désactivé, le refrain apparaît une fois après la strophe 1, comme dans le livre imprimé.';

  @override
  String get hymnShowDetails => 'Afficher auteur, mètre et mélodie';

  @override
  String get hymnShowOptional =>
      'Afficher les strophes et refrains facultatifs';

  @override
  String get hymnAboutBook => 'À propos de ce recueil';

  @override
  String get hymnReportConcern => 'Signaler un problème de droits d\'auteur';

  @override
  String get hymnReportUnavailable =>
      'Impossible d\'ouvrir la page de signalement. Réessayez plus tard.';

  @override
  String get hymnalPublisher => 'Éditeur';

  @override
  String get hymnalEdition => 'Édition';

  @override
  String get hymnalIsbn => 'ISBN';

  @override
  String get hymnalCopyright => 'Droits d\'auteur';

  @override
  String get hymnalPermission => 'Autorisation';

  @override
  String get hymnalSource => 'Source';

  @override
  String get hymnalSourceBundled => 'Inclus dans l\'application';

  @override
  String get hymnalSourceImported =>
      'Importé depuis un fichier de cet appareil';

  @override
  String hymnalSourceRepository(String source) {
    return 'Téléchargé depuis $source';
  }

  @override
  String get hymnalSourceBundledShort => 'Inclus';

  @override
  String get hymnalSourceImportedShort => 'Importé';

  @override
  String get hymnalSourceRepositoryShort => 'Téléchargé';

  @override
  String get hymnalThirdPartyNotice =>
      'Ce recueil n\'est pas fourni avec l\'application. Ses droits relèvent de la personne qui l\'a fourni.';

  @override
  String get hymnalLibraryTitle => 'Recueils';

  @override
  String get hymnalManageBooks => 'Gérer les recueils';

  @override
  String get hymnalInstalledSection => 'Sur cet appareil';

  @override
  String get hymnalAvailableSection => 'Disponibles dans les dépôts';

  @override
  String get hymnalImportFile => 'Importer un fichier de recueil';

  @override
  String get hymnalImportSubtitle =>
      'Fichiers JSON de recueil (.json ou .json.gz)';

  @override
  String hymnalImported(String title) {
    return '« $title » ajouté';
  }

  @override
  String hymnalImportFailed(String error) {
    return 'Import impossible : $error';
  }

  @override
  String get hymnalOpenBook => 'Ouvrir';

  @override
  String hymnalDeleteTitle(String title) {
    return 'Retirer « $title » ?';
  }

  @override
  String get hymnalDeleteMessage =>
      'Le recueil est retiré de cet appareil. Vos favoris sont conservés si vous l\'ajoutez à nouveau.';

  @override
  String get hymnalNoRepoBooks =>
      'Vos dépôts ne proposent encore aucun recueil.';

  @override
  String get hymnalDownload => 'Télécharger';

  @override
  String get hymnalDownloaded => 'Installé';

  @override
  String get hymnalNotDownloadable =>
      'Listé seulement — non proposé au téléchargement';

  @override
  String hymnalDownloadFailed(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get manageRepositories => 'Gérer les dépôts';

  @override
  String get manageRepositoriesSubtitle =>
      'D\'où les recueils peuvent être téléchargés';

  @override
  String get repositoriesTitle => 'Dépôts';

  @override
  String get repositoriesIntro =>
      'Les dépôts listent les recueils téléchargeables. Le dépôt officiel est géré par les développeurs de l\'application ; les autres par des tiers.';

  @override
  String get repositoryOfficial => 'Officiel';

  @override
  String get repositoryAdd => 'Ajouter un dépôt';

  @override
  String get repositoryUrlLabel => 'Adresse du dépôt (https://…)';

  @override
  String get repositoryCheck => 'Vérifier';

  @override
  String repositoryAdded(String name) {
    return '« $name » ajouté';
  }

  @override
  String repositoryAddFailed(String error) {
    return 'Impossible d\'ajouter le dépôt : $error';
  }

  @override
  String get repositoryRefresh => 'Actualiser';

  @override
  String get repositoryRemove => 'Retirer';

  @override
  String repositoryRemoveTitle(String name) {
    return 'Retirer « $name » ?';
  }

  @override
  String get repositoryRemoveMessage =>
      'Les recueils téléchargés depuis ce dépôt seront aussi retirés de cet appareil.';

  @override
  String get repositoryLoadFailed =>
      'Impossible de charger ce dépôt pour le moment.';

  @override
  String repositoryMaintainer(String name) {
    return 'Géré par $name';
  }

  @override
  String get repositoryOwnerNote => 'Du propriétaire du dépôt :';

  @override
  String get repositoryDisclaimerTitle => 'Dépôt tiers';

  @override
  String get repositoryDisclaimerBody =>
      'Ce dépôt est géré par un tiers, et non par les développeurs de l\'application. Nous n\'hébergeons, ne vérifions ni ne distribuons son contenu, et ne pouvons pas confirmer que son propriétaire a le droit de le partager. Vous êtes responsable de vos téléchargements. Pour signaler un problème de droits d\'auteur, utilisez « Signaler un problème de droits d\'auteur » dans la page « À propos » du recueil, qui contacte le propriétaire du dépôt.';

  @override
  String get repositoryDisclaimerAccept =>
      'Je comprends que ce contenu n\'est pas fourni par l\'application';

  @override
  String get legalTitle => 'Mentions légales et demandes de retrait';

  @override
  String get legalSubtitle =>
      'Droits du contenu, sources tierces et demandes de retrait';

  @override
  String get legalBundledHeading => 'Contenu inclus dans l\'application';

  @override
  String get legalBundledBody =>
      'Les recueils inclus dans l\'application sont distribués avec l\'autorisation de leurs éditeurs. Les mentions de droits et d\'autorisation figurent dans la page « À propos » de chaque recueil et accompagnent chaque cantique copié, partagé ou imprimé.';

  @override
  String get legalThirdPartyHeading => 'Dépôts tiers';

  @override
  String get legalThirdPartyBody =>
      'Les dépôts que vous ajoutez vous-même sont gérés par d\'autres personnes. Leur contenu n\'est ni hébergé, ni vérifié, ni distribué par les développeurs de l\'application, et nous ne garantissons pas que leurs propriétaires aient le droit de le partager. Les demandes concernant ce contenu doivent être adressées au propriétaire du dépôt, dont le contact figure dans la page « À propos » de chaque recueil.';

  @override
  String get legalImportedHeading => 'Fichiers importés';

  @override
  String get legalImportedBody =>
      'Les fichiers importés restent sur votre appareil et ne sont jamais partagés par l\'application. N\'importez que des fichiers que vous avez le droit d\'utiliser.';

  @override
  String get legalTakedownHeading => 'Demandes de retrait';

  @override
  String get legalTakedownBody =>
      'Si vous détenez les droits d\'un contenu inclus dans l\'application ou listé dans le dépôt officiel et souhaitez son retrait, envoyez une demande de retrait. Indiquez le recueil et les numéros de cantiques, l\'œuvre concernée et comment vous joindre. Une fois la demande confirmée, le contenu est retiré du dépôt officiel et les recueils retirés sont supprimés des appareils lors de la prochaine actualisation des dépôts.';

  @override
  String get legalReportButton => 'Envoyer une demande de retrait';

  @override
  String hymnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cantiques',
      one: '1 cantique',
    );
    return '$_temp0';
  }

  @override
  String get repositoryGuide =>
      'Fonctionnement des dépôts et comment créer le vôtre';

  @override
  String get hymnalNameTitle => 'Nommer ce recueil';

  @override
  String get hymnalNameLabel => 'Nom';

  @override
  String get hymnalNameRequired => 'Saisissez un nom';

  @override
  String get hymnalShortNameLabel => 'Nom court (facultatif)';

  @override
  String get hymnalShortNameHelper =>
      'Affiché en haut de l\'onglet Cantiques, par ex. BHB';

  @override
  String get hymnalImportAction => 'Importer';

  @override
  String hymnalImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cantiques trouvés.',
      one: '1 cantique trouvé.',
    );
    return '$_temp0';
  }

  @override
  String get hymnalImportReplaces =>
      'Ce recueil est déjà sur l\'appareil. L\'importer le remplace ; vos favoris sont conservés.';

  @override
  String get hymnalRename => 'Renommer';

  @override
  String get hymnalRenameAction => 'Enregistrer';

  @override
  String get hymnalImportGuide => 'Comment importer';

  @override
  String get hymnalMakeGuide => 'Créer votre propre fichier de recueil';

  @override
  String get linkOpenFailed => 'Impossible d\'ouvrir le lien.';

  @override
  String get reportChooseRoute => 'Comment souhaitez-vous l\'envoyer ?';

  @override
  String reportByEmail(String email) {
    return 'E-mail à $email';
  }

  @override
  String get reportByEmailSubtitle =>
      'Privé. Ouvre votre application de messagerie.';

  @override
  String get reportByGitHub => 'Ouvrir un ticket GitHub';

  @override
  String get reportByGitHubSubtitle =>
      'Public : tout le monde peut le lire. Nécessite un compte GitHub.';

  @override
  String reportNoEmailApp(String email) {
    return 'Aucune application de messagerie ne s\'est ouverte. Écrivez à $email.';
  }

  @override
  String get hymnTextSmaller => 'Texte plus petit';

  @override
  String get hymnTextLarger => 'Texte plus grand';
}
