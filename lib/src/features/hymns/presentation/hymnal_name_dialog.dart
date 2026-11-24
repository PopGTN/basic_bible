import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// The name the user chose for a hymn book.
typedef HymnalName = ({String title, String shortTitle});

/// Asks for a hymn book's name and optional short name (shown in the Hymns
/// tab's title). Used when importing a file and when renaming. Returns null
/// when cancelled.
Future<HymnalName?> showHymnalNameDialog(
  BuildContext context, {
  required String dialogTitle,
  required String confirmLabel,
  required String initialTitle,
  String? initialShortTitle,
  String? message,
}) => showDialog<HymnalName>(
  context: context,
  builder: (_) => _HymnalNameDialog(
    dialogTitle: dialogTitle,
    confirmLabel: confirmLabel,
    initialTitle: initialTitle,
    initialShortTitle: initialShortTitle ?? '',
    message: message,
  ),
);

class _HymnalNameDialog extends StatefulWidget {
  const _HymnalNameDialog({
    required this.dialogTitle,
    required this.confirmLabel,
    required this.initialTitle,
    required this.initialShortTitle,
    required this.message,
  });

  final String dialogTitle;
  final String confirmLabel;
  final String initialTitle;
  final String initialShortTitle;
  final String? message;

  @override
  State<_HymnalNameDialog> createState() => _HymnalNameDialogState();
}

class _HymnalNameDialogState extends State<_HymnalNameDialog> {
  late final _title = TextEditingController(text: widget.initialTitle);
  late final _short = TextEditingController(text: widget.initialShortTitle);

  @override
  void dispose() {
    _title.dispose();
    _short.dispose();
    super.dispose();
  }

  void _submit() {
    if (_title.text.trim().isEmpty) return;
    Navigator.pop<HymnalName>(context, (
      title: _title.text.trim(),
      shortTitle: _short.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!),
              const SizedBox(height: 12),
            ],
            ValueListenableBuilder(
              valueListenable: _title,
              builder: (context, value, _) => TextField(
                controller: _title,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: t.hymnalNameLabel,
                  errorText: value.text.trim().isEmpty
                      ? t.hymnalNameRequired
                      : null,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _short,
              textCapitalization: TextCapitalization.characters,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: t.hymnalShortNameLabel,
                helperText: t.hymnalShortNameHelper,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelAction),
        ),
        ValueListenableBuilder(
          valueListenable: _title,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: Text(widget.confirmLabel),
          ),
        ),
      ],
    );
  }
}
