import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/content_reporting.dart';

/// Sends a copyright concern or takedown request.
///
/// With [ownerContact] (a third-party repository's own contact) it goes
/// straight there: that content isn't ours to remove. Otherwise the user
/// chooses email (private) or a GitHub issue (public).
Future<void> sendContentReport(
  BuildContext context, {
  required String subject,
  required String body,
  String? ownerContact,
}) async {
  if (ownerContact != null) {
    await _open(
      context,
      buildContentReportUri(ownerContact, subject: subject, body: body),
    );
    return;
  }
  final choice = await showModalBottomSheet<_Route>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _RouteSheet(),
  );
  if (choice == null || !context.mounted) return;
  final contact = switch (choice) {
    _Route.email => 'mailto:$kAppTakedownEmail',
    _Route.github => kAppTakedownContact,
  };
  await _open(
    context,
    buildContentReportUri(contact, subject: subject, body: body),
    fallbackEmail: choice == _Route.email ? kAppTakedownEmail : null,
  );
}

enum _Route { email, github }

Future<void> _open(
  BuildContext context,
  Uri? uri, {
  String? fallbackEmail,
}) async {
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (opened || !context.mounted) return;
  final t = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  if (fallbackEmail == null) {
    messenger.showSnackBar(SnackBar(content: Text(t.hymnReportUnavailable)));
    return;
  }
  // No email app (common on desktop and web): show the address to copy.
  messenger.showSnackBar(
    SnackBar(
      content: Text(t.reportNoEmailApp(fallbackEmail)),
      duration: const Duration(seconds: 8),
      action: SnackBarAction(
        label: t.copyAction,
        onPressed: () => Clipboard.setData(ClipboardData(text: fallbackEmail)),
      ),
    ),
  );
}

class _RouteSheet extends StatelessWidget {
  const _RouteSheet();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              t.reportChooseRoute,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(t.reportByEmail(kAppTakedownEmail)),
            subtitle: Text(t.reportByEmailSubtitle),
            onTap: () => Navigator.pop(context, _Route.email),
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(t.reportByGitHub),
            subtitle: Text(t.reportByGitHubSubtitle),
            onTap: () => Navigator.pop(context, _Route.github),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
