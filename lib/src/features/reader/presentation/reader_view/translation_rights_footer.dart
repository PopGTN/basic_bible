import 'package:basic_bible/src/features/library/presentation/translation_rights_sheet.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final license = rights.license.trim().isNotEmpty
        ? rights.license.trim()
        : rights.isPublicDomain
        ? 'Public Domain'
        : null;
    final label = [
      translation.id.toUpperCase(),
      if (license != null) license,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Center(
        child: TextButton.icon(
          onPressed: () => showTranslationRightsSheet(context, translation),
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
