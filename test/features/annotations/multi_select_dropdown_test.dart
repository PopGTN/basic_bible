// Guards the notes-screen filter dropdown: replicates the exact
// MenuAnchor + MenuItemButton(closeOnActivate: false) shape used by the
// private _MultiSelectDropdown in notes_screen.dart (can't import a private
// widget from another library file) to confirm the menu stays open across
// multiple taps and the button label reflects the current selection.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MultiSelectDropdown extends StatelessWidget {
  const _MultiSelectDropdown({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onToggled,
  });

  final String label;
  final List<MapEntry<String, String>> options;
  final Set<String> selectedValues;
  final void Function(String value, bool selected) onToggled;

  String get _buttonLabel {
    if (selectedValues.isEmpty) return label;
    if (selectedValues.length == 1) {
      final id = selectedValues.first;
      final match = options.where((entry) => entry.key == id).firstOrNull;
      return match?.value ?? label;
    }
    return '$label (${selectedValues.length})';
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          icon: const Icon(Icons.arrow_drop_down),
          label: Text(_buttonLabel, overflow: TextOverflow.ellipsis),
        );
      },
      menuChildren: [
        for (final entry in options)
          MenuItemButton(
            closeOnActivate: false,
            leadingIcon: Icon(
              selectedValues.contains(entry.key)
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            onPressed: () =>
                onToggled(entry.key, !selectedValues.contains(entry.key)),
            child: Text(entry.value),
          ),
      ],
    );
  }
}

class _Harness extends StatefulWidget {
  const _Harness({required this.options});

  final List<MapEntry<String, String>> options;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: _MultiSelectDropdown(
            label: 'Translation',
            options: widget.options,
            selectedValues: selected,
            onToggled: (value, isSelected) => setState(() {
              if (isSelected) {
                selected.add(value);
              } else {
                selected.remove(value);
              }
            }),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'menu stays open across multiple taps and toggles several options',
    (tester) async {
      await tester.pumpWidget(
        const _Harness(
          options: [
            MapEntry('kjv', 'KJV'),
            MapEntry('niv', 'NIV'),
            MapEntry('esv', 'ESV'),
          ],
        ),
      );

      expect(find.text('Translation'), findsOneWidget);

      await tester.tap(find.byWidgetPredicate((widget) => widget is OutlinedButton));
      await tester.pumpAndSettle();

      expect(find.text('KJV'), findsOneWidget);
      expect(find.text('NIV'), findsOneWidget);
      expect(find.text('ESV'), findsOneWidget);

      // First selection.
      await tester.tap(find.text('KJV'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('NIV'), findsOneWidget, reason: 'menu closed after one tap');
      expect(find.text('KJV', skipOffstage: false), findsWidgets);

      // Second selection — proves the menu is still open and state updates.
      await tester.tap(find.text('ESV'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Button label collapses to a count once more than one is selected.
      expect(find.text('Translation (2)'), findsOneWidget);

      // Unchecking closes nothing either, and updates the label back down.
      await tester.tap(find.text('KJV'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Only one selected now, so the label shows that option's own name —
      // matching both the button label and the still-open menu item.
      expect(find.text('ESV'), findsNWidgets(2));
    },
  );
}
