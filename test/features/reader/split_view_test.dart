// Issue #84: split view — a second reader with its own translation/location.

import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/reader/application/view_models/current_chapter_view_model.dart';
import 'package:basic_bible/src/features/library/data/app_bible_repository.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_data_view_models.dart';
import 'package:basic_bible/src/features/annotations/application/view_models/annotation_selection_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_library_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/reader_session_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/translation_actions_view_model.dart';
import 'package:basic_bible/src/features/reader/application/view_models/bible_search_view_models.dart';
import 'package:basic_bible/src/features/reader/application/view_models/split_view_view_models.dart';
import 'package:basic_bible/src/features/reader/presentation/reader_scope.dart';
import 'package:basic_bible/src/features/reader/presentation/split_view/split_reader_layout.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:basic_bible/src/utils/reference_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

BibleBook _book(String id, int chapters) => BibleBook(
  id: id,
  name: id == 'GEN' ? 'Genesis' : 'Exodus',
  shortName: id,
  bookNumber: id == 'GEN' ? 1 : 2,
  chapters: [for (var c = 1; c <= chapters; c++) BibleChapter(number: c)],
);

final _books = [_book('GEN', 2), _book('EXO', 1)];

Future<SharedPreferences> _prefs(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues({
    'bible_translation': 'kjv',
    'bible_book': 'EXO',
    'bible_chapter': 1,
    ...values,
  });
  return SharedPreferences.getInstance();
}

/// Root container plus a child scoped like the split-view pane.
Future<(ProviderContainer, ProviderContainer)> _containers(
  Map<String, Object> values,
) async {
  final sp = await _prefs(values);
  final root = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
  final pane = ProviderContainer(
    parent: root,
    overrides: splitPaneOverrides(
      sp,
      mainTranslation: root.read(currentTranslationProvider),
      mainReference: root.read(currentReferenceProvider),
    ),
  );
  addTearDown(root.dispose);
  addTearDown(pane.dispose);
  return (root, pane);
}

/// Hydrated books from memory, so the real chapter providers run without disk.
class _InMemoryRepository implements AppBibleRepository {
  final _loaded = [
    for (final id in ['GEN', 'EXO'])
      BibleBook(
        id: id,
        name: id,
        shortName: id,
        bookNumber: 0,
        chapters: [
          for (var c = 1; c <= 3; c++)
            BibleChapter(
              number: c,
              verses: [BibleVerse(number: 1, text: '$id $c')],
            ),
        ],
      ),
  ];

  @override
  List<BibleBook>? peekLoadedTranslation(String translationId) => _loaded;

