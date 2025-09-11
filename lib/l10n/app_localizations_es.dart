// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get bible => 'Bible';

  @override
  String get about => 'About';

  @override
  String get settings => 'Configuración';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get goToOther => 'Go to Other Page';

  @override
  String get aboutDescription => 'This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart. The app allows reading the Bible, taking notes, TTS support, and more. It is inspired by apps like YouVersion Bible but with extra features and improved UI.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';
}
