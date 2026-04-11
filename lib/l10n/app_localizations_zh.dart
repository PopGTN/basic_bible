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
}
