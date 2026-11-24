import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/hymns/presentation/hymnal_name_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('returns the chosen name and requires one', (tester) async {
    HymnalName? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showHymnalNameDialog(
              context,
              dialogTitle: 'Name this hymn book',
              confirmLabel: 'Import',
              initialTitle: 'favoritehymns',
              message: 'Found 2 hymns.',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Found 2 hymns.'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '   ');
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
      reason: 'a blank name cannot be saved',
    );

    await tester.enterText(fields.first, 'Favorite Hymns');
    await tester.enterText(fields.last, 'FH');
    await tester.pump();
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(result, (title: 'Favorite Hymns', shortTitle: 'FH'));
  });
}
