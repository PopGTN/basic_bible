import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureKey;

  const ComingSoonScreen({super.key, required this.featureKey});

  static String? _featureTitle(AppLocalizations t, String key) => switch (key) {
    'notes' => t.notesTitle,
    'prayer' => t.menuPrayerList,
    'verses' => t.menuVersesOfTheDay,
    'about' => t.about,
    'donate' => t.menuDonate,
    'help' => t.menuHelp,
    'language' => t.language,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final title =
        _featureTitle(AppLocalizations.of(context)!, featureKey.toLowerCase()) ??
        _humanize(context, featureKey);

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.comingSoonTitle(title),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.comingSoonBody,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanize(BuildContext context, String value) {
    if (value.isEmpty) return AppLocalizations.of(context)!.featureDefaultName;
    final normalized = value.replaceAll('-', ' ').replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}
