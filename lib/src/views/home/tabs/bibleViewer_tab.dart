import 'package:flutter/material.dart';
import 'package:basic_bible/l10n/app_localizations.dart'; // <-- Added

class BibleViewerTab extends StatelessWidget {
  const BibleViewerTab({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        t.bible, // <-- translated
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
