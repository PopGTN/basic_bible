// Issue #18: copyright details come from the catalog and survive the merges
// that build the Versions list.

import 'dart:convert';

import 'package:basic_bible/src/features/library/data/bible_translation_catalog.dart';
import 'package:basic_bible/src/features/library/data/remote_translation_catalog_service.dart';
import 'package:basic_bible/src/models/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Future<List<BibleTranslation>> _parse(Map<String, dynamic> entry) {
  final service = RemoteTranslationCatalogService(
    client: MockClient(
      (_) async => http.Response(
        jsonEncode({
          'translations': [
            {
              'id': 'web',
              'name': 'World English Bible',
              'language': 'en',
              'artifacts': [
                {
                  'format': 'usfx',
                  'downloadUrl': 'https://example.com/web.xml',
                  'fileName': 'web.xml',
                },
              ],
              ...entry,
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json'},
      ),
    ),
  );
  return service.fetchTranslations(forceRefresh: true);
}

void main() {
  test('catalog rights fields are parsed', () async {
    final translations = await _parse({
      'license': 'Public Domain',
      'licenseUrl': 'https://worldenglishbible.org/',
      'copyrightNotice': 'Freely copied.',
      'officialSourceUrl': 'https://example.org/',
    });
    expect(
      translations.single.rights,
      const BibleTranslationRights(
        license: 'Public Domain',
        licenseUrl: 'https://worldenglishbible.org/',
        copyrightNotice: 'Freely copied.',
        sourceUrl: 'https://example.org/',
      ),
    );
  });

  test('an entry without rights fields has no rights', () async {
    final translations = await _parse({'license': '  '});
    expect(translations.single.rights, isNull);
  });

  test('built-ins have offline rights and the catalog overrides them', () {
    final kjv = kBuiltInTranslations.firstWhere((t) => t.id == 'kjv');
    expect(kjv.rights?.license, 'Public Domain');

    const remoteRights = BibleTranslationRights(license: 'Updated');
    final merged = mergeCatalogTranslation(
      builtIn: kjv,
      remote: kjv.copyWith(rights: remoteRights),
    );
    expect(merged.rights, remoteRights);
  });

  test('stored rows (which have no rights column) keep the base rights', () {
    final kjv = kBuiltInTranslations.firstWhere((t) => t.id == 'kjv');
    final stored = BibleTranslation(
      id: 'kjv',
      name: 'King James Version',
      language: 'en',
      description: '',
      isLocal: true,
    );
    expect(
      mergeStoredTranslation(base: kjv, stored: stored).rights,
      kjv.rights,
    );
  });
}
