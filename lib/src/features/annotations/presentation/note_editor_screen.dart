import 'package:basic_bible/src/features/annotations/application/annotation_providers.dart';
import 'package:basic_bible/src/features/annotations/models/user_annotations.dart';
import 'package:basic_bible/src/features/annotations/presentation/annotation_theme.dart';
import 'package:basic_bible/src/features/reader/application/bible_provider.dart';
import 'package:basic_bible/src/features/reader/presentation/widgets/reference_bar.dart';
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
  });

  final AnnotationVerseLink primaryVerse;
  final UserAnnotation? existingAnnotation;
  final int? initialHighlightColorValue;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _noteController;
  late final TextEditingController _labelsController;

  @override
  void initState() {
    super.initState();
    final draftNotifier = ref.read(annotationEditorDraftProvider.notifier);
    if (widget.existingAnnotation != null) {
      draftNotifier.editExisting(widget.existingAnnotation!);
    } else {
      draftNotifier.startNew(
        primaryVerse: widget.primaryVerse,
        type: UserAnnotationType.note,
        highlightColorValue: widget.initialHighlightColorValue,
      );
    }
    final draft = ref.read(annotationEditorDraftProvider);
    _noteController = TextEditingController(text: draft?.noteText ?? '');
    _labelsController = TextEditingController(text: draft?.labels.join(', ') ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _labelsController.dispose();
    // Provider is no longer autoDispose; reset the draft so stale state
    // does not bleed into the next editor session if the screen is re-pushed.
    ref.read(annotationEditorDraftProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(annotationEditorDraftProvider);
    final booksAsync = ref.watch(bibleBooksShellProvider);
    if (draft == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final theme = Theme.of(context);
    final highlightColor = annotationColorFromValue(
      draft.highlightColorValue,
      theme.colorScheme.surfaceContainerHighest,
    );
    final canSave =
        draft.noteText.trim().isNotEmpty || draft.highlightColorValue != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingAnnotation == null ? 'New Note' : 'Edit Note',
        ),
        actions: [
          TextButton(
            onPressed: canSave ? () => _save(context, draft) : null,
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
            onChanged: ref
                .read(annotationEditorDraftProvider.notifier)
                .setNoteText,
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
            link: draft.primaryVerse,
            books: booksAsync.value ?? const [],
          ),
          for (final link in draft.linkedVerses) ...[
            const SizedBox(height: 10),
            _LinkedVerseCard(
              title: 'Linked Verse',
              link: link,
              books: booksAsync.value ?? const [],
              onRemove: () => ref
                  .read(annotationEditorDraftProvider.notifier)
                  .removeLinkedVerse(link),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: booksAsync.value == null
                ? null
                : () => _addVerse(context, draft, booksAsync.value!),
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
                isSelected: draft.highlightColorValue == null,
                label: 'None',
                fillColor: theme.colorScheme.surfaceContainerHighest,
                onTap: () => ref
                    .read(annotationEditorDraftProvider.notifier)
                    .setHighlightColor(null),
              ),
              for (final color in annotationHighlightPalette)
                _HighlightChoice(
                  isSelected: draft.highlightColorValue == color.toARGB32(),
                  label: '',
                  fillColor: color,
                  onTap: () => ref
                      .read(annotationEditorDraftProvider.notifier)
                      .setHighlightColor(color.toARGB32()),
                ),
            ],
          ),
          if (draft.highlightColorValue != null) ...[
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
              ref
                  .read(annotationEditorDraftProvider.notifier)
                  .setLabels(labels);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _addVerse(
    BuildContext context,
    AnnotationEditorDraft draft,
    List<BibleBook> books,
  ) async {
    final pickedReference = await Navigator.of(context).push<BibleReference>(
      MaterialPageRoute(
        builder: (context) => ReferencePickerScreen(
          books: books,
          currentReference: draft.primaryVerse.reference,
          showVerseSelector: true,
        ),
      ),
    );
    if (!mounted || !context.mounted || pickedReference?.verse == null) return;

    final translation = await resolveCurrentTranslation(ref);
    if (translation == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current translation is not available.')),
        );
      }
      return;
    }
    ref
        .read(annotationEditorDraftProvider.notifier)
        .addLinkedVerse(
          buildAnnotationVerseLink(
            reference: pickedReference!,
            translation: translation,
          ),
        );
  }

  Future<void> _save(BuildContext context, AnnotationEditorDraft draft) async {
    final annotation = draftToAnnotation(draft);
    await ref.read(userAnnotationRepositoryProvider).saveAnnotation(annotation);
    if (!mounted || !context.mounted) return;
    ref.read(annotationEditorDraftProvider.notifier).reset();
    Navigator.of(context).pop(true);
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
