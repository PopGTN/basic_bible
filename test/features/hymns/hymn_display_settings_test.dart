import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/hymns/application/view_models/hymn_settings_view_model.dart';
import 'package:basic_bible/src/features/hymns/presentation/hymn_display_settings.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _preview = "How sweet the name of Jesus sounds\nIn a believer's ear!";

double _previewSize(WidgetTester tester) =>
    tester.widget<Text>(find.text(_preview)).style!.fontSize!;

void main() {
  testWidgets('text size shows a readout and a preview at the real size', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(child: HymnDisplaySettingsPanel()),
          ),
        ),
      ),
    );

    expect(find.text('100%'), findsOneWidget);
    expect(_previewSize(tester), HymnSettings.baseLyricSize);

    await tester.tap(find.byTooltip('Larger text'));
    await tester.pump();
    await tester.tap(find.byTooltip('Larger text'));
    await tester.pump();
    expect(find.text('120%'), findsOneWidget);
    expect(
      _previewSize(tester),
      closeTo(HymnSettings.baseLyricSize * 1.2, 1e-9),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HymnDisplaySettingsPanel)),
    );
    expect(
      container.read(hymnSettingsProvider).lyricSize,
      _previewSize(tester),
      reason: 'preview uses the same size as the hymn view',
    );

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('Smaller text'));
      await tester.pump();
    }
    expect(find.text('80%'), findsOneWidget, reason: 'stops at the minimum');
    final smaller = tester.widget<IconButton>(
      find.ancestor(
        of: find.text('A').first,
        matching: find.byType(IconButton),
      ),
    );
    expect(smaller.onPressed, isNull);
  });
}
