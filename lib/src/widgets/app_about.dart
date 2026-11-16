import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

const String _appName = 'Basic Bible';
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
    applicationLegalese: AppLocalizations.of(context)!.aboutLegalese,
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
    applicationLegalese: AppLocalizations.of(context)!.aboutLegalese,
  );
}
