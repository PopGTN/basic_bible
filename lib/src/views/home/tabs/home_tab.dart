import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:basic_bible/l10n/app_localizations.dart'; // <-- Added for translations

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // <-- Get translations

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/home/other');
            },
            child: Text(t.goToOther), // <-- translated
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.go('/home/settings'),
            icon: const Icon(Icons.settings),
            label: Text(t.settings), // <-- translated
            iconAlignment: IconAlignment.start,
          ),
        ],
      ),
    );
  }
}
