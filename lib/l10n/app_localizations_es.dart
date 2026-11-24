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
  String get aboutDescription =>
      'Esta aplicación de la Biblia es un proyecto gratuito de PopGTN. Es un proyecto de práctica para aprender Flutter y Dart. La aplicación permite leer la Biblia, tomar notas, soporte TTS y más. Está inspirada en aplicaciones como YouVersion Bible, pero con funciones adicionales y una interfaz mejorada.';

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
  String get menu => 'Menú';

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
  String get versionsTitle => 'Versiones';

  @override
  String get searchTranslationsTooltip => 'Buscar traducciones';

  @override
  String get importBibleFileAction => 'Importar archivo de la Biblia';

  @override
  String get clearTranslationCacheAction => 'Borrar caché de traducciones';

  @override
  String get clearTranslationCacheTitle => '¿Borrar caché de traducciones?';

  @override
  String get clearTranslationCacheDescription =>
      'Esto elimina del almacenamiento local de la app los archivos de traducciones descargadas, las copias de fuentes importadas y las entradas obsoletas del registro de traducciones. Las traducciones incluidas seguirán disponibles.';

  @override
  String get clearCacheAction => 'Borrar caché';

  @override
  String get clearedTranslationCacheMessage => 'Caché de traducciones borrada.';

  @override
  String couldNotClearTranslationCache(Object error) {
    return 'No se pudo borrar la caché de traducciones: $error';
  }

  @override
  String get translationsFileTypeLabel => 'Archivos de la Biblia';

  @override
  String unableToLoadTranslations(Object error) {
    return 'No se pudieron cargar las traducciones: $error';
  }

  @override
  String couldNotSwitchTranslation(Object error) {
    return 'No se pudo cambiar de traducción: $error';
  }

  @override
  String importedTranslationMessage(Object name) {
    return '$name importada.';
  }

  @override
  String importFailedMessage(Object error) {
    return 'La importación falló: $error';
  }

  @override
  String deleteTranslationTitle(Object name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteImportedTranslationDescription =>
      'Esto elimina la Biblia importada de la biblioteca y la caché de la app. El archivo original del disco no se eliminará.';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String deletedTranslationMessage(Object name) {
    return '$name eliminada.';
  }

  @override
  String couldNotDeleteTranslation(Object error) {
    return 'No se pudo eliminar la traducción: $error';
  }

  @override
  String removeDownloadedTranslationTitle(Object name) {
    return '¿Quitar la descarga de $name?';
  }

  @override
  String get removeDownloadedTranslationDescription =>
      'Esto elimina la Biblia descargada del almacenamiento local de la app. Seguirá en la biblioteca como opción descargable para que puedas volver a descargarla más tarde.';

  @override
  String get removeAction => 'Quitar';

  @override
  String removedLocalDownloadMessage(Object name) {
    return 'Se quitó la descarga local de $name.';
  }

  @override
  String couldNotRemoveDownload(Object error) {
    return 'No se pudo quitar la descarga: $error';
  }

  @override
  String get moreActionsTooltip => 'Más acciones';

  @override
  String get deleteImportAction => 'Eliminar importación';

  @override
  String get removeDownloadAction => 'Quitar descarga';

  @override
  String get availableOfflineTooltip => 'Disponible sin conexión';

  @override
  String get downloadTranslationTooltip => 'Descargar traducción';

  @override
  String get audioOptionsTooltip => 'Opciones de audio';

  @override
  String get bundledTranslationSource => 'Incluida';

  @override
  String get downloadedTranslationSource => 'Descargada';

  @override
  String get downloadableTranslationSource => 'Descargable';

  @override
  String get importedTranslationSource => 'Importada';

  @override
  String get importBibleTitle => 'Importar Biblia';

  @override
  String unableToPrepareImport(Object error) {
    return 'No se pudo preparar la importación: $error';
  }

  @override
  String get translationDetailsTitle => 'Detalles de la traducción';

  @override
  String get translationDetailsDescription =>
      'Define el nombre, la abreviatura, el código de idioma y la descripción antes de guardar la importación.';

  @override
  String get translationNameLabel => 'Nombre';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired =>
      'Introduce un nombre para la traducción.';

  @override
  String get translationAbbreviationLabel => 'Abreviatura';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp =>
      'Se usa igual que las abreviaturas incluidas, como KJV y ASV.';

  @override
  String get translationAbbreviationRequired => 'Introduce una abreviatura.';

  @override
  String get translationAbbreviationTaken => 'Esa abreviatura ya está en uso.';

  @override
  String get translationLanguageCodeLabel => 'Código de idioma';

  @override
  String get translationLanguageCodeHint => 'es';

  @override
  String get translationLanguageCodeHelp =>
      'Usa un código corto como en, es, fr o de.';

  @override
  String get translationLanguageCodeRequired =>
      'Introduce un código de idioma.';

  @override
  String get translationDescriptionLabel => 'Descripción';

  @override
  String get translationDescriptionHint =>
      'Importada de my_local_bible.xml o my_translation.sqlite';

  @override
  String get importingAction => 'Importando...';

  @override
  String get importTranslationAction => 'Importar traducción';

  @override
  String detectedFormatLabel(Object format) {
    return 'Formato detectado: $format';
  }

  @override
  String booksFoundLabel(int count) {
    return 'Libros encontrados: $count';
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
  String get readerFontRemoveDescription =>
      'El archivo de fuente importado se eliminará de este dispositivo.';

  @override
  String get readerFontSearchHint => 'Buscar fuentes instaladas';

  @override
  String get readerFontNoInstalled => 'No se encontraron fuentes instaladas.';

  @override
  String readerFontNoMatches(Object query) {
    return 'Ninguna fuente coincide con «$query».';
  }

  @override
  String get readerFontScanUnsupported =>
      'Las fuentes instaladas no se pueden listar en esta plataforma';

  @override
  String get readerFontScanUnsupportedHint =>
      'Importa un archivo de fuente en su lugar.';

  @override
  String readerFontImported(Object fontName) {
    return 'Se importó $fontName.';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return 'No se pudo cargar $fontName.';
  }

  @override
  String get readerFontUnsupportedType =>
      'Solo se pueden importar archivos de fuente .ttf y .otf.';

  @override
  String get readerFontNotAFont =>
      'Ese archivo no parece ser una fuente válida.';

  @override
  String get readerFontUnloadable => 'No se pudo cargar ese archivo de fuente.';

  @override
  String get readerFontImportFailed => 'No se pudo importar esa fuente.';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return 'No se pudo quitar $fontName.';
  }

  @override
  String get readerFontPreviewSample =>
      'En el principio creó Dios los cielos y la tierra.';

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

  @override
  String get translationAboutAction => 'Acerca de esta traducción';

  @override
  String get translationRightsLicenseLabel => 'Licencia';

  @override
  String get translationRightsNoticeLabel => 'Aviso de derechos de autor';

  @override
  String get translationRightsPermissionsLabel => 'Permisos';

  @override
  String get translationRightsPublicDomain => 'Dominio público';

  @override
  String get translationRightsViewLicense => 'Ver licencia';

  @override
  String get translationRightsSourceLabel => 'Fuente oficial';

  @override
  String get translationRightsNotesAction => 'Notas de licencia completas';

  @override
  String get translationRightsDownloadNotPermitted =>
      'El titular de los derechos no permite descargar esta traducción en la aplicación.';

  @override
  String get translationRightsUnknown =>
      'No hay información de derechos de autor ni de licencia para esta traducción.';

  @override
  String get translationRightsUnknownImported =>
      'Importaste esta traducción desde un archivo, por lo que la aplicación no tiene información de derechos de autor ni de licencia. Asegúrate de tener derecho a usarla.';

  @override
  String get searchBibleHint => 'Buscar en la Biblia';

  @override
  String get clearAction => 'Borrar';

  @override
  String get searchTypePrompt => 'Escribe una palabra o frase para buscar.';

  @override
  String searchFailed(Object error) {
    return 'La búsqueda falló: $error';
  }

  @override
  String get searchNoResults => 'No se encontraron versículos.';

  @override
  String searchResultsCapped(int limit) {
    return 'Se muestran los primeros $limit versículos. Añade palabras para acotar la búsqueda.';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos',
      one: '1 versículo',
    );
    return '$_temp0';
  }

  @override
  String get searchScopeAll => 'Toda la Biblia';

  @override
  String get searchScopeOldTestament => 'Antiguo Testamento';

  @override
  String get searchScopeNewTestament => 'Nuevo Testamento';

  @override
  String get searchScopeCurrentBook => 'Este libro';

  @override
  String get searchScopeCurrentChapter => 'Este capítulo';

  @override
  String get splitViewTooltip => 'Vista dividida';

  @override
  String get closeSplitViewTooltip => 'Cerrar vista dividida';

  @override
  String get paneTranslationTooltip => 'Traducción para este panel';

  @override
  String couldNotLoadTranslation(Object error) {
    return 'No se pudo cargar esta traducción: $error';
  }

  @override
  String get chapterNotFound => 'Capítulo no encontrado';

  @override
  String get noteDateFieldModified => 'Última modificación';

  @override
  String get noteDateFieldCreated => 'Creación';

  @override
  String get noteDateRangeAny => 'Cualquier fecha';

  @override
  String get noteDateRangeToday => 'Hoy';

  @override
  String get noteDateRangePastWeek => 'Última semana';

  @override
  String get noteDateRangePastMonth => 'Último mes';

  @override
  String get noteDateRangePastYear => 'Último año';

  @override
  String get noteTypeNote => 'Nota';

  @override
  String get noteTypeHighlightOnly => 'Solo resaltado';

  @override
  String get notesDateButton => 'Fecha';

  @override
  String get notesDateButtonCreated => 'Fecha: creación';

  @override
  String notesDateCreatedRange(Object range) {
    return 'Creación: $range';
  }

  @override
  String get notesDateShowSection => 'Mostrar';

  @override
  String get notesDateSortSection => 'Por fecha (más recientes primero)';

  @override
  String get linkedVersesTitle => 'Versículos vinculados';

  @override
  String get showLessAction => 'Mostrar menos';

  @override
  String showAllCountAction(int count) {
    return 'Mostrar todo (+$count)';
  }

  @override
  String get readFrontMatterAction => 'Leer';

  @override
  String get boldWordsOfJesusTitle => 'Palabras de Jesús en negrita';

  @override
  String get boldWordsOfJesusSubtitle =>
      'Muestra las palabras de Jesús en negrita además de en rojo. Desactivado por defecto, como en la mayoría de las Biblias con letra roja.';

  @override
  String get openSourceLicensesTitle => 'Licencias de código abierto';

  @override
  String get openSourceLicensesSubtitle =>
      'Bibliotecas y código que usa esta app';

  @override
  String get exportTranslationHelp =>
      'Exporta el archivo SQLite de una traducción guardada en este dispositivo. Descarga una traducción desde Traducciones para exportarla.';

  @override
  String get noDownloadedTranslationsToExport =>
      'No hay traducciones descargadas para exportar.';

  @override
  String get downloadNotificationChannelName => 'Descargas de la Biblia';

  @override
  String get downloadNotificationChannelDescription =>
      'Progreso de las descargas de traducciones de la Biblia';

  @override
  String get downloadNotificationStarting => 'Iniciando…';

  @override
  String get downloadNotificationInstalling => 'Instalando…';

  @override
  String downloadNotificationProgressTitle(Object name) {
    return 'Descargando $name';
  }

  @override
  String downloadNotificationDoneTitle(Object name) {
    return '$name descargada';
  }

  @override
  String get downloadNotificationDoneBody => 'Lista para leer sin conexión.';

  @override
  String get downloadNotificationFailedTitle => 'La descarga falló';

  @override
  String downloadNotificationFailedBody(Object name) {
    return 'No se pudo descargar $name.';
  }

  @override
  String get playAudioTooltip => 'Reproducir audio';

  @override
  String get splitFollowMainTitle =>
      'Abrir la vista dividida en el capítulo actual';

  @override
  String get splitFollowMainSubtitle =>
      'Cada vez que se abre la vista dividida, el segundo panel empieza en el capítulo del lector principal. Desactivado por defecto: el panel se queda donde lo dejaste hasta que se reinicie la app.';

  @override
  String get searchTooltip => 'Buscar';

  @override
  String get readerOptionsTooltip => 'Opciones de lectura';

  @override
  String get relatedContentAction => 'Contenido relacionado';

  @override
  String get fontsAndSettingsAction => 'Fuentes y ajustes';

  @override
  String get continuousScrollingTitle => 'Desplazamiento continuo';

  @override
  String get documentModeTitle => 'Modo documento';

  @override
  String get showNotesAcrossTranslationsTitle =>
      'Mostrar notas en otras traducciones';

  @override
  String get allSettingsAction => 'Todos los ajustes';

  @override
  String get retryAction => 'Reintentar';

  @override
  String get addNoteAction => 'Añadir nota';

  @override
  String get viewAction => 'Ver';

  @override
  String get crossReferencesTitle => 'Referencias cruzadas';

  @override
  String get noCrossReferences =>
      'No hay referencias cruzadas para este versículo.';

  @override
  String couldNotParseReference(Object label) {
    return 'No se pudo interpretar la referencia: $label';
  }

  @override
  String get currentTranslationLabel => 'Traducción actual';

  @override
  String get backToDetailsAction => 'Volver a los detalles';

  @override
  String get backToNoteAction => 'Volver a la nota';

  @override
  String readerErrorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String failedToLoadBible(Object error) {
    return 'No se pudo cargar la Biblia: $error';
  }

  @override
  String get shareTextCopied =>
      'Texto para compartir copiado. El uso compartido nativo puede añadirse más adelante sin cambiar tus notas.';

  @override
  String get highlightAction => 'Resaltar';

  @override
  String get noteAction => 'Nota';

  @override
  String get copyAction => 'Copiar';

  @override
  String get shareAction => 'Compartir';

  @override
  String get noteHighlightsEditedFromNote =>
      'Los resaltados de notas se editan desde la propia nota.';

  @override
  String get previewUnavailable =>
      'Vista previa no disponible para esta referencia.';

  @override
  String get openInBibleAction => 'Abrir en la Biblia';

  @override
  String get previousChapterTooltip => 'Capítulo anterior';

  @override
  String get nextChapterTooltip => 'Capítulo siguiente';

  @override
  String get sourceDetailsTitle => 'Detalles de la fuente';

  @override
  String get quoteSpeakerLabel => 'Hablante de la cita';

  @override
  String get lemmaLabel => 'Lema';

  @override
  String get morphologyLabel => 'Morfología';

  @override
  String get translationNotAvailable => 'Traducción no disponible.';

  @override
  String get currentTranslationNotAvailable =>
      'La traducción actual no está disponible.';

  @override
  String get saveNoteFailed =>
      'No se pudo guardar la nota. Inténtalo de nuevo.';

  @override
  String get saveAction => 'Guardar';

  @override
  String get noteFieldLabel => 'Nota';

  @override
  String get noteFieldHint => 'Escribe tu nota aquí.';

  @override
  String get primaryVerseTitle => 'Versículo principal';

  @override
  String get removeVerseTitle => '¿Quitar el versículo?';

  @override
  String get addVerseAction => 'Añadir versículo';

  @override
  String get connectedHighlightTitle => 'Resaltado vinculado';

  @override
  String get noneOption => 'Ninguno';

  @override
  String get connectedHighlightDescription =>
      'Esta nota mantendrá un resaltado vinculado en su versículo principal.';

  @override
  String get labelsFieldLabel => 'Etiquetas';

  @override
  String get labelsFieldHint => 'Etiquetas separadas por comas';

  @override
  String get onlyStandaloneHighlightsRemovable =>
      'Aquí solo se pueden quitar resaltados independientes. Edita una nota para cambiar su resaltado.';

  @override
  String noteVerseLimit(int count) {
    return 'Las notas pueden vincularse a un máximo de $count versículos a la vez. Selecciona un rango menor.';
  }

  @override
  String get deleteAnnotationTitle => '¿Eliminar?';

  @override
  String get deleteAnnotationDescription =>
      'Esta nota o resaltado se eliminará de forma permanente.';

  @override
  String get noReferenceHistory => 'Aún no hay historial de referencias.';

  @override
  String get recentReferencesTitle => 'Referencias recientes';

  @override
  String get referencesTitle => 'Referencias';

  @override
  String get historyTooltip => 'Historial';

  @override
  String get searchBooksHint => 'Buscar libros';

  @override
  String get chaptersLabel => 'Capítulos';

  @override
  String goToReference(Object reference) {
    return 'Ir a $reference';
  }

  @override
  String versesInChapter(Object chapter) {
    return 'Versículos en $chapter';
  }

  @override
  String get keepOneTranslationMessage =>
      'Debe quedar al menos una traducción en este dispositivo. Descarga o importa otra antes de quitar esta.';

  @override
  String get hymnsTab => 'Himnos';

  @override
  String get hymnSearchHint => 'Número, título, letra o autor';

  @override
  String get hymnSortTooltip => 'Ordenar';

  @override
  String get hymnSortNumber => 'Por número';

  @override
  String get hymnSortAlphabetical => 'Alfabético';

  @override
  String get hymnFavoritesOnly => 'Mostrar favoritos';

  @override
  String get hymnShowAll => 'Mostrar todos los himnos';

  @override
  String get hymnCountLabel => 'Himnos';

  @override
  String get hymnNoResults => 'Ningún himno coincide con tu búsqueda.';

  @override
  String get hymnNoFavorites =>
      'Aún no hay favoritos. Toca la estrella de un himno para añadirlo.';

  @override
  String get hymnPickHint => 'Elige un himno para leerlo aquí.';

  @override
  String get hymnalLoadError => 'No se pudo abrir este himnario.';

  @override
  String get hymnChorusLabel => 'Coro';

  @override
  String get hymnOptionalChorus => 'Coro opcional';

  @override
  String get hymnOptionalVerse => 'Estrofa opcional';

  @override
  String get hymnAddFavorite => 'Añadir a favoritos';

  @override
  String get hymnRemoveFavorite => 'Quitar de favoritos';

  @override
  String get hymnCopied => 'Himno copiado';

  @override
  String get hymnPrint => 'Imprimir';

  @override
  String get hymnPrevious => 'Himno anterior';

  @override
  String get hymnNext => 'Himno siguiente';

  @override
  String get hymnDisplaySettings => 'Pantalla';

  @override
  String get hymnTextSize => 'Tamaño del texto';

  @override
  String get hymnChorusEveryVerse => 'Mostrar el coro después de cada estrofa';

  @override
  String get hymnChorusEveryVerseSubtitle =>
      'Si está desactivado, el coro aparece una vez después de la estrofa 1, como en el libro impreso.';

  @override
  String get hymnShowDetails => 'Mostrar autor, métrica y melodía';

  @override
  String get hymnShowOptional => 'Mostrar estrofas y coros opcionales';

  @override
  String get hymnAboutBook => 'Acerca de este libro';

  @override
  String get hymnReportConcern =>
      'Informar de un problema de derechos de autor';

  @override
  String get hymnReportUnavailable =>
      'No se pudo abrir la página de informe. Inténtalo más tarde.';

  @override
  String get hymnalPublisher => 'Editorial';

  @override
  String get hymnalEdition => 'Edición';

  @override
  String get hymnalIsbn => 'ISBN';

  @override
  String get hymnalCopyright => 'Derechos de autor';

  @override
  String get hymnalPermission => 'Permiso';

  @override
  String get hymnalSource => 'Origen';

  @override
  String get hymnalSourceBundled => 'Incluido con la aplicación';

  @override
  String get hymnalSourceImported =>
      'Importado desde un archivo de este dispositivo';

  @override
  String hymnalSourceRepository(String source) {
    return 'Descargado de $source';
  }

  @override
  String get hymnalSourceBundledShort => 'Incluido';

  @override
  String get hymnalSourceImportedShort => 'Importado';

  @override
  String get hymnalSourceRepositoryShort => 'Descargado';

  @override
  String get hymnalThirdPartyNotice =>
      'Este libro no viene con la aplicación. Sus derechos son responsabilidad de quien lo proporcionó.';

  @override
  String get hymnalLibraryTitle => 'Himnarios';

  @override
  String get hymnalManageBooks => 'Administrar himnarios';

  @override
  String get hymnalInstalledSection => 'En este dispositivo';

  @override
  String get hymnalAvailableSection => 'Disponibles en repositorios';

  @override
  String get hymnalImportFile => 'Importar un archivo de himnario';

  @override
  String get hymnalImportSubtitle =>
      'Archivos JSON de himnario (.json o .json.gz)';

  @override
  String hymnalImported(String title) {
    return 'Se añadió «$title»';
  }

  @override
  String hymnalImportFailed(String error) {
    return 'No se pudo importar: $error';
  }

  @override
  String get hymnalOpenBook => 'Abrir';

  @override
  String hymnalDeleteTitle(String title) {
    return '¿Quitar «$title»?';
  }

  @override
  String get hymnalDeleteMessage =>
      'El libro se quita de este dispositivo. Tus favoritos se conservan por si lo vuelves a añadir.';

  @override
  String get hymnalNoRepoBooks => 'Tus repositorios aún no ofrecen himnarios.';

  @override
  String get hymnalDownload => 'Descargar';

  @override
  String get hymnalDownloaded => 'Instalado';

  @override
  String get hymnalNotDownloadable =>
      'Solo listado: no disponible para descargar';

  @override
  String hymnalDownloadFailed(String error) {
    return 'Error al descargar: $error';
  }

  @override
  String get manageRepositories => 'Administrar repositorios';

  @override
  String get manageRepositoriesSubtitle =>
      'De dónde se pueden descargar himnarios';

  @override
  String get repositoriesTitle => 'Repositorios';

  @override
  String get repositoriesIntro =>
      'Los repositorios listan himnarios que puedes descargar. El oficial lo gestionan los desarrolladores de esta aplicación; los demás, terceros.';

  @override
  String get repositoryOfficial => 'Oficial';

  @override
  String get repositoryAdd => 'Añadir repositorio';

  @override
  String get repositoryUrlLabel => 'Dirección del repositorio (https://…)';

  @override
  String get repositoryCheck => 'Comprobar';

  @override
  String repositoryAdded(String name) {
    return 'Se añadió «$name»';
  }

  @override
  String repositoryAddFailed(String error) {
    return 'No se pudo añadir el repositorio: $error';
  }

  @override
  String get repositoryRefresh => 'Actualizar';

  @override
  String get repositoryRemove => 'Quitar';

  @override
  String repositoryRemoveTitle(String name) {
    return '¿Quitar «$name»?';
  }

  @override
  String get repositoryRemoveMessage =>
      'Los himnarios descargados de este repositorio también se quitarán de este dispositivo.';

  @override
  String get repositoryLoadFailed =>
      'No se puede cargar este repositorio ahora.';

  @override
  String repositoryMaintainer(String name) {
    return 'Mantenido por $name';
  }

  @override
  String get repositoryOwnerNote => 'Del propietario del repositorio:';

  @override
  String get repositoryDisclaimerTitle => 'Repositorio de terceros';

  @override
  String get repositoryDisclaimerBody =>
      'Este repositorio lo gestiona un tercero, no los desarrolladores de esta aplicación. No alojamos, revisamos ni distribuimos su contenido, y no podemos confirmar que su propietario tenga permiso para compartirlo. Eres responsable de lo que descargas. Para informar de un problema de derechos de autor, usa «Informar de un problema de derechos de autor» en la página «Acerca de» del libro, que contacta con el propietario del repositorio.';

  @override
  String get repositoryDisclaimerAccept =>
      'Entiendo que este contenido no lo proporciona esta aplicación';

  @override
  String get legalTitle => 'Aviso legal y solicitudes de retirada';

  @override
  String get legalSubtitle =>
      'Derechos del contenido, fuentes de terceros y cómo solicitar la retirada';

  @override
  String get legalBundledHeading => 'Contenido incluido con la aplicación';

  @override
  String get legalBundledBody =>
      'Los himnarios incluidos con la aplicación se distribuyen con permiso de sus editoriales. Los avisos de derechos y permisos de cada libro aparecen en su página «Acerca de» y se añaden a cada himno que copies, compartas o imprimas.';

  @override
  String get legalThirdPartyHeading => 'Repositorios de terceros';

  @override
  String get legalThirdPartyBody =>
      'Los repositorios que añades tú mismo los gestionan otras personas. Los desarrolladores de esta aplicación no alojan, revisan ni distribuyen su contenido, y no garantizamos que sus propietarios tengan derecho a compartirlo. Las solicitudes sobre ese contenido deben dirigirse al propietario del repositorio, cuyo contacto aparece en la página «Acerca de» de cada libro.';

  @override
  String get legalImportedHeading => 'Archivos que importas';

  @override
  String get legalImportedBody =>
      'Los archivos importados se quedan en tu dispositivo y la aplicación nunca los comparte. Importa solo archivos que tengas derecho a usar.';

  @override
  String get legalTakedownHeading => 'Solicitudes de retirada';

  @override
  String get legalTakedownBody =>
      'Si tienes los derechos de contenido incluido en la aplicación o en el repositorio oficial y quieres que se retire, envía una solicitud de retirada. Indica el libro y los números de himno, la obra que te pertenece y cómo contactarte. Una vez confirmada, el contenido se retira del repositorio oficial y los libros retirados se eliminan de los dispositivos la próxima vez que la aplicación actualice sus repositorios.';

  @override
  String get legalReportButton => 'Enviar solicitud de retirada';

  @override
  String hymnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count himnos',
      one: '1 himno',
    );
    return '$_temp0';
  }

  @override
  String get repositoryGuide =>
      'Cómo funcionan los repositorios y cómo crear el tuyo';

  @override
  String get hymnalNameTitle => 'Nombra este himnario';

  @override
  String get hymnalNameLabel => 'Nombre';

  @override
  String get hymnalNameRequired => 'Escribe un nombre';

  @override
  String get hymnalShortNameLabel => 'Nombre corto (opcional)';

  @override
  String get hymnalShortNameHelper =>
      'Se muestra arriba en la pestaña Himnos, p. ej. BHB';

  @override
  String get hymnalImportAction => 'Importar';

  @override
  String hymnalImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se encontraron $count himnos.',
      one: 'Se encontró 1 himno.',
    );
    return '$_temp0';
  }

  @override
  String get hymnalImportReplaces =>
      'Este libro ya está en el dispositivo. Importarlo lo reemplaza; tus favoritos se conservan.';

  @override
  String get hymnalRename => 'Cambiar nombre';

  @override
  String get hymnalRenameAction => 'Guardar';

  @override
  String get hymnalImportGuide => 'Cómo importar';

  @override
  String get hymnalMakeGuide => 'Crea tu propio archivo de himnario';

  @override
  String get linkOpenFailed => 'No se pudo abrir el enlace.';
}
