// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get home => '主页';

  @override
  String get bible => '圣经';

  @override
  String get about => '关于';

  @override
  String get settings => '设置';

  @override
  String get logout => '登出';

  @override
  String get goToOther => '前往其他页面';

  @override
  String get aboutDescription => '这个圣经应用是 PopGTN 的免费项目。它是学习 Flutter 和 Dart 的练习项目。该应用允许阅读圣经、做笔记、支持 TTS 等功能。它的灵感来自 YouVersion 圣经等应用，但具有额外功能和改进的界面。';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

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
  String get readerFootnotesTooltip => '查看脚注和参考资料';

  @override
  String get readerNotesTooltip => '查看个人笔记';

  @override
  String get savedNoteLabel => '已保存笔记';

  @override
  String get savedNotesLabel => '已保存笔记';

  @override
  String get openAction => '打开';

  @override
  String get editAction => '编辑';

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
  String get languageFilterLabel => '语言';

  @override
  String get allLanguagesOption => '所有语言';

  @override
  String get selectLanguageTitle => '选择语言';

  @override
  String get readerFontTitle => '字体';

  @override
  String get readerFontSystemDefault => '系统默认';

  @override
  String get readerFontSectionDefault => '默认';

  @override
  String get readerFontSectionBundled => '应用自带';

  @override
  String get readerFontSectionImported => '你的字体';

  @override
  String get readerFontSectionInstalled => '本设备已安装';

  @override
  String get readerFontImportAction => '导入字体文件';

  @override
  String get readerFontImportHint => '选择 .ttf 或 .otf 文件';

  @override
  String get readerFontFileTypeLabel => '字体';

  @override
  String get readerFontRemoveTooltip => '移除字体';

  @override
  String readerFontRemoveTitle(Object fontName) {
    return '移除 $fontName？';
  }

  @override
  String get readerFontRemoveDescription => '导入的字体文件将从本设备中删除。';

  @override
  String get readerFontSearchHint => '搜索已安装的字体';

  @override
  String get readerFontNoInstalled => '未找到已安装的字体。';

  @override
  String readerFontNoMatches(Object query) {
    return '没有与“$query”匹配的字体。';
  }

  @override
  String get readerFontScanUnsupported => '此平台无法列出已安装的字体';

  @override
  String get readerFontScanUnsupportedHint => '请改为导入字体文件。';

  @override
  String readerFontImported(Object fontName) {
    return '已导入 $fontName。';
  }

  @override
  String readerFontLoadFailed(Object fontName) {
    return '无法加载 $fontName。';
  }

  @override
  String get readerFontUnsupportedType => '只能导入 .ttf 和 .otf 字体文件。';

  @override
  String get readerFontNotAFont => '该文件似乎不是有效的字体。';

  @override
  String get readerFontUnloadable => '无法加载该字体文件。';

  @override
  String get readerFontImportFailed => '无法导入该字体。';

  @override
  String readerFontDeleteFailed(Object fontName) {
    return '无法移除 $fontName。';
  }

  @override
  String get readerFontPreviewSample => '起初，神创造天地。';

  @override
  String readerTextSizeLabel(int size) {
    return '文字大小 $size';
  }

  @override
  String get readerDecreaseTextSize => '减小文字';

  @override
  String get readerIncreaseTextSize => '增大文字';

  @override
  String get readerLineSpacingTitle => '行距';

  @override
  String get readerLineSpacingCompact => '紧凑';

  @override
  String get readerLineSpacingNormal => '标准';

  @override
  String get readerLineSpacingRelaxed => '宽松';

  @override
  String get readerLineSpacingLoose => '很宽';
}
