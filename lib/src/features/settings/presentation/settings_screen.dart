import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_preferences_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_preferences_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/advanced_preferences_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/app_launch_preferences_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/reader_display_preferences_view_models.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:basic_bible/src/widgets/theme_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/features/settings/application/view_models/language_view_model.dart';
import 'package:basic_bible/src/features/settings/application/view_models/theme_view_model.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final selectedLanguage = ref.watch(languageProvider);
    final showBookIntroductions = ref.watch(showBookIntroductionsProvider);
    final showVerseSelector = ref.watch(showVerseSelectorProvider);
    final confirmRemoveLinkedVerse = ref.watch(confirmRemoveLinkedVerseProvider);
    final showNotesAcrossTranslations = ref.watch(
      showNotesAcrossTranslationsProvider,
    );
    final advancedModeEnabled = ref.watch(advancedModeEnabledProvider);
    final partialHighlightsEnabled = ref.watch(
      partialHighlightsEnabledProvider,
    );
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
    final underlineWordMetadata = ref.watch(underlineWordMetadataProvider);
    final bracketTranslatorAdditions = ref.watch(
      bracketTranslatorAdditionsProvider,
    );
    final useSourceBoldStyling = ref.watch(useSourceBoldStylingProvider);
    final showSourceDetails = ref.watch(showSourceDetailsProvider);
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
            SizedBox(
              height: 146,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final themeMode in AppThemeMode.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ThemePreviewCard(
                        mode: themeMode,
                        selected: currentTheme == themeMode,
                        onTap: () {
                          ref.read(themeProvider.notifier).setTheme(themeMode);
                        },
                      ),
                    ),
                ],
              ),
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
                'Underline proper nouns when the source marks them.',
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
              title: const Text('Underline Word Tags'),
              subtitle: const Text(
                'Underline source-tagged word metadata such as Strong\'s-linked words. Off by default.',
              ),
              value: underlineWordMetadata,
              onChanged: (value) {
                ref
                    .read(underlineWordMetadataProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bracket Translator Additions'),
              subtitle: const Text(
                'Show translator-supplied words in [brackets]. Turn this off if you prefer italic-only rendering.',
              ),
              value: bracketTranslatorAdditions,
              onChanged: (value) {
                ref
                    .read(bracketTranslatorAdditionsProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use Source Bold Styling'),
              subtitle: const Text(
                'Respect bold-style emphasis from the source format for tags such as keywords and explicit bold spans.',
              ),
              value: useSourceBoldStyling,
              onChanged: (value) {
                ref
                    .read(useSourceBoldStylingProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Source Details'),
              subtitle: const Text(
                'Show study metadata such as Strong\'s numbers, lemmas, morphology, and quote speakers in the verse details sheet. Off by default.',
              ),
              value: showSourceDetails,
              onChanged: (value) {
                ref.read(showSourceDetailsProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Verse Selector'),
              subtitle: const Text(
                'Allow the reference picker to drill into verse selection instead of only picking chapters. Off by default.',
              ),
              value: showVerseSelector,
              onChanged: (value) {
                ref.read(showVerseSelectorProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 20),

            Text(
              'Notes',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Confirm Before Removing Linked Verses'),
              subtitle: const Text(
                'Show a confirmation dialog before unlinking a verse from a note.',
              ),
              value: confirmRemoveLinkedVerse,
              onChanged: (value) {
                ref
                    .read(confirmRemoveLinkedVerseProvider.notifier)
                    .setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Notes On Other Translations'),
              subtitle: const Text(
                'Show notes and highlights on a verse even if they were saved '
                'while reading a different translation. Off by default.',
              ),
              value: showNotesAcrossTranslations,
              onChanged: (value) {
                ref
                    .read(showNotesAcrossTranslationsProvider.notifier)
                    .setEnabled(value);
              },
            ),
            const SizedBox(height: 20),

            Text(
              'Advanced Mode',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Advanced Mode'),
              subtitle: const Text(
                'Turn on experimental, in-progress reader features below. Off by default.',
              ),
              value: advancedModeEnabled,
              onChanged: (value) {
                ref.read(advancedModeEnabledProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Partial Highlights'),
              subtitle: Text(
                advancedModeEnabled
                    ? 'Hold and drag across a verse to highlight only the words you drag over, instead of the whole verse.'
                    : 'Requires Advanced Mode to be turned on above.',
              ),
              value: advancedModeEnabled && partialHighlightsEnabled,
              onChanged: advancedModeEnabled
                  ? (value) {
                      ref
                          .read(partialHighlightsEnabledProvider.notifier)
                          .setEnabled(value);
                    }
                  : null,
            ),
            const SizedBox(height: 20),

            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.developer_mode_outlined),
              title: const Text('Advanced'),
              subtitle: const Text(
                'Developer tools — export translation databases',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/home/settings/advanced'),
            ),
          ],
        ),
      ),
    );
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
