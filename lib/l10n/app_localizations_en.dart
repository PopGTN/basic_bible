// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get bible => 'Bible';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get goToOther => 'Go to Other Page';

  @override
  String get aboutDescription =>
      'This Bible app is a free project by PopGTN. It is a practice project for learning Flutter & Dart. The app allows reading the Bible, taking notes, TTS support, and more. It is inspired by apps like YouVersion Bible but with extra features and improved UI.';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

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
  String get readerFootnotesTooltip => 'View footnotes and references';

  @override
  String get readerNotesTooltip => 'View personal notes';

  @override
  String get savedNoteLabel => 'Saved Note';

  @override
  String get savedNotesLabel => 'Saved Notes';

  @override
  String get openAction => 'Open';

  @override
  String get editAction => 'Edit';
}
