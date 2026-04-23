import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/settings/application/view_models/advanced_preferences_view_models.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/platform/runtime_support.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/services/translation_database_manager.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'translation_db_exporter.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() =>
      _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState
    extends ConsumerState<AdvancedSettingsScreen> {
  late final TextEditingController _catalogUrlController;
  String? _lastSyncedOverride;
  bool _savingCatalogUrl = false;

  @override
  void initState() {
    super.initState();
    final initialValue = ref.read(translationCatalogUrlOverrideProvider) ?? '';
    _lastSyncedOverride = ref.read(translationCatalogUrlOverrideProvider);
    _catalogUrlController = TextEditingController(text: initialValue);
    _catalogUrlController.addListener(_handleCatalogUrlChanged);
  }

  @override
  void dispose() {
    _catalogUrlController
      ..removeListener(_handleCatalogUrlChanged)
      ..dispose();
    super.dispose();
  }

  void _handleCatalogUrlChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _hasUnsavedCatalogUrlChanges {
    final currentText = _catalogUrlController.text.trim();
    final savedValue = (_lastSyncedOverride ?? '').trim();
    return currentText != savedValue;
  }

  String? get _catalogUrlValidationError {
    final value = _catalogUrlController.text.trim();
    if (value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a full URL like https://example.com/catalog.json';
    }
    if (uri.scheme != 'https' && uri.scheme != 'http') {
      return 'Only http:// and https:// catalog URLs are supported.';
    }
    return null;
  }

  Future<void> _saveCatalogUrlOverride() async {
    if (_savingCatalogUrl) return;
    final validationError = _catalogUrlValidationError;
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _savingCatalogUrl = true;
    });

    try {
      await ref
          .read(translationCatalogUrlOverrideProvider.notifier)
          .setUrl(_catalogUrlController.text);
      _lastSyncedOverride = ref.read(translationCatalogUrlOverrideProvider);
      ref.invalidate(availableTranslationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _lastSyncedOverride == null
                ? 'Translation catalog URL reset to default.'
                : 'Translation catalog URL saved.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save catalog URL: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingCatalogUrl = false;
        });
      }
    }
  }

  Future<void> _resetCatalogUrlOverride() async {
    if (_savingCatalogUrl) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _savingCatalogUrl = true;
    });

    try {
      await ref
          .read(translationCatalogUrlOverrideProvider.notifier)
          .resetToDefault();
      _lastSyncedOverride = null;
      _catalogUrlController.text = '';
      ref.invalidate(availableTranslationsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Translation catalog URL reset to default.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not reset catalog URL: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingCatalogUrl = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationsAsync = ref.watch(availableTranslationsProvider);
    final catalogUrlOverride = ref.watch(translationCatalogUrlOverrideProvider);
    if (!_hasUnsavedCatalogUrlChanges &&
        catalogUrlOverride != _lastSyncedOverride &&
        !_savingCatalogUrl) {
      _lastSyncedOverride = catalogUrlOverride;
      final syncedValue = catalogUrlOverride ?? '';
      if (_catalogUrlController.text != syncedValue) {
        _catalogUrlController.value = TextEditingValue(
          text: syncedValue,
          selection: TextSelection.collapsed(offset: syncedValue.length),
        );
      }
    }

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
            _TranslationCatalogUrlCard(
              controller: _catalogUrlController,
              currentOverride: catalogUrlOverride,
              validationError: _catalogUrlValidationError,
              isSaving: _savingCatalogUrl,
              hasUnsavedChanges: _hasUnsavedCatalogUrlChanges,
              onSave: _saveCatalogUrlOverride,
              onReset: _resetCatalogUrlOverride,
            ),
            const SizedBox(height: 24),
            Text(
              'Export Translation Databases',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
            if (isWebRuntime)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Browser builds can read and cache translations, but exporting cached database files is not available on web yet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
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
                      _TranslationExportTile(
                        translation: t,
                        enabled: !isWebRuntime,
                      ),
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

class _TranslationCatalogUrlCard extends StatelessWidget {
  const _TranslationCatalogUrlCard({
    required this.controller,
    required this.currentOverride,
    required this.validationError,
    required this.isSaving,
    required this.hasUnsavedChanges,
    required this.onSave,
    required this.onReset,
  });

  final TextEditingController controller;
  final String? currentOverride;
  final String? validationError;
  final bool isSaving;
  final bool hasUnsavedChanges;
  final Future<void> Function() onSave;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usingDefault = currentOverride == null || currentOverride!.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translation Catalog URL',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Override the remote JSON catalog used to load available translations. '
            'Leave blank or tap Reset to go back to the built-in default source.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !isSaving,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: 'Catalog URL',
              hintText: 'https://raw.githubusercontent.com/.../bibles.json',
              errorText: validationError,
              helperText: usingDefault
                  ? 'Using built-in default catalog endpoint.'
                  : 'Using custom catalog endpoint override.',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            'Default: ${RemoteTranslationCatalogService.defaultCatalogUrl}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton(
                onPressed:
                    isSaving || !hasUnsavedChanges || validationError != null
                    ? null
                    : onSave,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              OutlinedButton(
                onPressed: isSaving || usingDefault ? null : onReset,
                child: const Text('Reset To Default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TranslationExportTile extends StatefulWidget {
  const _TranslationExportTile({
    required this.translation,
    this.enabled = true,
  });

  final BibleTranslation translation;
  final bool enabled;

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
      final fileName = '${widget.translation.id.toLowerCase()}.sqlite';

      await exportTranslationDatabase(
        dbPath: dbPath,
        fileName: fileName,
        translationName: widget.translation.name,
      );

      if (mounted && !isMobileRuntime) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export completed for ${widget.translation.name}.'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
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
                  onPressed: widget.enabled ? _export : null,
                  child: const Text('Export'),
                ),
        ],
      ),
    );
  }
}
