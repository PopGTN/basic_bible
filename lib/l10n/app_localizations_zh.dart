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
  String get aboutDescription =>
      '这个圣经应用是 PopGTN 的免费项目。它是学习 Flutter 和 Dart 的练习项目。该应用允许阅读圣经、做笔记、支持 TTS 等功能。它的灵感来自 YouVersion 圣经等应用，但具有额外功能和改进的界面。';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get login => '登录';

  @override
  String get english => '英语';

  @override
  String get spanish => '西班牙语';

  @override
  String get french => '法语';

  @override
  String get german => '德语';

  @override
  String get menu => '菜单';

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
  String get versionsTitle => '版本';

  @override
  String get searchTranslationsTooltip => '搜索译本';

  @override
  String get importBibleFileAction => '导入圣经文件';

  @override
  String get clearTranslationCacheAction => '清除译本缓存';

  @override
  String get clearTranslationCacheTitle => '清除译本缓存？';

  @override
  String get clearTranslationCacheDescription =>
      '这将从本地应用存储中删除已下载的译本文件、导入的源文件快照和过时的译本注册条目。内置译本仍可使用。';

  @override
  String get clearCacheAction => '清除缓存';

  @override
  String get clearedTranslationCacheMessage => '译本缓存已清除。';

  @override
  String couldNotClearTranslationCache(Object error) {
    return '无法清除译本缓存：$error';
  }

  @override
  String get translationsFileTypeLabel => '圣经文件';

  @override
  String unableToLoadTranslations(Object error) {
    return '无法加载译本：$error';
  }

  @override
  String couldNotSwitchTranslation(Object error) {
    return '无法切换译本：$error';
  }

  @override
  String importedTranslationMessage(Object name) {
    return '已导入 $name。';
  }

  @override
  String importFailedMessage(Object error) {
    return '导入失败：$error';
  }

  @override
  String deleteTranslationTitle(Object name) {
    return '删除 $name？';
  }

  @override
  String get deleteImportedTranslationDescription =>
      '这将从应用资料库和缓存中删除导入的圣经。磁盘上的原始文件不会被删除。';

  @override
  String get cancelAction => '取消';

  @override
  String get deleteAction => '删除';

  @override
  String deletedTranslationMessage(Object name) {
    return '已删除 $name。';
  }

  @override
  String couldNotDeleteTranslation(Object error) {
    return '无法删除译本：$error';
  }

  @override
  String removeDownloadedTranslationTitle(Object name) {
    return '移除 $name 的下载？';
  }

  @override
  String get removeDownloadedTranslationDescription =>
      '这将从本地应用存储中删除已下载的圣经。它仍会作为可下载项保留在资料库中，以便日后重新下载。';

  @override
  String get removeAction => '移除';

  @override
  String removedLocalDownloadMessage(Object name) {
    return '已移除 $name 的本地下载。';
  }

  @override
  String couldNotRemoveDownload(Object error) {
    return '无法移除下载：$error';
  }

  @override
  String get moreActionsTooltip => '更多操作';

  @override
  String get deleteImportAction => '删除导入';

  @override
  String get removeDownloadAction => '移除下载';

  @override
  String get availableOfflineTooltip => '可离线使用';

  @override
  String get downloadTranslationTooltip => '下载译本';

  @override
  String get audioOptionsTooltip => '音频选项';

  @override
  String get bundledTranslationSource => '内置';

  @override
  String get downloadedTranslationSource => '已下载';

  @override
  String get downloadableTranslationSource => '可下载';

  @override
  String get importedTranslationSource => '已导入';

  @override
  String get importBibleTitle => '导入圣经';

  @override
  String unableToPrepareImport(Object error) {
    return '无法准备导入：$error';
  }

  @override
  String get translationDetailsTitle => '译本详情';

  @override
  String get translationDetailsDescription => '保存导入前，请设置名称、缩写、语言代码和描述。';

  @override
  String get translationNameLabel => '名称';

  @override
  String get translationNameHint => 'World English Bible';

  @override
  String get translationNameRequired => '请输入译本名称。';

  @override
  String get translationAbbreviationLabel => '缩写';

  @override
  String get translationAbbreviationHint => 'WEB';

  @override
  String get translationAbbreviationHelp => '用法与内置缩写（如 KJV 和 ASV）相同。';

  @override
  String get translationAbbreviationRequired => '请输入缩写。';

  @override
  String get translationAbbreviationTaken => '该缩写已被使用。';

  @override
  String get translationLanguageCodeLabel => '语言代码';

  @override
  String get translationLanguageCodeHint => 'zh';

  @override
  String get translationLanguageCodeHelp => '请使用简短代码，如 en、es、fr 或 de。';

  @override
  String get translationLanguageCodeRequired => '请输入语言代码。';

  @override
  String get translationDescriptionLabel => '描述';

  @override
  String get translationDescriptionHint =>
      '从 my_local_bible.xml 或 my_translation.sqlite 导入';

  @override
  String get importingAction => '正在导入...';

  @override
  String get importTranslationAction => '导入译本';

  @override
  String detectedFormatLabel(Object format) {
    return '检测到的格式：$format';
  }

  @override
  String booksFoundLabel(int count) {
    return '找到的书卷：$count';
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

  @override
  String get translationAboutAction => '关于此译本';

  @override
  String get translationRightsLicenseLabel => '许可';

  @override
  String get translationRightsNoticeLabel => '版权声明';

  @override
  String get translationRightsPermissionsLabel => '权限';

  @override
  String get translationRightsPublicDomain => '公有领域';

  @override
  String get translationRightsViewLicense => '查看许可';

  @override
  String get translationRightsSourceLabel => '官方来源';

  @override
  String get translationRightsNotesAction => '完整许可说明';

  @override
  String get translationRightsDownloadNotPermitted => '版权方不允许在应用内下载此译本。';

  @override
  String get translationRightsUnknown => '此译本没有可用的版权或许可信息。';

  @override
  String get translationRightsUnknownImported =>
      '此译本是您从文件导入的，应用没有它的版权或许可信息。请确认您有权使用它。';

  @override
  String get searchBibleHint => '搜索圣经';

  @override
  String get clearAction => '清除';

  @override
  String get searchTypePrompt => '输入要搜索的字词或短语。';

  @override
  String searchFailed(Object error) {
    return '搜索失败：$error';
  }

  @override
  String get searchNoResults => '未找到经文。';

  @override
  String searchResultsCapped(int limit) {
    return '仅显示前 $limit 节经文。添加更多字词以缩小范围。';
  }

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 节经文',
    );
    return '$_temp0';
  }

  @override
  String get searchScopeAll => '整本圣经';

  @override
  String get searchScopeOldTestament => '旧约';

  @override
  String get searchScopeNewTestament => '新约';

  @override
  String get searchScopeCurrentBook => '本卷书';

  @override
  String get searchScopeCurrentChapter => '本章';

  @override
  String get splitViewTooltip => '分屏视图';

  @override
  String get closeSplitViewTooltip => '关闭分屏视图';

  @override
  String get paneTranslationTooltip => '此窗格的译本';

  @override
  String couldNotLoadTranslation(Object error) {
    return '无法加载此译本：$error';
  }

  @override
  String get chapterNotFound => '未找到该章';

  @override
  String get noteDateFieldModified => '最后修改';

  @override
  String get noteDateFieldCreated => '创建时间';

  @override
  String get noteDateRangeAny => '任何时间';

  @override
  String get noteDateRangeToday => '今天';

  @override
  String get noteDateRangePastWeek => '过去一周';

  @override
  String get noteDateRangePastMonth => '过去一个月';

  @override
  String get noteDateRangePastYear => '过去一年';

  @override
  String get noteTypeNote => '笔记';

  @override
  String get noteTypeHighlightOnly => '仅高亮';

  @override
  String get notesDateButton => '日期';

  @override
  String get notesDateButtonCreated => '日期：创建时间';

  @override
  String notesDateCreatedRange(Object range) {
    return '创建时间：$range';
  }

  @override
  String get notesDateShowSection => '显示';

  @override
  String get notesDateSortSection => '按日期（最新优先）';

  @override
  String get linkedVersesTitle => '关联经文';

  @override
  String get showLessAction => '收起';

  @override
  String showAllCountAction(int count) {
    return '显示全部（+$count）';
  }

  @override
  String get readFrontMatterAction => '阅读';

  @override
  String get boldWordsOfJesusTitle => '耶稣的话加粗';

  @override
  String get boldWordsOfJesusSubtitle => '除红色外，还以粗体显示耶稣的话。默认关闭，与大多数红字版圣经一致。';

  @override
  String get openSourceLicensesTitle => '开源许可';

  @override
  String get openSourceLicensesSubtitle => '本应用使用的库和代码';

  @override
  String get exportTranslationHelp =>
      '导出存储在此设备上的译本的 SQLite 文件。请先在“译本”中下载译本再导出。';

  @override
  String get noDownloadedTranslationsToExport => '没有可导出的已下载译本。';

  @override
  String get downloadNotificationChannelName => '圣经下载';

  @override
  String get downloadNotificationChannelDescription => '圣经译本下载进度';

  @override
  String get downloadNotificationStarting => '正在开始…';

  @override
  String get downloadNotificationInstalling => '正在安装…';

  @override
  String downloadNotificationProgressTitle(Object name) {
    return '正在下载 $name';
  }

  @override
  String downloadNotificationDoneTitle(Object name) {
    return '$name 已下载';
  }

  @override
  String get downloadNotificationDoneBody => '可离线阅读。';

  @override
  String get downloadNotificationFailedTitle => '下载失败';

  @override
  String downloadNotificationFailedBody(Object name) {
    return '无法下载 $name。';
  }

  @override
  String get playAudioTooltip => '播放音频';

  @override
  String get splitFollowMainTitle => '分屏打开时跳到当前章节';

  @override
  String get splitFollowMainSubtitle =>
      '每次打开分屏时，第二个窗格从主阅读器所在的章节开始。默认关闭：窗格会停留在你离开的位置，直到重新启动应用。';

  @override
  String get searchTooltip => '搜索';

  @override
  String get readerOptionsTooltip => '阅读选项';

  @override
  String get relatedContentAction => '相关内容';

  @override
  String get fontsAndSettingsAction => '字体与设置';

  @override
  String get continuousScrollingTitle => '连续滚动';

  @override
  String get documentModeTitle => '文档模式';

  @override
  String get showNotesAcrossTranslationsTitle => '在其他译本中显示笔记';

  @override
  String get allSettingsAction => '所有设置';

  @override
  String get retryAction => '重试';

  @override
  String get addNoteAction => '添加笔记';

  @override
  String get viewAction => '查看';

  @override
  String get crossReferencesTitle => '交叉引用';

  @override
  String get noCrossReferences => '此经文没有交叉引用。';

  @override
  String couldNotParseReference(Object label) {
    return '无法解析引用：$label';
  }

  @override
  String get currentTranslationLabel => '当前译本';

  @override
  String get backToDetailsAction => '返回详情';

  @override
  String get backToNoteAction => '返回笔记';

  @override
  String readerErrorMessage(Object error) {
    return '错误：$error';
  }

  @override
  String failedToLoadBible(Object error) {
    return '无法加载圣经：$error';
  }

  @override
  String get shareTextCopied => '已复制分享文本。以后可添加系统分享功能，不会更改你的笔记数据。';

  @override
  String get highlightAction => '高亮';

  @override
  String get noteAction => '笔记';

  @override
  String get copyAction => '复制';

  @override
  String get shareAction => '分享';

  @override
  String get noteHighlightsEditedFromNote => '笔记的高亮需在笔记中编辑。';

  @override
  String get previewUnavailable => '此引用无法预览。';

  @override
  String get openInBibleAction => '在圣经中打开';

  @override
  String get previousChapterTooltip => '上一章';

  @override
  String get nextChapterTooltip => '下一章';

  @override
  String get sourceDetailsTitle => '来源详情';

  @override
  String get quoteSpeakerLabel => '说话者';

  @override
  String get lemmaLabel => '词元';

  @override
  String get morphologyLabel => '词法';

  @override
  String get translationNotAvailable => '译本不可用。';

  @override
  String get currentTranslationNotAvailable => '当前译本不可用。';

  @override
  String get saveNoteFailed => '笔记保存失败，请重试。';

  @override
  String get saveAction => '保存';

  @override
  String get noteFieldLabel => '笔记';

  @override
  String get noteFieldHint => '在此写下你的笔记。';

  @override
  String get primaryVerseTitle => '主经文';

  @override
  String get removeVerseTitle => '移除经文？';

  @override
  String get addVerseAction => '添加经文';

  @override
  String get connectedHighlightTitle => '关联高亮';

  @override
  String get noneOption => '无';

  @override
  String get connectedHighlightDescription => '此笔记会在其主经文上保留关联高亮。';

  @override
  String get labelsFieldLabel => '标签';

  @override
  String get labelsFieldHint => '用逗号分隔标签';

  @override
  String get onlyStandaloneHighlightsRemovable =>
      '此处只能移除独立高亮。如需更改笔记的高亮，请编辑该笔记。';

  @override
  String noteVerseLimit(int count) {
    return '笔记一次最多可关联 $count 节经文。请选择更小的范围。';
  }

  @override
  String get deleteAnnotationTitle => '删除？';

  @override
  String get deleteAnnotationDescription => '此笔记或高亮将被永久删除。';

  @override
  String get noReferenceHistory => '暂无引用历史。';

  @override
  String get recentReferencesTitle => '最近的引用';

  @override
  String get referencesTitle => '经文位置';

  @override
  String get historyTooltip => '历史';

  @override
  String get searchBooksHint => '搜索书卷';

  @override
  String get chaptersLabel => '章';

  @override
  String goToReference(Object reference) {
    return '前往 $reference';
  }

  @override
  String versesInChapter(Object chapter) {
    return '第 $chapter 章的经文';
  }

  @override
  String get keepOneTranslationMessage => '此设备上必须至少保留一个译本。请先下载或导入其他译本，再移除此译本。';

  @override
  String get hymnsTab => '诗歌';

  @override
  String get hymnSearchHint => '编号、标题、歌词或作者';

  @override
  String get hymnSortTooltip => '排序';

  @override
  String get hymnSortNumber => '按编号';

  @override
  String get hymnSortAlphabetical => '按字母';

  @override
  String get hymnFavoritesOnly => '显示收藏';

  @override
  String get hymnShowAll => '显示全部诗歌';

  @override
  String get hymnCountLabel => '诗歌数';

  @override
  String get hymnNoResults => '没有符合搜索的诗歌。';

  @override
  String get hymnNoFavorites => '还没有收藏。点击诗歌旁的星标即可收藏。';

  @override
  String get hymnPickHint => '选择一首诗歌在此阅读。';

  @override
  String get hymnalLoadError => '无法打开这本诗歌本。';

  @override
  String get hymnChorusLabel => '副歌';

  @override
  String get hymnOptionalChorus => '可选副歌';

  @override
  String get hymnOptionalVerse => '可选段落';

  @override
  String get hymnAddFavorite => '加入收藏';

  @override
  String get hymnRemoveFavorite => '取消收藏';

  @override
  String get hymnCopied => '已复制诗歌';

  @override
  String get hymnPrint => '打印';

  @override
  String get hymnPrevious => '上一首';

  @override
  String get hymnNext => '下一首';

  @override
  String get hymnDisplaySettings => '显示设置';

  @override
  String get hymnTextSize => '文字大小';

  @override
  String get hymnChorusEveryVerse => '每段后显示副歌';

  @override
  String get hymnChorusEveryVerseSubtitle => '关闭时，副歌只在第 1 段后出现一次，与印刷版相同。';

  @override
  String get hymnShowDetails => '显示作者、格律和曲调';

  @override
  String get hymnShowOptional => '显示可选段落和副歌';

  @override
  String get hymnAboutBook => '关于本书';

  @override
  String get hymnReportConcern => '报告版权问题';

  @override
  String get hymnReportUnavailable => '无法打开报告页面，请稍后再试。';

  @override
  String get hymnalPublisher => '出版社';

  @override
  String get hymnalEdition => '版本';

  @override
  String get hymnalIsbn => 'ISBN';

  @override
  String get hymnalCopyright => '版权';

  @override
  String get hymnalPermission => '授权';

  @override
  String get hymnalSource => '来源';

  @override
  String get hymnalSourceBundled => '随应用提供';

  @override
  String get hymnalSourceImported => '从本设备上的文件导入';

  @override
  String hymnalSourceRepository(String source) {
    return '下载自 $source';
  }

  @override
  String get hymnalSourceBundledShort => '内置';

  @override
  String get hymnalSourceImportedShort => '已导入';

  @override
  String get hymnalSourceRepositoryShort => '已下载';

  @override
  String get hymnalThirdPartyNotice => '本书并非随应用提供，其版权由提供者负责。';

  @override
  String get hymnalLibraryTitle => '诗歌本';

  @override
  String get hymnalManageBooks => '管理诗歌本';

  @override
  String get hymnalInstalledSection => '本设备上';

  @override
  String get hymnalAvailableSection => '可从资源库获取';

  @override
  String get hymnalImportFile => '导入诗歌本文件';

  @override
  String get hymnalImportSubtitle => '诗歌本 JSON 文件（.json 或 .json.gz）';

  @override
  String hymnalImported(String title) {
    return '已添加“$title”';
  }

  @override
  String hymnalImportFailed(String error) {
    return '无法导入：$error';
  }

  @override
  String get hymnalOpenBook => '打开';

  @override
  String hymnalDeleteTitle(String title) {
    return '移除“$title”？';
  }

  @override
  String get hymnalDeleteMessage => '本书将从此设备移除。你的收藏会保留，以便再次添加时使用。';

  @override
  String get hymnalNoRepoBooks => '你的资源库暂时没有可用的诗歌本。';

  @override
  String get hymnalDownload => '下载';

  @override
  String get hymnalDownloaded => '已安装';

  @override
  String get hymnalNotDownloadable => '仅列出——不提供下载';

  @override
  String hymnalDownloadFailed(String error) {
    return '下载失败：$error';
  }

  @override
  String get manageRepositories => '管理资源库';

  @override
  String get manageRepositoriesSubtitle => '诗歌本的下载来源';

  @override
  String get repositoriesTitle => '资源库';

  @override
  String get repositoriesIntro => '资源库列出可下载的诗歌本。官方资源库由本应用开发者维护，其他资源库由第三方维护。';

  @override
  String get repositoryOfficial => '官方';

  @override
  String get repositoryAdd => '添加资源库';

  @override
  String get repositoryUrlLabel => '资源库地址（https://…）';

  @override
  String get repositoryCheck => '检查';

  @override
  String repositoryAdded(String name) {
    return '已添加“$name”';
  }

  @override
  String repositoryAddFailed(String error) {
    return '无法添加资源库：$error';
  }

  @override
  String get repositoryRefresh => '刷新';

  @override
  String get repositoryRemove => '移除';

  @override
  String repositoryRemoveTitle(String name) {
    return '移除“$name”？';
  }

  @override
  String get repositoryRemoveMessage => '从该资源库下载的诗歌本也将从此设备移除。';

  @override
  String get repositoryLoadFailed => '暂时无法加载此资源库。';

  @override
  String repositoryMaintainer(String name) {
    return '维护者：$name';
  }

  @override
  String get repositoryOwnerNote => '资源库所有者说明：';

  @override
  String get repositoryDisclaimerTitle => '第三方资源库';

  @override
  String get repositoryDisclaimerBody =>
      '此资源库由第三方维护，而非本应用开发者。我们不托管、不审核也不分发其内容，也无法确认其所有者是否有权分享。你需要对自己下载的内容负责。如需报告某本书的版权问题，请在该书的“关于本书”页面使用“报告版权问题”，它会联系资源库所有者。';

  @override
  String get repositoryDisclaimerAccept => '我了解此内容并非由本应用提供';

  @override
  String get legalTitle => '法律声明与删除请求';

  @override
  String get legalSubtitle => '内容权利、第三方来源以及如何申请删除';

  @override
  String get legalBundledHeading => '随应用提供的内容';

  @override
  String get legalBundledBody =>
      '随应用提供的诗歌本已获得出版社授权分发。每本书的版权与授权声明显示在其“关于本书”页面，并会附在你复制、分享或打印的每首诗歌中。';

  @override
  String get legalThirdPartyHeading => '第三方资源库';

  @override
  String get legalThirdPartyBody =>
      '你自行添加的资源库由他人维护。本应用开发者不托管、不审核也不分发其内容，也不保证其所有者有权分享。有关这些内容的请求请联系资源库所有者，联系方式显示在每本书的“关于本书”页面。';

  @override
  String get legalImportedHeading => '你导入的文件';

  @override
  String get legalImportedBody => '导入的文件只保存在你的设备上，应用不会分享它们。请只导入你有权使用的文件。';

  @override
  String get legalTakedownHeading => '删除请求';

  @override
  String get legalTakedownBody =>
      '如果你拥有随应用提供或官方资源库中内容的权利并希望将其删除，请发送删除请求。请注明书名和诗歌编号、你拥有的作品以及联系方式。请求确认后，内容将从官方资源库撤下，被撤下的书会在应用下次刷新资源库时从设备中移除。';

  @override
  String get legalReportButton => '发送删除请求';

  @override
  String hymnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 首诗歌',
    );
    return '$_temp0';
  }

  @override
  String get repositoryGuide => '资源库如何运作，以及如何创建自己的资源库';

  @override
  String get hymnalNameTitle => '为这本诗歌本命名';

  @override
  String get hymnalNameLabel => '名称';

  @override
  String get hymnalNameRequired => '请输入名称';

  @override
  String get hymnalShortNameLabel => '简称（可选）';

  @override
  String get hymnalShortNameHelper => '显示在诗歌页顶部，例如 BHB';

  @override
  String get hymnalImportAction => '导入';

  @override
  String hymnalImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 首诗歌。',
    );
    return '$_temp0';
  }

  @override
  String get hymnalImportReplaces => '本设备上已有这本书。导入会替换它，你的收藏会保留。';

  @override
  String get hymnalRename => '重命名';

  @override
  String get hymnalRenameAction => '保存';

  @override
  String get hymnalImportGuide => '如何导入';

  @override
  String get hymnalMakeGuide => '制作自己的诗歌本文件';

  @override
  String get linkOpenFailed => '无法打开链接。';

  @override
  String get reportChooseRoute => '你想如何发送？';

  @override
  String reportByEmail(String email) {
    return '发送邮件至 $email';
  }

  @override
  String get reportByEmailSubtitle => '私密。会打开你的邮件应用。';

  @override
  String get reportByGitHub => '在 GitHub 上提交问题';

  @override
  String get reportByGitHubSubtitle => '公开：任何人都能看到。需要 GitHub 账号。';

  @override
  String reportNoEmailApp(String email) {
    return '没有打开邮件应用。请写信至 $email。';
  }

  @override
  String get hymnTextSmaller => '缩小文字';

  @override
  String get hymnTextLarger => '放大文字';

  @override
  String get hymnOpenOnNumber => '输入编号时直接打开诗歌';

  @override
  String get hymnOpenOnNumberSubtitle =>
      '在搜索框输入 122 会打开第 122 首。如果有更长的编号以相同数字开头（12 → 120–129），会在短暂停顿后打开。';
}
