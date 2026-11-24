import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens one of the public guides (bible-data/docs) in the browser.
Future<void> openHymnGuide(BuildContext context, String url) async {
  final opened = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.linkOpenFailed)),
    );
  }
}

/// A help button that opens [url].
class HymnGuideLink extends StatelessWidget {
  const HymnGuideLink({super.key, required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.help_outline),
    label: Text(label),
    onPressed: () => openHymnGuide(context, url),
  );
}
