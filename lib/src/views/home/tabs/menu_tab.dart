import 'package:basic_bible/src/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class MenuTab extends ConsumerWidget {
  const MenuTab({super.key});

Future<void> _openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  if (kIsWeb) {
    // On web, open in a new browser tab/window
    try {
      await launchUrlString(url, webOnlyWindowName: '_blank');
    } catch (_) {
      // ignore or log
    }
    return;
  }

  // On mobile/desktop, ask the OS to open the link in the external browser/app
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      // fallback to platform default behavior if external application failed
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  } catch (_) {
    // ignore or log; you could show a snackbar if you pass BuildContext
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        // Profile header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "User Name", // TODO: Replace with actual user name from auth
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Notes
        ListTile(
          leading: const Icon(Icons.note),
          title: Text("Notes"),
          onTap: () => context.go('/coming-soon/notes'),
        ),

        // Prayer List
        ListTile(
          leading: const Icon(Icons.list_alt),
          title: Text("Prayer List"),
          onTap: () => context.go('/coming-soon/prayer'),
        ),

        // Verses of the Day
        ListTile(
          leading: const Icon(Icons.auto_stories),
          title: Text("Verses of the Day"),
          onTap: () => context.go('/coming-soon/verses'),
        ),

        const Divider(),
        
        // About
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(t.about),
          onTap: () => context.go('/coming-soon/about'),
        ),

        //Donate
        ListTile(
          leading: const Icon(Icons.help_outline),
           title: Text("Donate"),
          onTap: () => context.go('/coming-soon/donate'),
        ),
        // Help
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: Text("Help"),
          onTap: () => context.go('/coming-soon/help'),
        ),

        // GitHub Repo
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text("GitHub Repository"),
          onTap: () => _openLink("https://github.com/PopGTN/basic_bible"),
        ),

        const Divider(),
        // Language
        ListTile(
          leading: const Icon(Icons.language),
          title: Text("Language"),
          onTap: () => context.go('/coming-soon/language'),
        ),
        // Settings
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(t.settings),
          onTap: () => context.go('/home/settings'),
        ),

        const Divider(),

        // Logout
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: Text(
            t.logout,
            style: const TextStyle(color: Colors.redAccent),
          ),
          onTap: () {
            ref.read(authProvider.notifier).logout();
            // context.go('/login');
          },
        ),
      ],
    );
  }
}
