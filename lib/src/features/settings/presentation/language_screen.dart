import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/localization/language_pack_providers.dart';
import 'package:basic_bible/src/features/localization/language_pack_service.dart';
import 'package:basic_bible/src/features/settings/application/view_models/language_view_model.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-page language picker. Language packs download from GitHub on demand.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    LanguageInfo? language,
  ) async {
    final notifier = ref.read(languageProvider.notifier);
    final ok = language == null
        ? await notifier.useDeviceLanguage()
        : await notifier.setLanguage(language.code);
    if (!ok && context.mounted) {
      final name = language?.nativeName ?? '';
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.languageDownloadFailed(name),
          ),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.retryAction,
            onPressed: () => _select(context, ref, language),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final state = ref.watch(languageProvider);
    final languages = ref.watch(availableLanguagesProvider);
    final service = ref.watch(languagePackServiceProvider);
    final deviceCode = resolveDeviceLanguage(
      WidgetsBinding.instance.platformDispatcher.locales,
    );

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: Text(t.language)),
      body: languages.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const SizedBox.shrink(),
        data: (list) {
          final deviceName = list
              .where((l) => l.code == deviceCode)
              .map((l) => l.nativeName)
              .firstOrNull;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.smartphone_outlined),
                title: Text(t.languageDeviceDefault),
                subtitle: deviceName == null ? null : Text(deviceName),
                trailing: state.followsDevice
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: state.downloadingCode != null
                    ? null
                    : () => _select(context, ref, null),
              ),
              const Divider(height: 1),
              for (final language in list)
                _LanguageTile(
                  language: language,
                  selected: !state.followsDevice && state.code == language.code,
                  downloading: state.downloadingCode == language.code,
                  offline: service.isAvailableOffline(language.code),
                  failed: state.errorCode == language.code,
                  onTap: state.downloadingCode != null
                      ? null
                      : () => _select(context, ref, language),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.downloading,
    required this.offline,
    required this.failed,
    required this.onTap,
  });

  final LanguageInfo language;
  final bool selected;
  final bool downloading;
  final bool offline;
  final bool failed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final subtitle = downloading
        ? t.languageDownloading
        : (language.englishName == language.nativeName
              ? null
              : language.englishName);

    Widget? trailing;
    if (downloading) {
      trailing = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (selected) {
      trailing = Icon(Icons.check, color: colors.primary);
    } else if (failed) {
      trailing = Icon(Icons.error_outline, color: colors.error);
    } else if (offline) {
      trailing = Tooltip(
        message: t.languageAvailableOffline,
        child: Icon(Icons.download_done_outlined, color: colors.onSurfaceVariant),
      );
    } else {
      trailing = Tooltip(
        message: t.languageNeedsDownload,
        child: Icon(Icons.cloud_download_outlined, color: colors.onSurfaceVariant),
      );
    }

    return ListTile(
      title: Text(language.nativeName),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing,
      selected: selected,
      onTap: onTap,
    );
  }
}
