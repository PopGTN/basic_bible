import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/hymns/application/view_models/hymnal_view_models.dart';
import 'package:basic_bible/src/features/hymns/data/hymnal_repository.dart';
import 'package:basic_bible/src/features/hymns/data/hymnal_store.dart';
import 'package:basic_bible/src/features/hymns/models/hymn.dart';
import 'package:basic_bible/src/features/hymns/models/hymn_search_index.dart';
import 'package:basic_bible/src/features/hymns/models/hymnal.dart';
import 'package:basic_bible/src/features/hymns/presentation/hymns_tab.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _hymns = [
  const Hymn(
    number: 1,
    title: 'Rock of Ages! Cleft for me',
    author: 'Toplady',
    verses: [
      ['Rock of Ages! Cleft for me,', 'Lo, I hide myself in Thee,'],
    ],
  ),
  const Hymn(
    number: 2,
    title: 'Lamb of God! our souls adore Thee',
    verses: [
      ['Lamb of God! our souls adore Thee', 'While upon Thy face we gaze;'],
      ['Second verse line', 'and another'],
    ],
    chorus: ['Worthy is the Lamb'],
  ),
];

final _hymnal = Hymnal(
  info: const HymnalInfo(
    id: 'bhb',
    title: 'The Believers Hymn Book',
    sourceKind: HymnalSourceKind.bundled,
    hymnCount: 2,
  ),
  hymns: _hymns,
  index: HymnSearchIndex(_hymns),
);

Future<void> _pump(WidgetTester tester, Size size) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        hymnalStoreProvider.overrideWithValue(InMemoryHymnalStore()),
        hymnalRepositoryProvider.overrideWithValue(
          HymnalRepository(store: InMemoryHymnalStore()),
        ),
        currentHymnalProvider.overrideWith((ref) async => _hymnal),
        hymnalListProvider.overrideWith((ref) async => [_hymnal.info]),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HymnsTab()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 120)); // debounce
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone: search, open a hymn, typing returns to the list', (
    tester,
  ) async {
    await _pump(tester, const Size(400, 800));
    expect(find.text('Rock of Ages! Cleft for me'), findsOneWidget);
    expect(find.text('Lamb of God! our souls adore Thee'), findsOneWidget);

    await _type(tester, 'lamb');
    expect(find.text('Rock of Ages! Cleft for me'), findsNothing);

    await tester.tap(find.text('Lamb of God! our souls adore Thee'));
    await tester.pumpAndSettle();
    expect(find.text('2. Lamb of God! our souls adore Thee'), findsOneWidget);
    // Chorus is shown once, after verse 1, by default.
    expect(find.text('Worthy is the Lamb'), findsOneWidget);

    await _type(tester, 'rock');
    expect(find.text('2. Lamb of God! our souls adore Thee'), findsNothing);
    expect(find.text('Rock of Ages! Cleft for me'), findsOneWidget);
  });

  testWidgets('wide: the hymn stays open while results update', (tester) async {
    await _pump(tester, const Size(1200, 800));
    await tester.tap(find.text('Rock of Ages! Cleft for me'));
    await tester.pumpAndSettle();
    expect(find.text('1. Rock of Ages! Cleft for me'), findsOneWidget);

    await _type(tester, 'lamb');
    expect(find.text('1. Rock of Ages! Cleft for me'), findsOneWidget);
    expect(find.text('Lamb of God! our souls adore Thee'), findsOneWidget);
    expect(find.text('Rock of Ages! Cleft for me'), findsNothing);
  });

  testWidgets('favorites filter shows only starred hymns', (tester) async {
    await _pump(tester, const Size(400, 800));
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HymnsTab)),
    );
    expect(container.read(hymnFavoritesProvider('bhb')), {1});
    container.read(hymnFavoritesOnlyProvider.notifier).set(true);
    await tester.pumpAndSettle();
    expect(find.text('Rock of Ages! Cleft for me'), findsOneWidget);
    expect(find.text('Lamb of God! our souls adore Thee'), findsNothing);
  });
}
