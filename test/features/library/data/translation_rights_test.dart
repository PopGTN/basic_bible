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
  group('rightsFromCatalogJson', () {
    test('reads every rights field and resolves the notes path', () {
      final rights = rightsFromCatalogJson({
        'rightsStatus': 'public_domain',
        'allowDownload': true,
        'allowBundling': true,
        'license': 'Public Domain',
        'licenseUrl': 'https://ebible.org/publicdomain.htm',
        'copyrightNotice': ' Free to copy. ',
        'officialSourceUrl': 'https://ebible.org/Scriptures/',
        'licenseNotesPath': 'licenses/bibles/kjv.md',
      })!;

      expect(rights.isPublicDomain, isTrue);
      expect(rights.license, 'Public Domain');
      expect(rights.copyrightNotice, 'Free to copy.');
      expect(rights.sourceUrl, 'https://ebible.org/Scriptures/');
      expect(
        rights.notesUrl,
        'https://github.com/PopGTN/bible-data/blob/main/licenses/bibles/kjv.md',
      );
      expect(rights.allowDownload, isTrue);
      expect(rights.allowBundling, isTrue);
    });

    test('is null when the entry has no rights fields', () {
      expect(rightsFromCatalogJson({'id': 'x', 'name': 'X'}), isNull);
    });

    test('ignores malformed values instead of throwing', () {
      final rights = rightsFromCatalogJson({
        'license': 42,
        'copyrightNotice': {'text': 'x'},
        'officialSourceUrl': 'https://example.org/',
        'licenseNotesPath': '/licenses/bibles/x.md',
      })!;

      expect(rights.license, isEmpty);
      expect(rights.copyrightNotice, isEmpty);
      expect(rights.sourceUrl, 'https://example.org/');
      expect(
        rights.notesUrl,
        'https://github.com/PopGTN/bible-data/blob/main/licenses/bibles/x.md',
      );
    });

    test('a download ban alone is kept', () {
      final rights = rightsFromCatalogJson({'allowDownload': false})!;
      expect(rights.allowDownload, isFalse);
    });
  });

  group('merging', () {
    final builtIn = kBuiltInTranslations.firstWhere((t) => t.id == 'web');

    test('built-ins have offline rights', () {
      for (final t in kBuiltInTranslations) {
        expect(t.rights?.isPublicDomain, isTrue, reason: t.id);
      }
    });

    test('catalog rights override the built-in fallback', () {
      const remoteRights = BibleTranslationRights(license: 'Remote');
      final merged = mergeCatalogTranslation(
        builtIn: builtIn,
        remote: builtIn.copyWith(rights: remoteRights),
      );
      expect(merged.rights, remoteRights);
    });

    test('the built-in fallback survives a catalog entry without rights', () {
      final remote = BibleTranslation(
        id: 'web',
        name: 'World English Bible',
        language: 'en',
        description: '',
      );
      final merged = mergeCatalogTranslation(builtIn: builtIn, remote: remote);
      expect(merged.rights, builtIn.rights);
    });

    test('stored DB rows keep the base rights', () {
      final stored = builtIn.copyWith(isLocal: true);
      final merged = mergeStoredTranslation(
        base: builtIn,
        stored: BibleTranslation(
          id: stored.id,
          name: stored.name,
          language: stored.language,
          description: stored.description,
        ),
      );
      expect(merged.rights, builtIn.rights);
    });
  });

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
