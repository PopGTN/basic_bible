import 'package:basic_bible/src/features/reader/presentation/reader_scope.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/reader/presentation/reference_picker/reference_picker_screen.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';

class ChapterBar extends StatelessWidget {
  const ChapterBar({
    super.key,
    required double barHeight,
    required this.reference,
    required this.books,
    required this.canOpenReferencePicker,
    required this.showVerseSelector,
    required this.onReferenceChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  }) : _barHeight = barHeight;

  final double _barHeight;
  final BibleReference reference;
  final List<BibleBook> books;
  final bool canOpenReferencePicker;
  final bool showVerseSelector;
  final Function(BibleReference) onReferenceChanged;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final referenceBookName = displayBookNameForReference(
      books,
      reference.bookId,
    );
    final row = Row(
      children: [
        _BarActionButton(
          icon: Icons.arrow_back_ios_new,
          onPressed: onPreviousChapter,
          tooltip: l10n.previousChapterTooltip,
        ),
        Expanded(
          child: InkWell(
            onTap: canOpenReferencePicker
                ? () => _showReferencePicker(context)
                : null,
            borderRadius: BorderRadius.circular(_barHeight / 2),
            child: Center(
              child: Text(
                chapterReferenceLabel(referenceBookName, reference.chapter),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        _BarActionButton(
          icon: Icons.arrow_forward_ios,
          onPressed: onNextChapter,
          tooltip: l10n.nextChapterTooltip,
        ),
      ],
    );

    // YouVersion-style: a round play button beside the chapter pill, both
    // on the same raised surface.
    Widget surface(ShapeBorder shape, Widget child) => Material(
      color: colors.surfaceContainerHighest,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: shape,
      child: child,
    );
    final border = BorderSide(
      color: colors.outlineVariant.withValues(alpha: 0.3),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SizedBox(
        height: _barHeight,
        child: Row(
          children: [
            // Audio play/pause. Hidden until audio playback exists; restore
            // it (and the 12px gap) when it does. Its speed/track settings
            // open from the app bar's audio button (see home_screen.dart).
            // SizedBox.square(
            //   dimension: _barHeight,
            //   child: surface(
            //     CircleBorder(side: border),
            //     IconButton(
            //       icon: const Icon(Icons.play_arrow_rounded, size: 28),
            //       tooltip: l10n.playAudioTooltip,
            //       color: colors.onSurface,
            //       onPressed: () { /* start/pause playback */ },
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: surface(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_barHeight / 2),
                  side: border,
                ),
                row,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showReferencePicker(BuildContext context) async {
    final newReference = await Navigator.of(context).push<BibleReference>(
      MaterialPageRoute(
        builder: inReaderScope(
          context,
          (context) => ReferencePickerScreen(
            books: books,
            currentReference: reference,
            showVerseSelector: showVerseSelector,
          ),
        ),
      ),
    );
    if (newReference != null && context.mounted) {
      onReferenceChanged(newReference);
    }
  }
}

class _BarActionButton extends StatelessWidget {
  const _BarActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      tooltip: tooltip,
      color: colors.onSurface,
      splashRadius: 22,
    );
  }
}
