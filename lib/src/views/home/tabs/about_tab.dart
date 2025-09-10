import 'package:basic_bible/src/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:basic_bible/l10n/app_localizations.dart'; // <-- Added

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // <-- translations

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(t.aboutDescription), // <-- translated description
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            onPressed: () => context.go('/home/settings'),
            icon: const Icon(Icons.settings),
            label: Text(t.settings), // <-- translated
            iconAlignment: IconAlignment.start,
          ),
          const SizedBox(height: 20),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: Text(t.logout), // <-- translated
                iconAlignment: IconAlignment.start,
              );
            },
          ),
        ],
      ),
    );
  }
}
