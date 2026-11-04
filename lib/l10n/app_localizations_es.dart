// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get home => 'Inicio';

  @override
  String get bible => 'Biblia';

  @override
  String get about => 'Acerca de';

  @override
  String get settings => 'Configuración';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get goToOther => 'Ir a otra página';

  @override
  String get aboutDescription => 'Esta aplicación de la Biblia es un proyecto gratuito de PopGTN. Es un proyecto de práctica para aprender Flutter y Dart. La aplicación permite leer la Biblia, tomar notas, soporte TTS y más. Está inspirada en aplicaciones como YouVersion Bible, pero con funciones adicionales y una interfaz mejorada.';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get french => 'Francés';

  @override
  String get german => 'Alemán';

  @override
  String get menu => 'Menu';

  @override
  String get readerFootnotesTooltip => 'Ver notas al pie y referencias';

  @override
  String get readerNotesTooltip => 'Ver notas personales';

  @override
  String get savedNoteLabel => 'Nota guardada';

  @override
  String get savedNotesLabel => 'Notas guardadas';

  @override
  String get openAction => 'Abrir';

  @override
  String get editAction => 'Editar';

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
  String get languageFilterLabel => 'Idioma';

  @override
  String get allLanguagesOption => 'Todos los idiomas';

  @override
  String get selectLanguageTitle => 'Seleccionar idioma';

  @override
  String get readerFontTitle => 'Fuente';

  @override
  String get readerFontSystemDefault => 'Predeterminada del sistema';

  @override
  String get readerFontSectionDefault => 'Predeterminada';

  @override
  String get readerFontSectionBundled => 'Incluidas en la app';

  @override
  String get readerFontSectionImported => 'Tus fuentes';

  @override
  String get readerFontSectionInstalled => 'Instaladas en este dispositivo';

  @override
  String get readerFontImportAction => 'Importar un archivo de fuente';

  @override
  String get readerFontImportHint => 'Elige un archivo .ttf u .otf';

  @override
  String get readerFontFileTypeLabel => 'Fuentes';

  @override
  String get readerFontRemoveTooltip => 'Quitar fuente';

  @override
  String readerFontRemoveTitle(Object fontName) {
    return '¿Quitar $fontName?';
  }

  @override
  String get readerFontRemoveDescription => 'El archivo de fuente importado se eliminará de este dispositivo.';

  @override
  String get readerFontSearchHint => 'Buscar fuentes instaladas';

  @override
  String get readerFontNoInstalled => 'No se encontraron fuentes instaladas.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Ninguna fuente coincide con «$query».';
  }

  @override
  String get readerFontScanUnsupported => 'Las fuentes instaladas no se pueden listar en esta plataforma';

  @override
  String get readerFontScanUnsupportedHint => 'Importa un archivo de fuente en su lugar.';

  @override
  String readerFontImported(Object fontName) {
    return 'Se importó $fontName.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return 'No se pudo cargar $fontName.';
  }

  @override
  String get readerFontUnsupportedType => 'Solo se pueden importar archivos de fuente .ttf y .otf.';

  @override
  String get readerFontNotAFont => 'Ese archivo no parece ser una fuente válida.';

  @override
  String get readerFontUnloadable => 'No se pudo cargar ese archivo de fuente.';

  @override
  String get readerFontImportFailed => 'No se pudo importar esa fuente.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return 'No se pudo quitar $fontName.';
  }

  @override
  String get readerFontPreviewSample => 'En el principio creó Dios los cielos y la tierra.';

  @override
  String readerTextSizeLabel(int size) {
    return 'Tamaño del texto $size';
  }

  @override
  String get readerDecreaseTextSize => 'Reducir texto';

  @override
  String get readerIncreaseTextSize => 'Aumentar texto';

  @override
  String get readerLineSpacingTitle => 'Interlineado';

  @override
  String get readerLineSpacingCompact => 'Compacto';

  @override
  String get readerLineSpacingNormal => 'Normal';

  @override
  String get readerLineSpacingRelaxed => 'Amplio';

  @override
  String get readerLineSpacingLoose => 'Extra';
}
