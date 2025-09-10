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
}
