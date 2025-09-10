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
}
