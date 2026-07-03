import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_preferences_view_models.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/annotations/presentation/linked_verses_section.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_picker_screen.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({
    super.key,
    required this.primaryVerse,
    this.existingAnnotation,
    this.initialHighlightColorValue,
    this.initialLinkedVerses = const [],
  });

  final AnnotationVerseLink primaryVerse;
  final UserAnnotation? existingAnnotation;
  final int? initialHighlightColorValue;
  final List<AnnotationVerseLink> initialLinkedVerses;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late AnnotationEditorDraft _draft;
  late final TextEditingController _noteController;
  late final TextEditingController _labelsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAnnotation;
    _draft = existing != null
        ? AnnotationEditorDraft.fromAnnotation(existing)
        : AnnotationEditorDraft(
            type: UserAnnotationType.note,
            primaryVerse: widget.primaryVerse,
            highlightColorValue: widget.initialHighlightColorValue,
            linkedVerses: widget.initialLinkedVerses,
          );
    _noteController = TextEditingController(text: _draft.noteText);
    _labelsController = TextEditingController(text: _draft.labels.join(', '));
  }

  @override
  void dispose() {
    _noteController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Draft mutation — local setState, no global provider needed
  // ---------------------------------------------------------------------------

  void _setNoteText(String value) =>
      setState(() => _draft = _draft.copyWith(noteText: value));

  void _setLabels(List<String> labels) =>
      setState(() => _draft = _draft.copyWith(labels: labels));

  void _setHighlightColor(int? value) => setState(
    () => _draft = _draft.copyWith(
      highlightColorValue: value,
      clearHighlightColor: value == null,
    ),
  );

  void _addLinkedVerse(AnnotationVerseLink verse) {
    final exists = _draft.linkedVerses.any(
      (link) =>
          link.bookId == verse.bookId &&
          link.chapter == verse.chapter &&
          link.verse == verse.verse &&
          link.translationId == verse.translationId,
    );
    if (exists) return;
    setState(
      () => _draft = _draft.copyWith(
        linkedVerses: [
          ..._draft.linkedVerses,
          verse.copyWith(sortOrder: _draft.linkedVerses.length),
        ],
      ),
    );
  }

  void _removeLinkedVerse(AnnotationVerseLink verse) {
    final next = _draft.linkedVerses
        .where(
          (link) =>
              !(link.bookId == verse.bookId &&
                  link.chapter == verse.chapter &&
                  link.verse == verse.verse &&
                  link.translationId == verse.translationId),
        )
        .toList();
    setState(
      () => _draft = _draft.copyWith(
        linkedVerses: [
          for (var i = 0; i < next.length; i++) next[i].copyWith(sortOrder: i),
        ],
      ),
    );
  }

  // Promotes the first linked verse to primary and removes it from the linked
  // list. Only callable when linkedVerses is non-empty.
  void _removePrimaryVerse() {
    if (_draft.linkedVerses.isEmpty) return;
    final newPrimary = _draft.linkedVerses.first;
    final remaining = [
      for (var i = 1; i < _draft.linkedVerses.length; i++)
        _draft.linkedVerses[i].copyWith(sortOrder: i - 1),
    ];
    setState(
      () => _draft = _draft.copyWith(
        primaryVerse: newPrimary,
        linkedVerses: remaining,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _addVerse(BuildContext context, List<BibleBook> books) async {
    final pickedReference = await Navigator.of(context).push<BibleReference>(
      MaterialPageRoute(
        builder: (context) => ReferencePickerScreen(
          books: books,
          currentReference: _draft.primaryVerse.reference,
          showVerseSelector: true,
        ),
      ),
    );
    if (!mounted || !context.mounted || pickedReference?.verse == null) return;

    final translation = await resolveCurrentTranslation(ref);
    if (!mounted) return;
    if (translation == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current translation is not available.'),
          ),
        );
      }
      return;
    }
    _addLinkedVerse(
      buildAnnotationVerseLink(
        reference: pickedReference!,
        translation: translation,
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final annotation = draftToAnnotation(_draft);
    try {
      await ref
          .read(userAnnotationRepositoryProvider)
          .saveAnnotation(annotation);
    } catch (_) {
      if (mounted && context.mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save note. Please try again.'),
          ),
        );
      }
      return;
    }

    if (!mounted || !context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(bibleBooksShellProvider);
    final theme = Theme.of(context);
    final highlightColor = annotationColorFromValue(
      _draft.highlightColorValue,
      theme.colorScheme.surfaceContainerHighest,
    );
    final canSave =
        _draft.noteText.trim().isNotEmpty || _draft.highlightColorValue != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAnnotation == null ? 'New Note' : 'Edit Note',
        ),
        actions: [
          TextButton(
            onPressed: (canSave && !_isSaving) ? () => _save(context) : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            controller: _noteController,
            maxLines: 8,
            minLines: 6,
            decoration: const InputDecoration(
              labelText: 'Note',
              alignLabelWithHint: true,
              hintText: 'Write your note here.',
            ),
            onChanged: _setNoteText,
          ),
          const SizedBox(height: 16),
          Text(
            'Linked Verses',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _LinkedVerseCard(
            title: 'Primary Verse',
            link: _draft.primaryVerse,
            books: booksAsync.value ?? const [],
            onRemove: _draft.linkedVerses.isNotEmpty
                ? _removePrimaryVerse
                : null,
          ),
          if (_draft.linkedVerses.isNotEmpty) ...[
            const SizedBox(height: 10),
            LinkedVersesSection(
              books: booksAsync.value ?? const [],
              links: _draft.linkedVerses,
              maxVisible: 20,
              emptyMessage: null,
              onPreviewLinkedVerse: (link) async {},
              onDeleteLink: (link) async {
                final confirm = ref.read(confirmRemoveLinkedVerseProvider);
                if (confirm) {
                  final allBooks = booksAsync.value ?? const <BibleBook>[];
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Remove verse?'),
                      content: Text(
                        '${displayBookNameForReference(allBooks, link.bookId)} '
                        '${link.chapter}:${link.verse} will be unlinked from this note.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Remove'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true || !mounted) return;
                }
                _removeLinkedVerse(link);
              },
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: booksAsync.value == null
                ? null
                : () => _addVerse(context, booksAsync.value!),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Verse'),
          ),
          const SizedBox(height: 20),
          Text(
            'Connected Highlight',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HighlightChoice(
                isSelected: _draft.highlightColorValue == null,
                label: 'None',
                fillColor: theme.colorScheme.surfaceContainerHighest,
                onTap: () => _setHighlightColor(null),
              ),
              for (final color in annotationHighlightPalette)
                _HighlightChoice(
                  isSelected: _draft.highlightColorValue == color.toARGB32(),
                  label: '',
                  fillColor: color,
                  onTap: () => _setHighlightColor(color.toARGB32()),
                ),
            ],
          ),
          if (_draft.highlightColorValue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: highlightColor.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'This note will keep a connected verse highlight on its primary verse.',
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: _labelsController,
            decoration: const InputDecoration(
              labelText: 'Labels',
              hintText: 'Comma separated labels',
            ),
            onChanged: (value) {
              final labels = value
                  .split(',')
                  .map((item) => item.trim())
                  .where((item) => item.isNotEmpty)
                  .toList();
              _setLabels(labels);
            },
          ),
        ],
      ),
    );
  }
}

class _LinkedVerseCard extends StatelessWidget {
  const _LinkedVerseCard({
    required this.title,
    required this.link,
    required this.books,
    this.onRemove,
  });

  final String title;
  final AnnotationVerseLink link;
  final List<BibleBook> books;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookName = displayBookNameForReference(books, link.bookId);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHigh,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bookName ${link.chapter}:${link.verse}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  link.translationName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(onPressed: onRemove, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}

class _HighlightChoice extends StatelessWidget {
  const _HighlightChoice({
    required this.isSelected,
    required this.label,
    required this.fillColor,
    required this.onTap,
  });

  final bool isSelected;
  final String label;
  final Color fillColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: fillColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: label.isEmpty
            ? null
            : Icon(
                Icons.close,
                color: theme.colorScheme.onSurfaceVariant,
                size: 18,
              ),
      ),
    );
  }
}
