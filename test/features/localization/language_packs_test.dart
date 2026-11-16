import 'dart:ui' as ui;

import 'package:basic_bible/src/features/localization/language_pack_service.dart';
import 'package:basic_bible/src/features/localization/language_pack_store.dart';
import 'package:basic_bible/src/features/settings/application/view_models/language_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _fr = '{"@@locale":"fr","home":"Accueil","@home":{},"bible":"Bible"}';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('device language resolution picks first supported, else English', () {
    expect(resolveDeviceLanguage(const [ui.Locale('fr', 'CA')]), 'fr');
    expect(
      resolveDeviceLanguage(const [ui.Locale('ja'), ui.Locale('fr')]),
      'fr',
    );
    expect(resolveDeviceLanguage(const [ui.Locale('ja')]), 'en');
    expect(resolveDeviceLanguage(const []), 'en');
  });

  test('parseArb drops metadata and rejects non-objects', () {
    expect(LanguagePackStore.parseArb(_fr), {'home': 'Accueil', 'bible': 'Bible'});
    expect(() => LanguagePackStore.parseArb('[]'), throwsFormatException);
  });

  test('ensurePack downloads, caches, and falls back to cache offline', () async {
    final prefs = await SharedPreferences.getInstance();
    var calls = 0;
    var online = true;
    final client = MockClient((req) async {
      calls++;
      if (!online) throw http.ClientException('offline');
      expect(req.url.path.endsWith('app_fr.arb'), isTrue);
      return http.Response.bytes(_fr.codeUnits, 200);
    });
    var now = DateTime(2026, 1, 1);
    final service = LanguagePackService(
      prefs: prefs,
      client: client,
      baseUrl: 'https://example.com/l10n',
      now: () => now,
    );

    await service.ensurePack('fr');
    expect(calls, 1);
    expect(LanguagePackStore.strings('fr')['home'], 'Accueil');
    expect(service.isAvailableOffline('fr'), isTrue);

    await service.ensurePack('fr'); // fresh: no network
    expect(calls, 1);

    now = now.add(const Duration(days: 2));
    online = false;
    await service.ensurePack('fr'); // stale + offline: keeps cache
    expect(calls, 2);
    expect(LanguagePackStore.strings('fr')['home'], 'Accueil');
  });

  test('a pack cached for a different build ref is re-downloaded', () async {
    SharedPreferences.setMockInitialValues({
      'l10n_pack_fr': _fr,
      'l10n_pack_checked_fr': DateTime.now().millisecondsSinceEpoch,
      'l10n_pack_ref_fr': 'some-older-ref',
    });
    final prefs = await SharedPreferences.getInstance();
    var calls = 0;
    final service = LanguagePackService(
      prefs: prefs,
      client: MockClient((_) async {
        calls++;
        return http.Response.bytes(_fr.codeUnits, 200);
      }),
      baseUrl: 'https://example.com/l10n',
    );
    await service.ensurePack('fr');
    expect(calls, 1);
  });

  test('ensurePack throws when offline with nothing cached', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = LanguagePackService(
      prefs: prefs,
      client: MockClient((_) async => http.Response('nope', 404)),
      baseUrl: 'https://example.com/l10n',
    );
    await expectLater(service.ensurePack('de'), throwsA(anything));
    expect(service.isAvailableOffline('de'), isFalse);
  });

  test('first launch follows the device language when a pack is cached', () async {
    SharedPreferences.setMockInitialValues({'l10n_pack_fr': _fr});
    final prefs = await SharedPreferences.getInstance();
    final service = LanguagePackService(prefs: prefs);
    final state = loadInitialLanguageState(
      prefs,
      service,
      deviceLocales: const [ui.Locale('fr', 'CA')],
    );
    expect(state.code, 'fr');
    expect(state.followsDevice, isTrue);
  });

  test('saved manual choice wins over device language', () async {
    SharedPreferences.setMockInitialValues({
      'languageCode': 'en',
      'languageIsSystem': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final state = loadInitialLanguageState(
      prefs,
      LanguagePackService(prefs: prefs),
      deviceLocales: const [ui.Locale('fr')],
    );
    expect(state.code, 'en');
    expect(state.followsDevice, isFalse);
  });
}
