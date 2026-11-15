import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_preferences_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_preferences_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/app_launch_preferences_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/reader_display_preferences_view_models.dart';
import 'package:basic_bible/src/features/sync/presentation/notes_backup_tiles.dart';
import 'package:basic_bible/src/features/sync/presentation/sync_settings_section.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:basic_bible/src/widgets/horizontal_mouse_scroll_list.dart';
import 'package:basic_bible/src/widgets/theme_preview_card.dart';
import 'package:basic_bible/src/widgets/app_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:basic_bible/src/features/localization/language_pack_providers.dart';
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
    final boldDivineName = ref.watch(boldDivineNameProvider);
    final boldWordsOfJesus = ref.watch(boldWordsOfJesusProvider);
    final underlineProperNames = ref.watch(underlineProperNamesProvider);
    final underlineWordMetadata = ref.watch(underlineWordMetadataProvider);
    final bracketTranslatorAdditions = ref.watch(
      bracketTranslatorAdditionsProvider,
    );
    final useSourceBoldStyling = ref.watch(useSourceBoldStylingProvider);
    final showSourceDetails = ref.watch(showSourceDetailsProvider);
    final openBibleTabByDefault = ref.watch(openBibleTabByDefaultProvider);
    final requireDummyLogin = ref.watch(requireDummyLoginProvider);
    final t = AppLocalizations.of(context)!;
    final languageName = ref
            .watch(availableLanguagesProvider)
            .maybeWhen(
              data: (list) => list
                  .where((l) => l.code == selectedLanguage.code)
                  .map((l) => l.nativeName)
                  .firstOrNull,
              orElse: () => null,
            ) ??
        selectedLanguage.code;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            Text(
              t.theme,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 146,
              child: HorizontalMouseScrollList(
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

            // Language: one row that opens a dedicated page.
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.language),
              title: Text(
                t.language,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                selectedLanguage.followsDevice
                    ? '${t.languageDeviceDefault} · $languageName'
                    : languageName,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/home/settings/language'),
            ),
            const SizedBox(height: 20),

            Text(t.settingsAppStartup,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsOpenBibleTab),
              subtitle: Text(t.settingsOpenBibleTabDesc,
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
              title: Text(t.settingsRequireLogin),
              subtitle: Text(t.settingsRequireLoginDesc,
              ),
              value: requireDummyLogin,
              onChanged: (value) {
                ref.read(requireDummyLoginProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 20),

            Text(t.settingsBibleViewer,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsShowIntroductions),
              subtitle: Text(t.settingsShowIntroductionsDesc,
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
              title: Text(t.settingsBoldDivineName),
              subtitle: Text(t.settingsBoldDivineNameDesc,
              ),
              value: boldDivineName,
              onChanged: (value) {
                ref.read(boldDivineNameProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsBoldWordsOfJesus),
              subtitle: Text(t.settingsBoldWordsOfJesusDesc,
              ),
              value: boldWordsOfJesus,
              onChanged: (value) {
                ref.read(boldWordsOfJesusProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsUnderlineProperNames),
              subtitle: Text(t.settingsUnderlineProperNamesDesc,
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
              title: Text(t.settingsUnderlineWordTags),
              subtitle: Text(t.settingsUnderlineWordTagsDesc,
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
              title: Text(t.settingsBracketAdditions),
              subtitle: Text(t.settingsBracketAdditionsDesc,
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
              title: Text(t.settingsSourceBold),
              subtitle: Text(t.settingsSourceBoldDesc,
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
              title: Text(t.settingsSourceDetails),
              subtitle: Text(t.settingsSourceDetailsDesc,
              ),
              value: showSourceDetails,
              onChanged: (value) {
                ref.read(showSourceDetailsProvider.notifier).setEnabled(value);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsVerseSelector),
              subtitle: Text(t.settingsVerseSelectorDesc,
              ),
              value: showVerseSelector,
              onChanged: (value) {
                ref.read(showVerseSelectorProvider.notifier).setEnabled(value);
              },
            ),
            const SizedBox(height: 20),

            Text(t.settingsNotes,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t.settingsConfirmUnlink),
              subtitle: Text(t.settingsConfirmUnlinkDesc,
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
              title: Text(t.settingsNotesAcrossTranslations),
              subtitle: Text(t.settingsNotesAcrossTranslationsDesc,
              ),
              value: showNotesAcrossTranslations,
              onChanged: (value) {
                ref
                    .read(showNotesAcrossTranslationsProvider.notifier)
                    .setEnabled(value);
              },
            ),
            const NotesBackupTiles(),
            const SizedBox(height: 20),

            const SyncSettingsSection(),
            const SizedBox(height: 20),

            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.developer_mode_outlined),
              title: Text(t.settingsAdvanced),
              subtitle: Text(t.settingsAdvancedDesc,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/home/settings/advanced'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.description_outlined),
              title: Text(t.settingsLicenses),
              subtitle: Text(t.settingsLicensesDesc),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showAppLicenses(context),
            ),
          ],
        ),
      ),
    );
  }
}
