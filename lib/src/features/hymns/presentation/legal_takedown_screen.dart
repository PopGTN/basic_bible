import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/content_reporting.dart';

/// Settings → Legal & takedown requests: what the app distributes, what it
/// doesn't (third-party repositories), and how rights holders get content
/// removed.
class LegalTakedownScreen extends StatelessWidget {
  const LegalTakedownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.legalTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          heading(t.legalBundledHeading),
          Text(t.legalBundledBody),
          heading(t.legalThirdPartyHeading),
          Text(t.legalThirdPartyBody),
          heading(t.legalImportedHeading),
          Text(t.legalImportedBody),
          heading(t.legalTakedownHeading),
          Text(t.legalTakedownBody),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.flag_outlined),
            label: Text(t.legalReportButton),
            onPressed: () async {
              final uri = buildContentReportUri(
                kAppTakedownContact,
                subject: 'Takedown request',
                body:
                    'Content (book title and hymn numbers, or repository '
                    'address):\n\nYour rights in the work:\n\nHow we can '
                    'contact you:\n',
              );
              final opened =
                  uri != null &&
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (!opened && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.hymnReportUnavailable)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
