import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/widgets/app_back_button.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportTranslationScreen extends ConsumerStatefulWidget {
  const ImportTranslationScreen({
    super.key,
    required this.filePath,
    required this.existingIds,
  });

  final String filePath;
  final Set<String> existingIds;

  @override
  ConsumerState<ImportTranslationScreen> createState() =>
      _ImportTranslationScreenState();
}

class _ImportTranslationScreenState
    extends ConsumerState<ImportTranslationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _abbreviationController = TextEditingController();
  final _languageController = TextEditingController();
  final _descriptionController = TextEditingController();

  late final Future<BibleImportDraft> _draftFuture;
  bool _didInitializeControllers = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _draftFuture = ref
        .read(bibleBooksProvider.notifier)
        .prepareImportTranslation(widget.filePath);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _abbreviationController.dispose();
    _languageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(t.importBibleTitle),
      ),
      body: FutureBuilder<BibleImportDraft>(
        future: _draftFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.unableToPrepareImport(snapshot.error.toString())),
              ),
            );
          }

          final draft = snapshot.requireData;
          if (!_didInitializeControllers) {
            _nameController.text = draft.suggestedName;
            _abbreviationController.text = draft.suggestedId.toUpperCase();
            _languageController.text = draft.suggestedLanguage;
            _descriptionController.text = draft.suggestedDescription;
            _didInitializeControllers = true;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ImportSummaryCard(draft: draft),
                    const SizedBox(height: 20),
                    Text(
                      t.translationDetailsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.translationDetailsDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: t.translationNameLabel,
                        hintText: t.translationNameHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.translationNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _abbreviationController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: t.translationAbbreviationLabel,
                        hintText: t.translationAbbreviationHint,
                        helperText: t.translationAbbreviationHelp,
                      ),
                      validator: (value) {
                        final normalized = _normalizeAbbreviation(value);
                        if (normalized.isEmpty) {
                          return t.translationAbbreviationRequired;
                        }
                        if (widget.existingIds.contains(normalized) &&
                            normalized != draft.suggestedId) {
                          return t.translationAbbreviationTaken;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _languageController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: t.translationLanguageCodeLabel,
                        hintText: t.translationLanguageCodeHint,
                        helperText: t.translationLanguageCodeHelp,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t.translationLanguageCodeRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: t.translationDescriptionLabel,
                        hintText: t.translationDescriptionHint,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitImport(context, draft),
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.library_add),
                        label: Text(
                          _isSubmitting
                              ? t.importingAction
                              : t.importTranslationAction,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitImport(
    BuildContext context,
    BibleImportDraft draft,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    final t = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final importedTranslation = await ref
          .read(bibleBooksProvider.notifier)
          .importPreparedTranslation(
            BibleImportRequest(
              filePath: draft.filePath,
              format: draft.format,
              importedBooks: draft.importedBooks,
              id: _normalizeAbbreviation(_abbreviationController.text),
              name: _nameController.text.trim(),
              language: _languageController.text.trim().toLowerCase(),
              description: _descriptionController.text.trim().isEmpty
                  ? draft.suggestedDescription
                  : _descriptionController.text.trim(),
            ),
          );
      if (!mounted) return;
      navigator.pop(importedTranslation);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.importFailedMessage(error.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _normalizeAbbreviation(String? value) {
    if (value == null) return '';
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}

class _ImportSummaryCard extends StatelessWidget {
  const _ImportSummaryCard({required this.draft});

  final BibleImportDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft.fileName,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            t.detectedFormatLabel(draft.format.name.toUpperCase()),
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.booksFoundLabel(draft.importedBooks.length),
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
