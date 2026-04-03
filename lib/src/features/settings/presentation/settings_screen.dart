import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/settings/application/app_preferences_provider.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/providers/language_provider.dart';
import 'package:basic_bible/src/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final showBookIntroductions = ref.watch(showBookIntroductionsProvider);
    final showVerseSelector = ref.watch(showVerseSelectorProvider);
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
    final openBibleTabByDefault = ref.watch(openBibleTabByDefaultProvider);
    final requireDummyLogin = ref.watch(requireDummyLoginProvider);
    final colors = Theme.of(context).colorScheme;

    final languages = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
    };

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            Text(
              AppLocalizations.of(context)!.theme,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: AppThemeMode.values.map((themeMode) {
                final isSelected = currentTheme == themeMode;
                return _SettingsChoiceChip(
                  label: _themeModeToString(themeMode),
                  isSelected: isSelected,
                  colors: colors,
                  onSelected: () {
                    ref.read(themeProvider.notifier).setTheme(themeMode);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Language Section
            Text(
              AppLocalizations.of(context)!.language,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: languages.entries.map((entry) {
                final isSelected = selectedLanguage == entry.key;
                return _SettingsChoiceChip(
                  label: entry.value,
                  isSelected: isSelected,
                  colors: colors,
                  onSelected: () {
                    ref.read(languageProvider.notifier).setLanguage(entry.key);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            Text(
              'App Startup',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Open Bible Tab By Default'),
              subtitle: const Text(
                'Start on the Bible page instead of the Home tab when the app opens.',
              ),
              value: openBibleTabByDefault,
              onChanged: (value) {
                ref
                    .read(openBibleTabByDefaultProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Require Dummy Login'),
              subtitle: const Text(
                'Keep the sample login screen turned on before entering the app.',
              ),
              value: requireDummyLogin,
              onChanged: (value) {
                ref.read(requireDummyLoginProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 20),

            Text(
              'Bible Viewer',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Introductions'),
              subtitle: const Text(
                'Show book introductions and front-matter blocks when they exist.',
              ),
              value: showBookIntroductions,
              onChanged: (value) {
                ref
                    .read(showBookIntroductionsProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bold Divine Name (LORD)'),
              subtitle: const Text(
                'Display the divine name (LORD / Yahweh) in bold. Off by default — turn on if your translation marks it.',
              ),
              value: boldDivineName,
              onChanged: (value) {
                ref.read(boldDivineNameProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Underline Proper Names'),
              subtitle: const Text(
                'Underline proper nouns and Strong\'s-tagged words when the source marks them.',
              ),
              value: underlineProperNames,
              onChanged: (value) {
                ref
                    .read(underlineProperNamesProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Verse Selector'),
              subtitle: const Text(
                'Allow the reference picker to drill into verse selection instead of only picking chapters.',
              ),
              value: showVerseSelector,
              onChanged: (value) {
                ref.read(showVerseSelectorProvider.notifier).setEnabled(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return "System";
      case AppThemeMode.light:
        return "Light";
      case AppThemeMode.dark:
        return "Dark";
      case AppThemeMode.softDark:
        return "Soft Dark";
      case AppThemeMode.black:
        return "Pure Black";
      case AppThemeMode.white:
        return "Pure White";
      case AppThemeMode.blue:
        return "Blue Theme";
      case AppThemeMode.red:
        return "Red Theme";
    }
  }
}

class _SettingsChoiceChip extends StatelessWidget {
  const _SettingsChoiceChip({
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ColorScheme colors;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: colors.surfaceContainerHighest,
      backgroundColor: colors.surfaceContainerLow,
      side: BorderSide(
        color: isSelected ? colors.onSurface : colors.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
