import 'dart:io';

import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class AdvancedSettingsScreen extends ConsumerWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translationsAsync = ref.watch(availableTranslationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Advanced'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These tools are intended for development and debugging. '
                      'Exported database files contain parsed Bible content — '
                      'verify you have the right to redistribute a translation before sharing it.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Export Translation Databases',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Exports the cached SQLite file for a translation. '
              'Open the translation in the reader first if the file is not yet cached.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            translationsAsync.when(
              data: (translations) {
                if (translations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No translations installed.'),
                  );
                }
                return Column(
                  children: [
                    for (final t in translations)
                      _TranslationExportTile(translation: t),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text('Failed to load translations: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-translation export tile
// ---------------------------------------------------------------------------

class _TranslationExportTile extends StatefulWidget {
  const _TranslationExportTile({required this.translation});

  final BibleTranslation translation;

  @override
  State<_TranslationExportTile> createState() => _TranslationExportTileState();
}

class _TranslationExportTileState extends State<_TranslationExportTile> {
  bool _exporting = false;

  Future<void> _export() async {
    if (_exporting) return;
    setState(() => _exporting = true);

    try {
      final dbPath = await TranslationDatabaseManager.pathForTranslation(
        widget.translation.id,
      );
      final file = File(dbPath);

      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${widget.translation.name}" has not been loaded yet. '
                'Open it in the reader first to generate the cache file.',
              ),
            ),
          );
        }
        return;
      }

      final fileName =
          '${widget.translation.id.toLowerCase()}.sqlite';

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Mobile: share via OS share sheet
        await Share.shareXFiles(
          [XFile(dbPath)],
          subject: '${widget.translation.name} Bible Database',
          text: fileName,
        );
      } else {
        // Desktop (Linux / Windows / macOS): save to a user-chosen path
        final location = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'SQLite database',
              extensions: ['sqlite', 'db'],
            ),
          ],
        );
        if (location == null) return; // user cancelled

        await file.copy(location.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to ${location.path}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.translation.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.translation.id.toUpperCase()} · ${widget.translation.language.toUpperCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _exporting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : FilledButton.tonal(
                  onPressed: _export,
                  child: const Text('Export'),
                ),
        ],
      ),
    );
  }
}
