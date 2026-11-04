import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a translation's copyright, license and source in a bottom sheet.
Future<void> showTranslationRightsSheet(
  BuildContext context,
  BibleTranslation translation,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => TranslationRightsSheet(translation: translation),
  );
}

class TranslationRightsSheet extends StatelessWidget {
  const TranslationRightsSheet({super.key, required this.translation});

  final BibleTranslation translation;

  static Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {
      // No browser available; nothing useful to do.
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final rights = translation.rights;

    final description = translation.description.trim();
    final license = rights == null
        ? ''
        : rights.license.isNotEmpty
        ? rights.license
        : rights.isPublicDomain
        ? t.translationRightsPublicDomain
        : '';

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(translation.name, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              '${translation.id.toUpperCase()} · '
              '${translation.effectiveLanguageName}',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(description, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: 8),
            if (rights == null)
              _Section(
                label: t.translationRightsLicenseLabel,
                child: Text(
                  translation.sourceType == BibleSourceType.import
                      ? t.translationRightsUnknownImported
                      : t.translationRightsUnknown,
                ),
              )
            else ...[
              if (license.isNotEmpty)
                _Section(
                  label: t.translationRightsLicenseLabel,
                  child: Text(license, style: textTheme.titleMedium),
                ),
              if (rights.copyrightNotice.isNotEmpty)
                _Section(
                  label: t.translationRightsNoticeLabel,
                  child: SelectableText(rights.copyrightNotice),
                ),
              if (!rights.allowDownload)
                _Section(
                  label: t.translationRightsPermissionsLabel,
                  child: Text(t.translationRightsDownloadNotPermitted),
                ),
              const SizedBox(height: 8),
              if (rights.licenseUrl case final url?)
                _LinkTile(
                  icon: Icons.gavel_outlined,
                  label: t.translationRightsViewLicense,
                  url: url,
                  onOpen: _open,
                ),
              if (rights.sourceUrl case final url?)
                _LinkTile(
                  icon: Icons.public,
                  label: t.translationRightsSourceLabel,
                  url: url,
                  onOpen: _open,
                ),
              if (rights.notesUrl case final url?)
                _LinkTile(
                  icon: Icons.description_outlined,
                  label: t.translationRightsNotesAction,
                  url: url,
                  onOpen: _open,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.url,
    required this.onOpen,
  });

  final IconData icon;
  final String label;
  final String url;
  final Future<void> Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(
        Uri.tryParse(url)?.host ?? url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: () => onOpen(url),
    );
  }
}
