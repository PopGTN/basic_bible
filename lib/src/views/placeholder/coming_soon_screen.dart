import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  final String featureKey;

  const ComingSoonScreen({
    super.key,
    required this.featureKey,
  });

  static const Map<String, String> _featureTitles = {
    'notes': 'Notes',
    'prayer': 'Prayer List',
    'verses': 'Verses of the Day',
    'about': 'About',
    'donate': 'Donate',
    'help': 'Help',
    'language': 'Language',
  };

  @override
  Widget build(BuildContext context) {
    final title = _featureTitles[featureKey.toLowerCase()] ?? _humanize(featureKey);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                '$title is not built yet.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'This menu entry is now routed intentionally instead of pointing to a missing screen.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _humanize(String value) {
    if (value.isEmpty) return 'Feature';
    final normalized = value.replaceAll('-', ' ').replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}
