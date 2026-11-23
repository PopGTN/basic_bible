import 'package:basic_bible/src/utils/localized_labels.dart';
import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/annotations/models/note_filters.dart';
import 'package:flutter/material.dart';

/// "Date" dropdown for the Notes filter bar (#39): pick how far back to show
/// and whether that (and the list order) uses the modified or created date.
class NotesDateFilterDropdown extends StatelessWidget {
  const NotesDateFilterDropdown({
    super.key,
    required this.field,
    required this.range,
    required this.onFieldChanged,
    required this.onRangeChanged,
  });

  final NoteDateField field;
  final NoteDateRange range;
  final ValueChanged<NoteDateField> onFieldChanged;
  final ValueChanged<NoteDateRange> onRangeChanged;

  bool get _isActive =>
      range != NoteDateRange.any || field != NoteDateField.modified;

  String _buttonLabel(AppLocalizations t) {
    if (range != NoteDateRange.any) {
      final rangeLabel = range.localizedLabel(t);
      return field == NoteDateField.created
          ? t.notesDateCreatedRange(rangeLabel)
          : rangeLabel;
    }
    return field == NoteDateField.created
        ? t.notesDateButtonCreated
        : t.notesDateButton;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    Icon radio(bool on) =>
        Icon(on ? Icons.radio_button_checked : Icons.radio_button_unchecked);

    return MenuAnchor(
      builder: (context, controller, child) => OutlinedButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.arrow_drop_down),
        label: Text(_buttonLabel(t), overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: _isActive
              ? colors.onSurface
              : colors.onSurfaceVariant,
          backgroundColor: _isActive ? colors.surfaceContainerHighest : null,
          side: BorderSide(
            color: _isActive ? colors.onSurface : colors.outlineVariant,
          ),
        ),
      ),
      menuChildren: [
        _MenuSectionLabel(t.notesDateShowSection),
        for (final option in NoteDateRange.values)
          MenuItemButton(
            closeOnActivate: false,
            leadingIcon: radio(option == range),
            onPressed: () => onRangeChanged(option),
            child: Text(option.localizedLabel(t)),
          ),
        const Divider(height: 8),
        _MenuSectionLabel(t.notesDateSortSection),
        for (final option in NoteDateField.values)
          MenuItemButton(
            closeOnActivate: false,
            leadingIcon: radio(option == field),
            onPressed: () => onFieldChanged(option),
            child: Text(option.localizedLabel(t)),
          ),
      ],
    );
  }
}

class _MenuSectionLabel extends StatelessWidget {
  const _MenuSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
