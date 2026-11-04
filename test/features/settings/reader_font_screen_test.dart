import 'dart:io';
import 'dart:typed_data';

import 'package:basic_bible/l10n/app_localizations.dart';
import 'package:basic_bible/src/features/settings/application/view_models/reader_font_view_models.dart';
import 'package:basic_bible/src/features/settings/data/reader_font_repository.dart';
import 'package:basic_bible/src/features/settings/presentation/reader_font_screen.dart';
import 'package:basic_bible/src/services/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('font page lists sources and selecting a font checks it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fontsDir = Directory.systemTemp.createTempSync('font_screen');
    addTearDown(() => fontsDir.deleteSync(recursive: true));
    final deviceDir = Directory(p.join(fontsDir.path, 'device'))..createSync();
    File(p.join(deviceDir.path, 'Lora-Regular.ttf')).writeAsBytesSync([1]);

    final repository = ReaderFontRepository(
      prefs,
      registrar: (family, files) async {},
      fontsDirectory: () async => fontsDir,
      assetKeys: () async => ['assets/fonts/GentiumPlus-Regular.ttf'],
      deviceFontDirectories: [deviceDir.path],
      fileReader: (path) async => Uint8List(16),
    );

    // Real file I/O never completes inside the widget-test fake clock, so
    // scan first (the result is cached by the repository).
    await tester.runAsync(repository.scanner.fonts);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          readerFontRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const ReaderFontScreen(),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('System Default'), findsWidgets);
    expect(find.text('Included with the app'), findsOneWidget);
    expect(find.text('Gentium Plus'), findsOneWidget);
    expect(find.text('Import a font file'), findsOneWidget);
    expect(find.text('Installed on this device'), findsOneWidget);

    // The installed font is listed and searchable.
    await tester.scrollUntilVisible(
      find.text('Lora'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.textContaining('No fonts match'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'lor');
    await tester.pumpAndSettle();
    expect(find.text('Lora'), findsOneWidget);

    await tester.tap(find.text('Lora'));
    await tester.pumpAndSettle();
    expect(repository.selected.name, 'Lora');
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('previews load only after scrolling stops', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fontsDir = Directory.systemTemp.createTempSync('font_scroll');
    addTearDown(() => fontsDir.deleteSync(recursive: true));
    final deviceDir = Directory(p.join(fontsDir.path, 'device'))..createSync();
    for (var i = 0; i < 60; i++) {
      final name = 'Family${i.toString().padLeft(2, '0')}-Regular.ttf';
      File(p.join(deviceDir.path, name)).writeAsBytesSync([1]);
    }

    final registered = <String>[];
    final repository = ReaderFontRepository(
      prefs,
      registrar: (family, files) async => registered.add(family),
      fontsDirectory: () async => fontsDir,
      assetKeys: () async => const [],
      deviceFontDirectories: [deviceDir.path],
      fileReader: (path) async => Uint8List(16),
    );
    await tester.runAsync(repository.scanner.fonts);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          readerFontRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReaderFontScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final initial = registered.length;
    expect(initial, greaterThan(0)); // Rows visible at rest get previews.

    // Hold a drag across several frames: nothing new may load meanwhile.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(CustomScrollView)),
    );
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -120));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(registered.length, initial);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(registered.length, greaterThan(initial));
  });
}