  @override
  void activateLoadedTranslation(String translationId) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A stand-in reader showing the chapter its scope resolves.
Widget _chapterText(String tag) => Consumer(
  builder: (context, ref, _) => Text(
    '$tag ${ref.watch(currentChapterProvider).value?.verses.first.text}',
  ),
);

void main() {
  testWidgets('each pane shows its own chapter; moving one leaves the other', (
    tester,
  ) async {
    final sp = await _prefs({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          bibleRepositoryProvider.overrideWithValue(_InMemoryRepository()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SplitReaderLayout(
              primary: _chapterText('MAIN'),
              secondary: _chapterText('PANE'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // main reader running before the pane
    final root = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    root.read(splitViewEnabledProvider.notifier).toggle();
    await tester.pumpAndSettle();
    expect(find.text('PANE EXO 1'), findsOneWidget);

    await root
        .read(splitPaneContainerProvider)
        .read(currentReferenceProvider.notifier)
        .setReference(const BibleReference(bookId: 'GEN', chapter: 2));
    await tester.pumpAndSettle();
    expect(find.text('PANE GEN 2'), findsOneWidget);
    expect(find.text('MAIN EXO 1'), findsOneWidget);

    await root
        .read(currentReferenceProvider.notifier)
        .setReference(const BibleReference(bookId: 'EXO', chapter: 3));
    await tester.pumpAndSettle();
    expect(find.text('MAIN EXO 3'), findsOneWidget);
    expect(find.text('PANE GEN 2'), findsOneWidget);
  });

  testWidgets('a full-page screen opened from the pane acts on the pane', (
    tester,
  ) async {
    final sp = await _prefs({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sp),
          bibleRepositoryProvider.overrideWithValue(_InMemoryRepository()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SplitReaderLayout(
              primary: _chapterText('MAIN'),
              // Opens on the app's navigator, as on phones.
              secondary: Builder(
                builder: (context) => TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute<void>(
                          builder: inReaderScope(
                            context,
                            (_) => _chapterText('OPENED'),
                          ),
                        ),
                      ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final root = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    root.read(splitViewEnabledProvider.notifier).toggle();
    await tester.pumpAndSettle();
    await root
        .read(splitPaneContainerProvider)
        .read(currentReferenceProvider.notifier)
        .setReference(const BibleReference(bookId: 'GEN', chapter: 2));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('OPENED GEN 2'), findsOneWidget);
  });

  testWidgets('on desktop the main reader keeps its state when split view '
      'moves it into its own navigator', (tester) async {
    expect(
      SplitReaderLayout.panesHaveOwnNavigators,
      isTrue,
    ); // tests run on desktop
    final sp = await _prefs({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final mainKey = GlobalKey<_CounterState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
        child: MaterialApp(
          home: Scaffold(
            body: SplitReaderLayout(
              primary: _Counter(key: mainKey),
              secondary: const Text('PANE'),
            ),
          ),
        ),
      ),
    );
    final state = mainKey.currentState!..count = 7;
    final root = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );

    root.read(splitViewEnabledProvider.notifier).toggle(); // on
    await tester.pumpAndSettle();
    expect(mainKey.currentState, same(state));
    expect(
      find.ancestor(of: find.byKey(mainKey), matching: find.byType(Navigator)),
      findsNWidgets(2), // its own + the app's
    );

    root.read(splitViewEnabledProvider.notifier).toggle(); // off
    await tester.pumpAndSettle();
    expect(mainKey.currentState, same(state));
    expect(mainKey.currentState!.count, 7);
  });

  group('pane state', () {
    test('split view starts off every launch', () async {
      final (root, _) = await _containers({'split_view_enabled': true});
      expect(root.read(splitViewEnabledProvider), isFalse);
    });

    test('opens at the main reader\'s chapter', () async {
      final (_, pane) = await _containers({});
      expect(
        pane.read(currentReferenceProvider),
        const BibleReference(bookId: 'EXO', chapter: 1),
      );
      expect(pane.read(currentTranslationProvider), 'kjv');
    });

    test(
      'the pane moves independently; only its translation is saved',
      () async {
        final (root, pane) = await _containers({});
        await pane
            .read(currentReferenceProvider.notifier)
            .setReference(const BibleReference(bookId: 'GEN', chapter: 2));
        await pane
            .read(currentTranslationProvider.notifier)
            .setTranslation('web');

        expect(root.read(currentReferenceProvider).bookId, 'EXO');
        expect(root.read(currentTranslationProvider), 'kjv');
        final sp = root.read(sharedPreferencesProvider);
        expect(sp.getString('split_view_translation'), 'web');
        expect(sp.getKeys().where((k) => k.startsWith('split_view_')), [
          'split_view_translation',
        ]);
        expect(sp.getString('bible_book'), 'EXO');
      },
    );

    test('providers the main reader already uses still get pane copies '
        '(riverpod copies them unscoped otherwise)', () async {
      final (root, _) = await _containers({});
      // The main reader has been running: these exist in the root already.
      root.read(annotationTranslationFilterProvider);
      root.read(searchContextReferenceProvider);
      root.read(translationActionsProvider);

      root.read(splitViewEnabledProvider.notifier).toggle();
      final pane = root.read(splitPaneContainerProvider);
      await pane
          .read(currentReferenceProvider.notifier)
          .setReference(const BibleReference(bookId: 'GEN', chapter: 2));
      // The pane's Versions screen switches the pane, not the main reader.
      await pane.read(translationActionsProvider).switchTo('web');

      expect(pane.read(currentTranslationProvider), 'web');
      expect(root.read(currentTranslationProvider), 'kjv');
      expect(pane.read(annotationTranslationFilterProvider), 'web');
      expect(root.read(annotationTranslationFilterProvider), 'kjv');
      expect(pane.read(searchContextReferenceProvider).bookId, 'GEN');
      expect(root.read(searchContextReferenceProvider).bookId, 'EXO');
    });

    test(
      'derived reader state follows the pane, not the main reader',
      () async {
        final (root, pane) = await _containers({});
        await pane
            .read(currentTranslationProvider.notifier)
            .setTranslation('web');
        pane
            .read(selectedVersesProvider.notifier)
            .toggle(const BibleReference(bookId: 'GEN', chapter: 1, verse: 1));

        expect(pane.read(annotationTranslationFilterProvider), 'web');
        expect(root.read(annotationTranslationFilterProvider), 'kjv');
        expect(pane.read(selectedVersesProvider), hasLength(1));
        expect(root.read(selectedVersesProvider), isEmpty);
      },
    );
  });

  group('reopening split view', () {
    Future<ProviderContainer> openedPaneAtGen2(ProviderContainer root) async {
      final split = root.read(splitViewEnabledProvider.notifier);
      split.toggle(); // opens at the main reader's chapter (EXO 1)
      await root
          .read(splitPaneContainerProvider)
          .read(currentReferenceProvider.notifier)
          .setReference(const BibleReference(bookId: 'GEN', chapter: 2));
      split.toggle(); // close
      split.toggle(); // reopen
      return root.read(splitPaneContainerProvider);
    }

    test('keeps the pane where it was left', () async {
      final (root, _) = await _containers({});
      final pane = await openedPaneAtGen2(root);
      expect(
        pane.read(currentReferenceProvider),
        const BibleReference(bookId: 'GEN', chapter: 2),
      );
    });

    test('with the setting on, jumps to the main reader\'s chapter', () async {
      final (root, _) = await _containers({});
      await root.read(splitPaneFollowsMainProvider.notifier).setEnabled(true);
      final pane = await openedPaneAtGen2(root);
      expect(
        pane.read(currentReferenceProvider),
        const BibleReference(bookId: 'EXO', chapter: 1),
      );
    });
  });

  test('a visible chapter left over from continuous scrolling is ignored '
      'once it is off', () async {
    // Single-chapter mode: the reader shows EXO 1, whatever was last scrolled.
    final (root, _) = await _containers({'reader_continuous_scrolling': false});
    root.read(visibleReaderReferenceProvider.notifier).state =
        const BibleReference(bookId: 'GEN', chapter: 2);
    root.read(splitViewEnabledProvider.notifier).toggle();
    expect(
      root.read(splitPaneContainerProvider).read(currentReferenceProvider),
      const BibleReference(bookId: 'EXO', chapter: 1),
    );
  });

  group('adjacentChapterReference', () {
    test('crosses book boundaries and stops at the ends', () {
      const gen2 = BibleReference(bookId: 'GEN', chapter: 2);
      const exo1 = BibleReference(bookId: 'EXO', chapter: 1);
      expect(adjacentChapterReference(_books, gen2, 1), exo1);
      expect(adjacentChapterReference(_books, exo1, -1), gen2);
      expect(adjacentChapterReference(_books, exo1, 1), isNull);
      expect(
        adjacentChapterReference(
          _books,
          const BibleReference(bookId: 'GEN', chapter: 1),
          -1,
        ),
        isNull,
      );
    });

    test('steps from the fallback the reader shows for a missing book', () {
      // e.g. "FRT" saved from a translation that has front matter.
      expect(
        adjacentChapterReference(
          _books,
          const BibleReference(bookId: 'FRT', chapter: 0),
          1,
        ),
        const BibleReference(bookId: 'GEN', chapter: 2),
      );
    });
  });

  group('layout', () {
    Future<void> pump(WidgetTester tester, Size size) async {
      final sp = await _prefs({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sp),
            availableTranslationsProvider.overrideWith((ref) async => const []),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              appBar: _AppBar(),
              body: SplitReaderLayout(
                primary: Text('MAIN'),
                secondary: Text('PANE'),
              ),
            ),
          ),
        ),
      );
      ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      ).read(splitViewEnabledProvider.notifier).toggle();
      await tester.pumpAndSettle();
    }

    testWidgets('side by side: pane left, main reader right', (tester) async {
      await pump(tester, const Size(1200, 800));
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(
        tester.getCenter(find.text('PANE')).dx,
        lessThan(tester.getCenter(find.text('MAIN')).dx),
      );
      // The pane's chip sits just left of the divider, not among the actions.
      expect(find.text('KJV'), findsOneWidget);
      final dividerX = tester.getTopLeft(find.byType(VerticalDivider)).dx;
      final chipRight = tester.getTopRight(find.byType(Card)).dx;
      expect(chipRight, lessThan(dividerX));
      expect(chipRight, greaterThan(dividerX - 24));
    });

    testWidgets('the pane chip follows the divider on resize', (tester) async {
      await pump(tester, const Size(1200, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pumpAndSettle();
      final dividerX = tester.getTopLeft(find.byType(VerticalDivider)).dx;
      final chipRight = tester.getTopRight(find.byType(Card)).dx;
      expect(chipRight, lessThan(dividerX));
      expect(chipRight, greaterThan(dividerX - 24));
    });

    testWidgets('a phone held upright hides split view until it turns back', (
      tester,
    ) async {
      await pump(tester, const Size(860, 400)); // landscape: side by side
      expect(find.text('PANE'), findsOneWidget);
      final root = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );

      tester.view.physicalSize = const Size(400, 860); // rotate upright
      await tester.pumpAndSettle();
      expect(find.text('PANE'), findsNothing);
      expect(find.text('KJV'), findsNothing); // no pane chip either
      expect(root.read(splitViewEnabledProvider), isTrue); // still on

      tester.view.physicalSize = const Size(860, 400); // back to landscape
      await tester.pumpAndSettle();
      expect(find.text('PANE'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsOneWidget);
    });

    testWidgets('narrow landscape stacks: main reader on top', (tester) async {
      await pump(tester, const Size(690, 400));
      expect(find.byType(VerticalDivider), findsNothing);
      expect(
        tester.getCenter(find.text('MAIN')).dy,
        lessThan(tester.getCenter(find.text('PANE')).dy),
      );
      expect(find.text('KJV'), findsOneWidget); // in the actions row
    });
  });
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    flexibleSpace: const SplitPaneTranslationChip(alignToDivider: true),
    actions: const [SplitPaneTranslationChip()],
  );
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;

  @override
  Widget build(BuildContext context) => Text('MAIN $count');
}
