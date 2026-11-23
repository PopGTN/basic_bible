import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const String _appName = 'Basic Bible';
const String _legalese =
    'Free and open source under the Apache License 2.0.\n'
    'Bible texts are public domain; see the notice at the end of each '
    'chapter.';

Widget _appIcon() => ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.asset('assets/icon/app_icon.png', width: 48, height: 48),
);

/// About dialog with Flutter's built-in "View licenses" button (#88).
void showAppAbout(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  showAboutDialog(
    context: context,
    applicationName: _appName,
    applicationIcon: _appIcon(),
    applicationLegalese: _legalese,
    children: [
      const SizedBox(height: 16),
      Text(t.aboutDescription),
    ],
  );
}

/// The open-source licenses page: every pub package and the Flutter engine
/// (collected by Flutter at build time) plus registerAdditionalLicenses().
void showAppLicenses(BuildContext context) {
  showLicensePage(
    context: context,
    applicationName: _appName,
    applicationIcon: Padding(
      padding: const EdgeInsets.all(8),
      child: _appIcon(),
    ),
    applicationLegalese: _legalese,
  );
}
