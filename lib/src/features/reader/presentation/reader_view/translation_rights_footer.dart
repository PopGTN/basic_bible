import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Copyright line shown at the end of every chapter (#18): the translation
/// and its license. Tapping it opens the full notice with links. Renders
/// nothing when the translation's rights are unknown (e.g. an imported file).
class TranslationRightsFooter extends ConsumerWidget {
  const TranslationRightsFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translation = ref.watch(currentTranslationInfoProvider);
    final rights = translation?.rights;
    if (translation == null || rights == null || rights.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    final label = [
      translation.id.toUpperCase(),
      if (rights.license != null) rights.license!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (_) => TranslationRightsSheet(translation: translation),
          ),
          icon: Icon(Icons.copyright, size: 16, color: color),
          label: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class TranslationRightsSheet extends StatelessWidget {
  const TranslationRightsSheet({super.key, required this.translation});

  final BibleTranslation translation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rights = translation.rights!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translation.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (rights.license != null) ...[
              const SizedBox(height: 4),
              Text(rights.license!, style: theme.textTheme.titleSmall),
            ],
            if (rights.copyrightNotice != null) ...[
              const SizedBox(height: 16),
              Text(
                rights.copyrightNotice!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (rights.licenseUrl != null)
                  OutlinedButton.icon(
                    onPressed: () => _open(rights.licenseUrl!),
                    icon: const Icon(Icons.gavel_outlined),
                    label: const Text('License'),
                  ),
                if (rights.sourceUrl != null &&
                    rights.sourceUrl != rights.licenseUrl)
                  OutlinedButton.icon(
                    onPressed: () => _open(rights.sourceUrl!),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Source'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(String url) =>
      launchUrlString(url, mode: LaunchMode.externalApplication);
}
